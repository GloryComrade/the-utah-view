import 'package:hive_ce_flutter/hive_flutter.dart';

import 'key_value_store.dart';

class HiveKeyValueStore implements KeyValueStore {
  HiveKeyValueStore(this._box);

  final Box<String> _box;

  /// Opens (or creates) the named box.
  static Future<HiveKeyValueStore> open(String name) async =>
      HiveKeyValueStore(await Hive.openBox<String>(name));

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Iterable<String> get keys => _box.keys.map((k) => k.toString());

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}

/// Opens the app's three Hive boxes. Kept apart from [AppStores] so the
/// data layer stays pure Dart (and runnable from `dart run tool/...`).
Future<AppStores> openHiveStores() async {
  await Hive.initFlutter('utah_view');
  final stores = await Future.wait([
    HiveKeyValueStore.open('api_cache'),
    HiveKeyValueStore.open('saved_stories'),
    HiveKeyValueStore.open('settings'),
  ]);
  return AppStores(
    apiCache: stores[0],
    savedStories: stores[1],
    settings: stores[2],
  );
}
