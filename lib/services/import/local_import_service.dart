import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/logging/logger.dart';
import '../../core/models/media_models.dart';
import '../../core/persistence/in_memory_db.dart';

class LocalImportService {
  LocalImportService(this._db, this._logger);

  final InMemoryDb _db;
  final AppLogger _logger;

  Future<int> importFromFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) return 0;

    final files = await dir
        .list(recursive: true)
        .where((e) => e is File)
        .cast<File>()
        .where((f) => const ['.mp3', '.m4a', '.flac', '.wav', '.ogg'].contains(p.extension(f.path).toLowerCase()))
        .toList();

    for (final file in files) {
      final id = file.path.hashCode.toString();
      final artistId = 'local-artist';
      final albumId = 'local-album';

      if (_db.artists.where((e) => e.id == artistId).isEmpty) {
        _db.artists.add(const Artist(id: 'local-artist', name: 'Local Artist'));
      }
      if (_db.albums.where((e) => e.id == albumId).isEmpty) {
        _db.albums.add(const Album(id: 'local-album', title: 'Local Collection', artistId: 'local-artist'));
      }

      if (_db.tracks.any((e) => e.id == id)) continue;
      _db.tracks.add(Track(
        id: id,
        title: p.basenameWithoutExtension(file.path),
        artistId: artistId,
        albumId: albumId,
        durationMs: 0,
        source: file.path,
      ));
    }

    _logger.info('Imported ${files.length} files from $folderPath');
    return files.length;
  }
}
