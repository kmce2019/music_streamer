import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/events/app_event_bus.dart';
import '../../core/models/media_models.dart';
import '../../repository/playback_repository.dart';

class PlaybackState extends Equatable {
  const PlaybackState({
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1,
  });

  final List<Track> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final bool shuffle;
  final RepeatMode repeatMode;
  final double volume;

  Track? get currentTrack => queue.isEmpty ? null : queue[currentIndex.clamp(0, queue.length - 1)];

  PlaybackState copyWith({
    List<Track>? queue,
    int? currentIndex,
    bool? isPlaying,
    Duration? position,
    bool? shuffle,
    RepeatMode? repeatMode,
    double? volume,
  }) =>
      PlaybackState(
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        shuffle: shuffle ?? this.shuffle,
        repeatMode: repeatMode ?? this.repeatMode,
        volume: volume ?? this.volume,
      );

  @override
  List<Object?> get props => [queue, currentIndex, isPlaying, position, shuffle, repeatMode, volume];
}

class PlaybackCubit extends Cubit<PlaybackState> {
  PlaybackCubit(this._repository, this._eventBus) : super(const PlaybackState());

  final PlaybackRepository _repository;
  final AppEventBus _eventBus;

  Future<void> loadQueue(List<Track> tracks, {int startIndex = 0}) async {
    await _repository.setQueue(tracks, startIndex: startIndex);
    emit(state.copyWith(queue: tracks, currentIndex: startIndex));
  }

  Future<void> play() async {
    await _repository.play();
    _eventBus.publish(PlaybackEvent('play'));
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> pause() async {
    await _repository.pause();
    _eventBus.publish(PlaybackEvent('pause'));
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    await _repository.next();
    emit(state.copyWith(currentIndex: (state.currentIndex + 1).clamp(0, state.queue.length - 1)));
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;
    await _repository.previous();
    emit(state.copyWith(currentIndex: (state.currentIndex - 1).clamp(0, state.queue.length - 1)));
  }

  Future<void> seek(Duration position) async {
    await _repository.seek(position);
    emit(state.copyWith(position: position));
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffle;
    await _repository.setShuffle(enabled);
    emit(state.copyWith(shuffle: enabled));
  }

  Future<void> cycleRepeatMode() async {
    final mode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await _repository.setRepeat(mode);
    emit(state.copyWith(repeatMode: mode));
  }

  Future<void> setVolume(double volume) async {
    await _repository.setVolume(volume);
    emit(state.copyWith(volume: volume));
  }
}
