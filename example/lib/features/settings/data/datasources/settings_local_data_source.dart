import 'dart:convert';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/app_failure_code.dart';

abstract interface class SettingsLocalDataSource {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, Object?> json);

  /// UI language code, or null to follow the device.
  Future<String?> readLocale();

  Future<void> writeLocale(String? languageCode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl(this._prefs);

  static const _key = 'app_settings_v1';

  /// Kept apart from [_key] so "Reset to defaults" leaves the language alone.
  static const _localeKey = 'app_locale_v1';

  final SharedPreferences _prefs;

  @override
  Future<Map<String, dynamic>?> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(Map<String, Object?> json) async {
    final ok = await _prefs.setString(_key, jsonEncode(json));
    if (!ok) {
      throw const CacheException(
        'Could not save settings.',
        code: AppFailureCode.settingsNotSaved,
      );
    }
  }

  @override
  Future<String?> readLocale() async => _prefs.getString(_localeKey);

  @override
  Future<void> writeLocale(String? languageCode) async {
    final ok = languageCode == null
        ? await _prefs.remove(_localeKey)
        : await _prefs.setString(_localeKey, languageCode);
    if (!ok) {
      throw const CacheException(
        'Could not save the app language.',
        code: AppFailureCode.appLanguageNotSaved,
      );
    }
  }
}
