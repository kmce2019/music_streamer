
import 'package:just_audio/just_audio.dart';

import '../../core/events/app_event_bus.dart';
import '../../core/models/media_models.dart';

class AudioPlayerService {
  AudioPlayerService(this._eventBus);

  final _player = AudioPlayer();
  final AppEventBus _eventBus;
  final List<Track> _queue = [];
  int _index = 0;

  Stream<PlayerState> get playerState => _player.playerStateStream;
  Stream<Duration> get position => _player.positionStream;

  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndex => _index;

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue
      ..clear()
      ..addAll(tracks);
    _index = startIndex;

  Future<void> play() async {
    await _player.play();
    _eventBus.publish(PlaybackEvent('play'));
  }

  Future<void> pause() async {
    await _player.pause();
    _eventBus.publish(PlaybackEvent('pause'));
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> setShuffle(bool enabled) => _player.setShuffleModeEnabled(enabled);

  Future<void> setRepeat(RepeatMode mode) => _player.setLoopMode(
        switch (mode) {
          RepeatMode.off => LoopMode.off,
          RepeatMode.one => LoopMode.one,
          RepeatMode.all => LoopMode.all,
        },
      );

  Future<void> setVolume(double volume) => _player.setVolume(volume);
}
