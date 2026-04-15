import 'package:rxdart/rxdart.dart';

sealed class AppEvent {}

class ErrorEvent extends AppEvent {
  ErrorEvent(this.message);
  final String message;
}

class PlaybackEvent extends AppEvent {
  PlaybackEvent(this.action);
  final String action;
}

class AppEventBus {
  final _subject = PublishSubject<AppEvent>();

  Stream<AppEvent> get stream => _subject.stream;
  void publish(AppEvent event) => _subject.add(event);
  Future<void> dispose() => _subject.close();
}
