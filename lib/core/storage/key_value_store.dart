/// A minimal persistent string store. Hive-backed in the app, in-memory in
/// tests, so nothing above this layer depends on Hive directly.
abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Iterable<String> get keys;
  Future<void> clear();
}

class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : _map = {...?initial};

  final Map<String, String> _map;

  @override
  String? read(String key) => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<void> delete(String key) async => _map.remove(key);

  @override
  Iterable<String> get keys => _map.keys;

  @override
  Future<void> clear() async => _map.clear();
}

/// The three stores the app uses, opened once at startup.
class AppStores {
  const AppStores({
    required this.apiCache,
    required this.savedStories,
    required this.settings,
  });

  /// Raw JSON responses, keyed by request path.
  final KeyValueStore apiCache;

  /// Bookmarked stories (full detail JSON), keyed by story id.
  final KeyValueStore savedStories;

  /// User preferences.
  final KeyValueStore settings;

  factory AppStores.inMemory() => AppStores(
    apiCache: MemoryKeyValueStore(),
    savedStories: MemoryKeyValueStore(),
    settings: MemoryKeyValueStore(),
  );
}
