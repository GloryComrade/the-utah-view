import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:utah_view/core/api/api_client.dart';
import 'package:utah_view/core/api/news_repository.dart';
import 'package:utah_view/core/api/parsers.dart';
import 'package:utah_view/core/api/providers.dart';
import 'package:utah_view/core/router/app_router.dart';
import 'package:utah_view/core/settings/app_settings.dart';
import 'package:utah_view/core/storage/key_value_store.dart';
import 'package:utah_view/core/theme/theme.dart';
import 'package:utah_view/shared/widgets/story_image.dart';

import 'fixtures.dart';
import 'test_harness.dart';

/// Serves canned responses by "METHOD /path"; anything else fails like a
/// dropped connection.
class FakeAdapter implements HttpClientAdapter {
  final routes = <String, (int, String)>{};
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes['${options.method} ${options.uri.path}'];
    if (route == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      route.$2,
      route.$1,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// An API client with no network: every request fails as offline unless a
/// route is added to [adapter].
ApiClient fakeApi([FakeAdapter? adapter]) => ApiClient(
  dio: Dio(
    BaseOptions(
      baseUrl: 'https://api.theutahview.com',
      responseType: ResponseType.plain,
    ),
  )..httpClientAdapter = adapter ?? FakeAdapter(),
);

/// The lead story id in the captured layout fixture.
String get fixtureLeadId => parseLayoutConfig(fixture('layout.json')).heroLead;

/// In-memory stores whose response cache already holds the live fixtures,
/// exactly as if the app had been opened online once.
AppStores seededStores({bool withLayout = true}) {
  final stores = AppStores.inMemory();
  void cache(String path, Object? json) => unawaited(
    stores.apiCache.write(
      path,
      jsonEncode({
        't': DateTime(2026, 10, 6).millisecondsSinceEpoch,
        'd': json,
      }),
    ),
  );
  cache(NewsRepository.stories.path, fixture('stories.json'));
  if (withLayout) cache(NewsRepository.layout.path, fixture('layout.json'));
  cache(NewsRepository.site.path, fixture('site.json'));
  cache(NewsRepository.pages.path, fixture('pages.json'));
  cache(NewsRepository.story(fixtureLeadId).path, fixture('story_detail.json'));
  cache(
    NewsRepository.page('our-mission').path,
    fixture('page_our_mission.json'),
  );
  return stores;
}

/// The real router and screens over seeded, offline data.
Widget routerTestApp({
  required String location,
  AppStores? stores,
  ApiClient? api,
  bool dark = false,
}) {
  final router = buildRouter(initialLocation: location);
  addTearDown(router.dispose);
  return ProviderScope(
    overrides: [
      appStoresProvider.overrideWithValue(stores ?? seededStores()),
      apiClientProvider.overrideWithValue(api ?? fakeApi()),
      routerProvider.overrideWithValue(router),
    ],
    // Mirrors UtahViewApp (theme mode comes from settings), plus a capture
    // boundary and no network images.
    child: Consumer(
      builder: (context, ref, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: dark
            ? ThemeMode.dark
            : ref.watch(settingsProvider.select((s) => s.themeMode)) ==
                  ThemeMode.system
            ? ThemeMode.light
            : ref.watch(settingsProvider.select((s) => s.themeMode)),
        routerConfig: router,
        builder: (context, child) => RepaintBoundary(
          key: screenshotKey,
          child: ImagePolicy(loadNetworkImages: false, child: child!),
        ),
      ),
    ),
  );
}

/// Pumps enough frames for routes, heroes and async builds to finish.
/// (The briefing ticker animates forever, so pumpAndSettle can't be used.)
Future<void> settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
