import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_streamer/blocs/library/library_cubit.dart';
import 'package:music_streamer/blocs/playback/playback_cubit.dart';
import 'package:music_streamer/core/events/app_event_bus.dart';
import 'package:music_streamer/core/logging/logger.dart';
import 'package:music_streamer/core/persistence/in_memory_db.dart';
import 'package:music_streamer/repository/library_repository.dart';
import 'package:music_streamer/repository/playback_repository.dart';
import 'package:music_streamer/screens/library/library_screen.dart';
import 'package:music_streamer/services/audio/audio_player_service.dart';
import 'package:music_streamer/services/import/local_import_service.dart';
import 'package:music_streamer/services/persistence/json_export_service.dart';
import 'package:music_streamer/services/search/library_search_service.dart';

void main() {
  testWidgets('library screen renders empty state before load', (tester) async {
    final db = InMemoryDb();
    final libraryRepo = LibraryRepository(
      db: db,
      importer: LocalImportService(db, AppLogger()),
      searchService: LibrarySearchService(),
      exportService: JsonExportService(db),
    );
    final libraryCubit = LibraryCubit(libraryRepo, AppEventBus());
    final playbackCubit = PlaybackCubit(PlaybackRepository(AudioPlayerService(AppEventBus())), AppEventBus());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: libraryCubit),
          BlocProvider.value(value: playbackCubit),
        ],
        child: const MaterialApp(home: LibraryScreen()),
      ),
    );

    expect(find.textContaining('No tracks imported'), findsOneWidget);
  });
}
