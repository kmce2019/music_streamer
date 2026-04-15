import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/logging/logger.dart';
import '../../core/models/media_models.dart';
import '../../core/persistence/in_memory_db.dart';

class ImportSummary {
  const ImportSummary({
    required this.filesScanned,
    required this.tracksImported,
    required this.albumsCreated,
    required this.artistsCreated,
  });

  final int filesScanned;
  final int tracksImported;
  final int albumsCreated;
  final int artistsCreated;
}

class LocalImportService {
  LocalImportService(this._db, this._logger);

  final InMemoryDb _db;
  final AppLogger _logger;

  static const _supportedExtensions = ['.mp3', '.m4a', '.flac', '.wav', '.ogg'];

  Future<ImportSummary> importFromFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      return const ImportSummary(filesScanned: 0, tracksImported: 0, albumsCreated: 0, artistsCreated: 0);
    }
  Future<int> importFromFolder(String folderPath) async {
    final dir = Directory(folderPath);
    if (!await dir.exists()) return 0;

    final files = await dir
        .list(recursive: true)
        .where((e) => e is File)
        .cast<File>()
        .where((f) => _supportedExtensions.contains(p.extension(f.path).toLowerCase()))
        .toList();

    var tracksImported = 0;
    var albumsCreated = 0;
    var artistsCreated = 0;

    for (final file in files) {
      final metadata = _extractMetadata(file.path);
      final artistId = _idFor('artist', metadata.artist);
      final albumId = _idFor('album', '${metadata.artist}::${metadata.album}');
      final trackId = _idFor('track', file.path);

      if (_db.artists.where((e) => e.id == artistId).isEmpty) {
        _db.artists.add(Artist(id: artistId, name: metadata.artist));
        artistsCreated += 1;
      }
      if (_db.albums.where((e) => e.id == albumId).isEmpty) {
        _db.albums.add(Album(id: albumId, title: metadata.album, artistId: artistId));
        albumsCreated += 1;
      }

      if (_db.tracks.any((e) => e.id == trackId)) continue;
      _db.tracks.add(Track(
        id: trackId,
        title: metadata.title,
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
      tracksImported += 1;
    }

    _logger.info(
      'Import complete. scanned=${files.length} tracksImported=$tracksImported albumsCreated=$albumsCreated artistsCreated=$artistsCreated',
    );

    return ImportSummary(
      filesScanned: files.length,
      tracksImported: tracksImported,
      albumsCreated: albumsCreated,
      artistsCreated: artistsCreated,
    );
  }

  String _idFor(String prefix, String value) => '$prefix-${value.toLowerCase().hashCode.abs()}';

  _ParsedMetadata _extractMetadata(String path) {
    final titleRaw = p.basenameWithoutExtension(path);
    final album = p.basename(p.dirname(path));

    if (titleRaw.contains(' - ')) {
      final parts = titleRaw.split(' - ');
      final artist = parts.first.trim();
      final title = parts.skip(1).join(' - ').trim();
      return _ParsedMetadata(
        artist: artist.isEmpty ? 'Unknown Artist' : artist,
        album: album.isEmpty ? 'Unknown Album' : album,
        title: title.isEmpty ? titleRaw : title,
      );
    }

    return _ParsedMetadata(
      artist: 'Unknown Artist',
      album: album.isEmpty ? 'Unknown Album' : album,
      title: titleRaw,
    );
  }
}

class _ParsedMetadata {
  const _ParsedMetadata({required this.artist, required this.album, required this.title});

  final String artist;
  final String album;
  final String title;
}
    }

    _logger.info('Imported ${files.length} files from $folderPath');
    return files.length;
  }
}
