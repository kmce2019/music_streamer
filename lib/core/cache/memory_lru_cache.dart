import 'dart:collection';

import 'cache_store.dart';

class MemoryLruCache implements CacheStore {
  MemoryLruCache({required this.maxEntries});

  final int maxEntries;
  final LinkedHashMap<String, Object?> _cache = LinkedHashMap();

  @override
  T? get<T>(String key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value as T?;
  }

  @override
  void put<T>(String key, T value) {
    _cache.remove(key);
    _cache[key] = value;
    if (_cache.length > maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  @override
  bool contains(String key) => _cache.containsKey(key);

  @override
  void remove(String key) => _cache.remove(key);

  @override
  void clear() => _cache.clear();
}
