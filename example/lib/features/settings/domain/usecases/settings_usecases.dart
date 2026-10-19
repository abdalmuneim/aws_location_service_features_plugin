import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettings implements UseCase<AppSettings, NoParams> {
  const LoadSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<AppSettings>> call(NoParams params) => _repository.load();
}

class SaveSettings implements UseCase<AppSettings, AppSettings> {
  const SaveSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<AppSettings>> call(AppSettings params) =>
      _repository.save(params);
}

/// The saved UI language code, or null to follow the device.
class LoadAppLocale implements UseCase<String?, NoParams> {
  const LoadAppLocale(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<String?>> call(NoParams params) => _repository.loadLocale();
}

/// Persists the UI language code; null follows the device.
class SaveAppLocale implements UseCase<String?, String?> {
  const SaveAppLocale(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<String?>> call(String? params) =>
      _repository.saveLocale(params);
}
