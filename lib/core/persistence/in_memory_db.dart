import '../models/media_models.dart';

class InMemoryDb {

  final List<Track> tracks = [];
  final List<Album> albums = [];
  final List<Artist> artists = [];
  final List<Playlist> playlists = [];
  final List<RecentHistoryItem> history = [];
  final Map<String, dynamic> settings = {'themeMode': 'system'};
  final Map<String, Map<String, dynamic>> pluginSettings = {};
  final List<Map<String, dynamic>> pluginManifests = [];

  void seedDemoData() {
    if (tracks.isNotEmpty) return;

    artists.add(const Artist(id: 'artist-1', name: 'Demo Artist'));
    albums.add(const Album(id: 'album-1', title: 'Demo Album', artistId: 'artist-1'));
    tracks.add(
      const Track(
        id: 'track-1',
        title: 'Demo Track',
        artistId: 'artist-1',
        albumId: 'album-1',
        durationMs: 180000,
        source: 'https://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      ),
    );
  }
}
