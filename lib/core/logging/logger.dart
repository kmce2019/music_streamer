class AppLogger {
  void info(String message) => _log('INFO', message);
  void warning(String message) => _log('WARN', message);
  void error(String message) => _log('ERROR', message);

  void _log(String level, String message) {
    // Structured logging hook (can be redirected to Rust/native sink later).
    // ignore: avoid_print
    print('{"level":"$level","message":"$message"}');
  }
}
