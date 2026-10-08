import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/api_client.dart';
import 'package:utah_view/core/api/news_repository.dart';
import 'package:utah_view/core/storage/key_value_store.dart';

import '../support/app_harness.dart';

void main() {
  late FakeAdapter adapter;
  late MemoryKeyValueStore cache;
  late NewsRepository repo;

  setUp(() {
    adapter = FakeAdapter();
    cache = MemoryKeyValueStore();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.theutahview.com',
        responseType: ResponseType.plain,
      ),
    )..httpClientAdapter = adapter;
    repo = NewsRepository(
      api: ApiClient(dio: dio),
      cache: cache,
    );
  });

  String storiesJson(List<String> ids) => jsonEncode({
    'stories': [
      for (final id in ids) {'id': id, 'title': id},
    ],
  });

  test('nothing is cached before the first fetch', () {
    expect(repo.cached(NewsRepository.stories), isNull);
  });

  test('fetch parses, caches, and the cache survives going offline', () async {
    adapter.routes['GET /api/stories'] = (200, storiesJson(['a', 'b']));
    final fresh = await repo.fetch(NewsRepository.stories);
    expect(fresh.map((s) => s.id), ['a', 'b']);

    adapter.routes.clear();
    expect(repo.cached(NewsRepository.stories)!.map((s) => s.id), ['a', 'b']);
    expect(repo.cachedAt(NewsRepository.stories), isNotNull);
    await expectLater(
      repo.fetch(NewsRepository.stories),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.offline),
      ),
    );
    expect(repo.cached(NewsRepository.stories), hasLength(2));
  });

  test('a malformed payload never overwrites a good cached copy', () async {
    adapter.routes['GET /api/stories'] = (200, storiesJson(['a']));
    await repo.fetch(NewsRepository.stories);

    adapter.routes['GET /api/stories'] = (200, '{"oops": true}');
    await expectLater(
      repo.fetch(NewsRepository.stories),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.invalidResponse,
        ),
      ),
    );
    expect(repo.cached(NewsRepository.stories)!.single.id, 'a');

    adapter.routes['GET /api/stories'] = (200, '<html>gateway</html>');
    await expectLater(
      repo.fetch(NewsRepository.stories),
      throwsA(isA<ApiException>()),
    );
    expect(repo.cached(NewsRepository.stories)!.single.id, 'a');
  });

  test('404 is classified as notFound', () async {
    adapter.routes['GET /api/stories/gone'] = (404, '{"error":"Not found"}');
    await expectLater(
      repo.fetch(NewsRepository.story('gone')),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.notFound,
        ),
      ),
    );
  });

  test('5xx is classified as server', () async {
    adapter.routes['GET /api/config/layout'] = (503, 'unavailable');
    await expectLater(
      repo.fetch(NewsRepository.layout),
      throwsA(
        isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.server),
      ),
    );
  });

  test('slugs and ids are URL-encoded', () async {
    adapter.routes['GET /api/pages/About%20Us'] = (
      200,
      '{"slug":"About Us","title":"About Us"}',
    );
    final page = await repo.fetch(NewsRepository.page('About Us'));
    expect(page.title, 'About Us');
  });

  test('a corrupt cache entry reads as no cache', () async {
    await cache.write('/api/stories', 'not json');
    expect(repo.cached(NewsRepository.stories), isNull);
  });

  group('subscribe', () {
    test('new subscriber', () async {
      adapter.routes['POST /api/subscribe'] = (200, '{"message":"Subscribed"}');
      expect(await repo.subscribe('a@b.co'), SubscribeResult.subscribed);
      final sent = adapter.requests.last;
      expect(jsonDecode(sent.data as String), {'email': 'a@b.co'});
    });

    test('already subscribed', () async {
      adapter.routes['POST /api/subscribe'] = (
        200,
        '{"message":"Already subscribed"}',
      );
      expect(await repo.subscribe('a@b.co'), SubscribeResult.alreadySubscribed);
    });

    test('unsubscribe posts the email', () async {
      adapter.routes['POST /api/unsubscribe'] = (200, '{"message":"ok"}');
      await repo.unsubscribe('a@b.co');
      expect(adapter.requests.last.uri.path, '/api/unsubscribe');
    });
  });
}
