import '../../core/models/media_models.dart';

class LibrarySearchService {
  List<Track> searchTracks(List<Track> tracks, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return tracks;
    return tracks.where((t) => t.title.toLowerCase().contains(q)).toList();
  }
}
