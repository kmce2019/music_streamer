import 'package:flutter_test/flutter_test.dart';
import 'package:music_streamer/core/logging/logger.dart';
import 'package:music_streamer/core/persistence/in_memory_db.dart';
import 'package:music_streamer/repository/library_repository.dart';
import 'package:music_streamer/services/import/local_import_service.dart';
import 'package:music_streamer/services/persistence/json_export_service.dart';
import 'package:music_streamer/services/search/library_search_service.dart';

void main() {
  test('seedDemoData populates initial tracks', () {
    final db = InMemoryDb();
    final repo = LibraryRepository(
      db: db,
      importer: LocalImportService(db, AppLogger()),
      searchService: LibrarySearchService(),
      exportService: JsonExportService(db),
    );

    repo.seedDemoData();

    expect(repo.getTracks(), isNotEmpty);
    expect(repo.search('demo').length, 1);
  });
}
