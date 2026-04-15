abstract class CacheStore {
  T? get<T>(String key);
  void put<T>(String key, T value);
  bool contains(String key);
  void remove(String key);
  void clear();
}
