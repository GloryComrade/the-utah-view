import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utah_view/core/api/api_client.dart';
import 'package:utah_view/core/api/models/models.dart';
import 'package:utah_view/core/api/providers.dart';
import 'package:utah_view/core/auth/reader_account.dart';
import 'package:utah_view/core/storage/key_value_store.dart';
import 'package:utah_view/features/saved/saved_stories.dart';

/// One reader account's bookmarks on the server, shared by several devices.
class FakeSavedServer implements HttpClientAdapter {
  FakeSavedServer([List<String>? ids]) : ids = [...?ids];

  List<String> ids;
  int puts = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ResponseBody ok(Object body) => ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
    final path = options.uri.path;
    if (path == '/api/me/saved' && options.method == 'GET') {
      return ok({'ids': ids});
    }
    if (path == '/api/me/saved' && options.method == 'PUT') {
      puts++;
      final body = jsonDecode(options.data as String) as Map<String, dynamic>;
      ids = [for (final id in body['ids'] as List) id as String];
      return ok({'ids': ids});
    }
    if (path.startsWith('/api/stories/')) {
      final id = Uri.decodeComponent(path.split('/').last);
      return ok({'id': id, 'title': 'Story $id', 'body': '<p>$id</p>'});
    }
    throw DioException.connectionError(requestOptions: options, reason: 'x');
  }

  @override
  void close({bool force = false}) {}
}

/// A phone signed in to the shared account, with its own local storage.
class Device {
  Device(FakeSavedServer server) : stores = AppStores.inMemory() {
    for (final MapEntry(:key, :value) in {
      'account_token': 'session-token',
      'account_email': 'reader@example.com',
      'account_name': 'Reader',
    }.entries) {
      stores.settings.write(key, value);
    }
    api = ApiClient(
      dio: Dio(
        BaseOptions(
          baseUrl: 'https://api.theutahview.com',
          responseType: ResponseType.plain,
        ),
      )..httpClientAdapter = server,
    );
  }

  final AppStores stores;
  late final ApiClient api;
  ProviderContainer? _c;

  /// Opens the app (a fresh container over the same storage).
  Future<ProviderContainer> launch() async {
    _c?.dispose();
    final c = _c = ProviderContainer(
      overrides: [
        appStoresProvider.overrideWithValue(stores),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(c.dispose);
    await c.read(savedSyncProvider).schedule();
    return c;
  }

  List<String> savedIds() =>
      [for (final s in _c!.read(savedStoriesProvider)) s.story.id]..sort();

  Future<void> save(String id) async {
    await _c!
        .read(savedStoriesProvider.notifier)
        .save(StoryDetail(id: id, title: id, body: '<p>$id</p>'));
    await _c!.read(savedSyncProvider).schedule();
  }

  Future<void> remove(String id) async {
    await _c!.read(savedStoriesProvider.notifier).remove(id);
    await _c!.read(savedSyncProvider).schedule();
  }
}

void main() {
  group('mergeSavedIds', () {
    test('first sync keeps everything from both sides', () {
      final m = mergeSavedIds(local: ['a', 'b'], remote: ['b', 'c']);
      expect(m.ids, ['a', 'b', 'c']);
      expect(m.toDownload, ['c']);
      expect(m.toRemove, isEmpty);
    });

    test('a story removed on this device is dropped from the account', () {
      final m = mergeSavedIds(
        local: ['a'],
        remote: ['a', 'b'],
        base: {'a', 'b'},
      );
      expect(m.ids, ['a']);
      expect(m.toDownload, isEmpty);
    });

    test('a story removed on another device is removed here too', () {
      final m = mergeSavedIds(
        local: ['a', 'b'],
        remote: ['a'],
        base: {'a', 'b'},
      );
      expect(m.ids, ['a']);
      expect(m.toRemove, ['b']);
    });

    test('saves on both sides since the last sync are all kept', () {
      final m = mergeSavedIds(
        local: ['a', 'x'],
        remote: ['a', 'y'],
        base: {'a'},
      );
      expect(m.ids, ['a', 'x', 'y']);
      expect(m.toDownload, ['y']);
    });
  });

  test('saving on one phone keeps what another phone saved', () async {
    final server = FakeSavedServer();
    final phoneA = Device(server);
    final phoneB = Device(server);
    await phoneA.launch();
    await phoneB.launch();

    await phoneA.save('x');
    expect(server.ids, ['x']);

    // Phone B has been signed in all along and saves something else.
    await phoneB.save('y');
    expect(server.ids..sort(), ['x', 'y']);
    expect(phoneB.savedIds(), ['x', 'y']);

    // Phone A picks up y on its next launch.
    await phoneA.launch();
    expect(phoneA.savedIds(), ['x', 'y']);
  });

  test('removing on one phone removes it everywhere', () async {
    final server = FakeSavedServer();
    final phoneA = Device(server);
    final phoneB = Device(server);
    await phoneA.launch();
    await phoneA.save('x');
    await phoneA.save('y');
    await phoneB.launch();
    expect(phoneB.savedIds(), ['x', 'y']);

    await phoneA.remove('x');
    expect(server.ids, ['y']);

    await phoneB.launch();
    expect(phoneB.savedIds(), ['y']);
    expect(server.ids, ['y']);
  });

  test('signing in on a new phone merges instead of replacing', () async {
    final server = FakeSavedServer(['x']);
    final phone = Device(server);
    // Bookmarks made before signing in on this phone.
    await phone.stores.settings.delete('account_token');
    final c = await phone.launch();
    await c
        .read(savedStoriesProvider.notifier)
        .save(const StoryDetail(id: 'local', title: 'Local'));
    expect(server.ids, ['x']);

    await phone.stores.settings.write('account_token', 'session-token');
    await phone.launch();
    expect(phone.savedIds(), ['local', 'x']);
    expect(server.ids..sort(), ['local', 'x']);
  });
}
