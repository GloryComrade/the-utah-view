import 'dart:convert';

import '../storage/key_value_store.dart';
import 'api_client.dart';
import 'models/json_converters.dart';
import 'models/models.dart';
import 'parsers.dart';

/// A GET endpoint whose raw JSON response is cached on disk.
class Endpoint<T> {
  const Endpoint(this.path, this.parse);

  final String path;
  final T Function(Object? json) parse;

  String get cacheKey => path;

  @override
  String toString() => 'Endpoint($path)';
}

enum SubscribeResult { subscribed, alreadySubscribed }

/// Single entry point for all data. Reads are cache-first: callers show
/// [cached] immediately, then call [fetch] to refresh in the background.
class NewsRepository {
  NewsRepository({required this._api, required this._cache});

  final ApiClient _api;
  final KeyValueStore _cache;

  static const stories = Endpoint<List<Story>>('/api/stories', parseStoryList);
  static const layout = Endpoint<LayoutConfig>(
    '/api/config/layout',
    parseLayoutConfig,
  );
  static const site = Endpoint<SiteConfig>('/api/config/site', parseSiteConfig);
  static const pages = Endpoint<List<SitePageSummary>>(
    '/api/pages',
    parsePageList,
  );

  static Endpoint<StoryDetail> story(String id) =>
      Endpoint('/api/stories/${Uri.encodeComponent(id)}', parseStoryDetail);

  static Endpoint<SitePage> page(String slug) =>
      Endpoint('/api/pages/${Uri.encodeComponent(slug)}', parseSitePage);

  /// The last good response for [endpoint], or null if there isn't one.
  T? cached<T>(Endpoint<T> endpoint) {
    final entry = _readEntry(endpoint.cacheKey);
    if (entry == null) return null;
    try {
      return endpoint.parse(entry.data);
    } on Object {
      return null;
    }
  }

  /// When [endpoint] was last fetched successfully.
  DateTime? cachedAt(Endpoint<Object?> endpoint) =>
      _readEntry(endpoint.cacheKey)?.fetchedAt;

  /// Fetches [endpoint] from the network and stores the response.
  ///
  /// The response is parsed before it is cached, so a malformed payload
  /// never replaces a good cached copy. Throws [ApiException].
  Future<T> fetch<T>(Endpoint<T> endpoint) async {
    final json = await _api.getJson(endpoint.path);
    final T value;
    try {
      value = endpoint.parse(json);
    } on FormatException catch (e) {
      throw ApiException(ApiErrorKind.invalidResponse, detail: e.message);
    }
    await _cache.write(
      endpoint.cacheKey,
      jsonEncode({'t': DateTime.now().millisecondsSinceEpoch, 'd': json}),
    );
    return value;
  }

  Future<SubscribeResult> subscribe(String email) async {
    final json = await _api.postJson('/api/subscribe', {'email': email});
    final message = coerceJsonString(asJsonMap(json)?['message']);
    return message.toLowerCase().contains('already')
        ? SubscribeResult.alreadySubscribed
        : SubscribeResult.subscribed;
  }

  Future<void> unsubscribe(String email) async {
    await _api.postJson('/api/unsubscribe', {'email': email});
  }

  _CacheEntry? _readEntry(String key) {
    final raw = _cache.read(key);
    if (raw == null) return null;
    try {
      final map = asJsonMap(jsonDecode(raw));
      final millis = map?['t'];
      if (map == null || millis is! int) return null;
      return _CacheEntry(map['d'], DateTime.fromMillisecondsSinceEpoch(millis));
    } on FormatException {
      return null;
    }
  }
}

class _CacheEntry {
  const _CacheEntry(this.data, this.fetchedAt);

  final Object? data;
  final DateTime fetchedAt;
}
