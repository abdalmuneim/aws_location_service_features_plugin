import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  /// Loads saved settings (defaults when nothing is saved) and applies them
  /// to the active connection.
  Future<Result<AppSettings>> load();

  /// Persists [settings] and applies them to the active connection.
  Future<Result<AppSettings>> save(AppSettings settings);

  /// The saved UI language code, or null to follow the device language.
  Future<Result<String?>> loadLocale();

  /// Persists the UI language code; null follows the device language.
  Future<Result<String?>> saveLocale(String? languageCode);
}
