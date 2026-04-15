import 'package:file_picker/file_picker.dart';

import '../core/models/media_models.dart';
import '../core/persistence/in_memory_db.dart';
import '../services/import/local_import_service.dart';
import '../services/persistence/json_export_service.dart';
import '../services/search/library_search_service.dart';

class LibraryRepository {
  LibraryRepository({
    required InMemoryDb db,
    required LocalImportService importer,
    required LibrarySearchService searchService,
    required JsonExportService exportService,
  })  : _db = db,
        _importer = importer,
        _searchService = searchService,
        _exportService = exportService;

  final InMemoryDb _db;
  final LocalImportService _importer;
  final LibrarySearchService _searchService;
  final JsonExportService _exportService;

  List<Track> getTracks() => List.unmodifiable(_db.tracks);
  List<Album> getAlbums() => List.unmodifiable(_db.albums);
  List<Artist> getArtists() => List.unmodifiable(_db.artists);
  List<RecentHistoryItem> getHistory() => List.unmodifiable(_db.history);

  Future<int> importLocalFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose music folder');
    if (path == null) return 0;
    return _importer.importFromFolder(path);
  }

  void seedDemoData() => _db.seedDemoData();

  List<Track> search(String query) => _searchService.searchTracks(_db.tracks, query);

  Future<void> toggleFavorite(String trackId) async {
    final i = _db.tracks.indexWhere((t) => t.id == trackId);
    if (i == -1) return;
    _db.tracks[i] = _db.tracks[i].copyWith(isFavorite: !_db.tracks[i].isFavorite);
  }

  Future<void> addHistory(String trackId) async {
    _db.history.insert(0, RecentHistoryItem(trackId: trackId, playedAt: DateTime.now()));
    if (_db.history.length > 100) _db.history.removeLast();
  }

  String exportJson() => _exportService.exportLibrary();
}
