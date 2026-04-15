import 'package:just_audio/just_audio.dart';

import '../../core/events/app_event_bus.dart';
import '../../core/models/media_models.dart';

class AudioPlayerSnapshot {
  const AudioPlayerSnapshot({
    required this.isPlaying,
    required this.position,
    required this.currentIndex,
    required this.duration,
  });

  final bool isPlaying;
  final Duration position;
  final int currentIndex;
  final Duration duration;
}

class AudioPlayerService {
  AudioPlayerService(this._eventBus);

  final _player = AudioPlayer();
  final AppEventBus _eventBus;
  final List<Track> _queue = [];
  int _index = 0;

  Stream<PlayerState> get playerState => _player.playerStateStream;
  Stream<Duration> get position => _player.positionStream;
  Stream<int?> get currentIndex => _player.currentIndexStream;
  Stream<Duration?> get duration => _player.durationStream;

  List<Track> get queue => List.unmodifiable(_queue);
  int get currentIndexValue => _index;

  Future<void> setQueue(List<Track> tracks, {int startIndex = 0}) async {
    _queue
      ..clear()
      ..addAll(tracks);
    _index = startIndex;
    final sources = tracks.map((t) => AudioSource.uri(_toPlayableUri(t.source))).toList();
    await _player.setAudioSource(ConcatenatingAudioSource(children: sources), initialIndex: startIndex);
  }

  Uri _toPlayableUri(String source) {
    final parsed = Uri.tryParse(source);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }
    return Uri.file(source);
  }

  Future<void> play() async {
    await _player.play();
    _eventBus.publish(PlaybackEvent('play'));
  }

  Future<void> pause() async {
    await _player.pause();
    _eventBus.publish(PlaybackEvent('pause'));
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> next() async {
    await _player.seekToNext();
    _index = _player.currentIndex ?? _index;
  }

  Future<void> previous() async {
    await _player.seekToPrevious();
    _index = _player.currentIndex ?? _index;
  }

  Future<void> setShuffle(bool enabled) => _player.setShuffleModeEnabled(enabled);

  Future<void> setRepeat(RepeatMode mode) => _player.setLoopMode(
        switch (mode) {
          RepeatMode.off => LoopMode.off,
          RepeatMode.one => LoopMode.one,
          RepeatMode.all => LoopMode.all,
        },
      );

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<AudioPlayerSnapshot> snapshot() async {
    return AudioPlayerSnapshot(
      isPlaying: _player.playing,
      position: _player.position,
      currentIndex: _player.currentIndex ?? _index,
      duration: _player.duration ?? Duration.zero,
    );
  }

  Future<void> dispose() => _player.dispose();
}
