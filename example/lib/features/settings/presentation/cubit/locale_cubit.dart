import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/settings_usecases.dart';

/// The UI language. `null` follows the device (see `AppLocales.resolve`).
///
/// Provided above [MaterialApp], so a change re-renders every screen at once
/// without restarting the app.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._save, super.initial);

  final SaveAppLocale _save;

  Future<void> setLocale(Locale? locale) async {
    if (locale == state) return;
    // Applied before saving, so the change shows instantly and still holds
    // for this session if persisting fails.
    emit(locale);
    await _save(locale?.languageCode);
  }
}
