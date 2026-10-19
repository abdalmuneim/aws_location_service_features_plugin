import 'package:flutter/widgets.dart';

/// The UI languages the app ships with.
abstract final class AppLocales {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  static const List<Locale> supported = [english, arabic];

  /// The device's preferred language when the app supports it, English
  /// otherwise. Only the first preference counts, so a French device with
  /// Arabic as a fallback still gets English.
  static Locale resolve(List<Locale>? preferred) {
    final code = preferred?.firstOrNull?.languageCode;
    return supported.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => english,
    );
  }
}
