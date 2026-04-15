import 'dart:convert';

import '../../core/persistence/in_memory_db.dart';

class JsonExportService {
  JsonExportService(this._db);

  final InMemoryDb _db;

  String exportLibrary() {
    return jsonEncode({
      'tracks': _db.tracks
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'artistId': t.artistId,
                'albumId': t.albumId,
                'durationMs': t.durationMs,
                'source': t.source,
              })
          .toList(),
      'albums': _db.albums.map((a) => {'id': a.id, 'title': a.title, 'artistId': a.artistId}).toList(),
      'artists': _db.artists.map((a) => {'id': a.id, 'name': a.name}).toList(),
    });
  }
}
