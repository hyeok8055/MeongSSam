import 'dart:developer' as developer;

class AppLogger {
  const AppLogger();

  void info(String message) {
    developer.log(message, name: 'MeongSSam');
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'MeongSSam',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
