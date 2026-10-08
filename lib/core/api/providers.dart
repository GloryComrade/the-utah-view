import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/story_index.dart';
import '../storage/key_value_store.dart';
import 'api_client.dart';
import 'models/models.dart';
import 'news_repository.dart';

/// Opened in `main()` and injected with `overrideWithValue`.
final appStoresProvider = Provider<AppStores>(
  (ref) => throw UnimplementedError('appStoresProvider must be overridden'),
);

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final newsRepositoryProvider = Provider<NewsRepository>(
  (ref) => NewsRepository(
    api: ref.watch(apiClientProvider),
    cache: ref.watch(appStoresProvider).apiCache,
  ),
);

/// Retry policy for API-backed providers: transient failures (offline,
/// timeouts, 5xx) retry with backoff; 404s and bad payloads don't.
Duration? apiRetry(int retryCount, Object error) {
  if (retryCount >= 3 || error is! ApiException) return null;
  return switch (error.kind) {
    ApiErrorKind.notFound || ApiErrorKind.invalidResponse => null,
    _ => Duration(milliseconds: 800 * (1 << retryCount)),
  };
}

/// Stale-while-revalidate for one endpoint.
///
/// `build` returns the cached copy synchronously when there is one, so
/// screens render on the first frame (and offline), then quietly swaps in
/// fresh data. With no cache it waits for the network.
abstract class CachedEndpointNotifier<T> extends AsyncNotifier<T> {
  Endpoint<T> get endpoint;

  /// A second offline source, e.g. a bookmarked copy of a story.
  T? offlineFallback() => null;

  /// Called with every successful network response.
  void onFetched(T value) {}

  @override
  FutureOr<T> build() {
    final repo = ref.watch(newsRepositoryProvider);
    final cached = repo.cached(endpoint) ?? offlineFallback();
    if (cached != null) {
      scheduleMicrotask(_refreshQuietly);
      return cached;
    }
    return _fetch(repo);
  }

  Future<T> _fetch(NewsRepository repo) async {
    final value = await repo.fetch(endpoint);
    onFetched(value);
    return value;
  }

  /// Fetches fresh data and publishes it if it changed. Throws
  /// [ApiException] so pull-to-refresh can tell the reader; whatever is on
  /// screen stays there.
  Future<void> refresh() async {
    final fresh = await _fetch(ref.read(newsRepositoryProvider));
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null ||
        !const DeepCollectionEquality().equals(current, fresh)) {
      state = AsyncData(fresh);
    }
  }

  Future<void> _refreshQuietly() async {
    if (!ref.mounted) return;
    try {
      await refresh();
    } on Object {
      // Offline or server trouble: keep showing the cached copy.
    }
  }
}

class StoriesNotifier extends CachedEndpointNotifier<List<Story>> {
  @override
  Endpoint<List<Story>> get endpoint => NewsRepository.stories;
}

class LayoutNotifier extends CachedEndpointNotifier<LayoutConfig> {
  @override
  Endpoint<LayoutConfig> get endpoint => NewsRepository.layout;
}

class SiteConfigNotifier extends CachedEndpointNotifier<SiteConfig> {
  @override
  Endpoint<SiteConfig> get endpoint => NewsRepository.site;
}

class PagesNotifier extends CachedEndpointNotifier<List<SitePageSummary>> {
  @override
  Endpoint<List<SitePageSummary>> get endpoint => NewsRepository.pages;
}

class SitePageNotifier extends CachedEndpointNotifier<SitePage> {
  SitePageNotifier(this.slug);

  final String slug;

  @override
  Endpoint<SitePage> get endpoint => NewsRepository.page(slug);
}

/// Published stories, newest first (no bodies).
final storiesProvider = AsyncNotifierProvider<StoriesNotifier, List<Story>>(
  StoriesNotifier.new,
  retry: apiRetry,
);

/// Front-page layout.
final layoutProvider = AsyncNotifierProvider<LayoutNotifier, LayoutConfig>(
  LayoutNotifier.new,
  retry: apiRetry,
);

/// Site-wide copy and navigation.
final siteConfigProvider =
    AsyncNotifierProvider<SiteConfigNotifier, SiteConfig>(
      SiteConfigNotifier.new,
      retry: apiRetry,
    );

/// Static "About" pages.
final pagesProvider =
    AsyncNotifierProvider<PagesNotifier, List<SitePageSummary>>(
      PagesNotifier.new,
      retry: apiRetry,
    );

/// One static page by slug.
final sitePageProvider = AsyncNotifierProvider.autoDispose
    .family<SitePageNotifier, SitePage, String>(
      SitePageNotifier.new,
      retry: apiRetry,
    );

/// Stories by id, or null until the list has loaded once.
final storyIndexProvider = Provider<StoryIndex?>((ref) {
  final stories = ref.watch(storiesProvider).value;
  return stories == null ? null : StoryIndex(stories);
});

/// Navigation categories, falling back to the website's defaults.
final navCategoriesProvider = Provider<List<NavCategory>>(
  (ref) =>
      ref.watch(siteConfigProvider).value?.effectiveNavCategories ??
      NavCategory.fallback,
);
