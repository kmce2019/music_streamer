import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/models/media_models.dart';
import '../../repository/playlist_repository.dart';

class PlaylistState extends Equatable {
  const PlaylistState({this.playlists = const []});

  final List<Playlist> playlists;

  PlaylistState copyWith({List<Playlist>? playlists}) => PlaylistState(playlists: playlists ?? this.playlists);

  @override
  List<Object?> get props => [playlists];
}

class PlaylistCubit extends Cubit<PlaylistState> {
  PlaylistCubit(this._repository) : super(const PlaylistState());

  final PlaylistRepository _repository;

  Future<void> loadPlaylists() async => emit(state.copyWith(playlists: _repository.getAll()));

  Future<void> create(String name) async {
    await _repository.create(name);
    await loadPlaylists();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await loadPlaylists();
  }
}
