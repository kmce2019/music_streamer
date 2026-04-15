import 'package:just_audio/just_audio.dart';

import '../core/models/media_models.dart';
import '../services/audio/audio_player_service.dart';

class PlaybackRepository {
  PlaybackRepository(this._service);
  final AudioPlayerService _service;

  Stream<PlayerState> get playerStateStream => _service.playerState;
  Stream<Duration> get positionStream => _service.position;
  Stream<int?> get currentIndexStream => _service.currentIndex;
  Stream<Duration?> get durationStream => _service.duration;

  Future<AudioPlayerSnapshot> snapshot() => _service.snapshot();

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) => _service.setQueue(tracks, startIndex: startIndex);
  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();
  Future<void> seek(Duration position) => _service.seek(position);
  Future<void> next() => _service.next();
  Future<void> previous() => _service.previous();
  Future<void> setShuffle(bool enabled) => _service.setShuffle(enabled);
  Future<void> setRepeat(RepeatMode mode) => _service.setRepeat(mode);
  Future<void> setVolume(double volume) => _service.setVolume(volume);
  Future<void> dispose() => _service.dispose();
}
