import '../core/models/media_models.dart';
import '../core/persistence/in_memory_db.dart';

class PlaylistRepository {
  PlaylistRepository(this._db);

  final InMemoryDb _db;

  List<Playlist> getAll() => List.unmodifiable(_db.playlists);

  Future<void> create(String name) async {
    _db.playlists.add(
      Playlist(
        id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        trackIds: const [],
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> delete(String id) async {
    _db.playlists.removeWhere((p) => p.id == id);
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    final i = _db.playlists.indexWhere((p) => p.id == playlistId);
    if (i < 0) return;
    final playlist = _db.playlists[i];
    if (playlist.trackIds.contains(trackId)) return;
    _db.playlists[i] = playlist.copyWith(trackIds: [...playlist.trackIds, trackId]);
  }
}
