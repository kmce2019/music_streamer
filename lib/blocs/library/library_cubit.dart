import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/events/app_event_bus.dart';
import '../../core/models/media_models.dart';
import '../../repository/library_repository.dart';

class LibraryState extends Equatable {
  const LibraryState({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
    this.history = const [],
    this.loading = false,
    this.lastImportMessage,
    this.error,
  });

  final List<Track> tracks;
  final List<Album> albums;
  final List<Artist> artists;
  final List<RecentHistoryItem> history;
  final bool loading;
  final String? lastImportMessage;
  final String? error;

  LibraryState copyWith({
    List<Track>? tracks,
    List<Album>? albums,
    List<Artist>? artists,
    List<RecentHistoryItem>? history,
    bool? loading,
    String? lastImportMessage,
    String? error,
  }) =>
      LibraryState(
        tracks: tracks ?? this.tracks,
        albums: albums ?? this.albums,
        artists: artists ?? this.artists,
        history: history ?? this.history,
        loading: loading ?? this.loading,
        lastImportMessage: lastImportMessage ?? this.lastImportMessage,
        error: error,
      );

  @override
  List<Object?> get props => [tracks, albums, artists, history, loading, lastImportMessage, error];
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(this._repository, this._eventBus) : super(const LibraryState());

  final LibraryRepository _repository;
  final AppEventBus _eventBus;

  Future<void> loadLibrary() async {
    emit(state.copyWith(loading: true, error: null));
    _repository.seedDemoData();
    emit(
      state.copyWith(
        tracks: _repository.getTracks(),
        albums: _repository.getAlbums(),
        artists: _repository.getArtists(),
        history: _repository.getHistory(),
        loading: false,
      ),
    );
  }

  Future<void> importFolder() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final summary = await _repository.importLocalFolder();
      await loadLibrary();
      emit(
        state.copyWith(
          lastImportMessage:
              'Scanned ${summary.filesScanned}, imported ${summary.tracksImported} tracks (${summary.artistsCreated} artists, ${summary.albumsCreated} albums).',
        ),
      );
    } catch (e) {
      _eventBus.publish(ErrorEvent('Failed to import local files: $e'));
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> toggleFavorite(String trackId) async {
    await _repository.toggleFavorite(trackId);
    emit(state.copyWith(tracks: _repository.getTracks()));
  }

  String exportAsJson() => _repository.exportJson();
}
