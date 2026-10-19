import 'package:flutter/foundation.dart';

/// Provides logging that only runs in Flutter debug builds.
class Debuger {
  const Debuger._();

  static void log(Object? message, {String tag = 'Debuger'}) {
    if (kDebugMode) {
      debugPrint('$message');
    }
  }

  static void error(Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    debugPrint('$error');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
