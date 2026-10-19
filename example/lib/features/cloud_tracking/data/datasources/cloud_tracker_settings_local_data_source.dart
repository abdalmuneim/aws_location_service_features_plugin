import 'dart:convert';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/app_failure_code.dart';

abstract interface class CloudTrackerSettingsLocalDataSource {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, Object?> json);
}

/// Cloud tracker settings in shared preferences, under their own key so the
/// app settings schema stays as it is.
class CloudTrackerSettingsLocalDataSourceImpl
    implements CloudTrackerSettingsLocalDataSource {
  const CloudTrackerSettingsLocalDataSourceImpl(this._prefs);

  static const _key = 'cloud_tracker_v1';

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
    if (!await _prefs.setString(_key, jsonEncode(json))) {
      throw const CacheException(
        'Could not save the cloud tracker settings.',
        code: AppFailureCode.cloudTrackerSettingsNotSaved,
      );
    }
  }
}
