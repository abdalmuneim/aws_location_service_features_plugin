import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local, this._runtime);

  final SettingsLocalDataSource _local;
  final AwsLocationConfig _runtime;

  @override
  Future<Result<AppSettings>> load() => guard(() async {
    final json = await _local.read();
    final defaults = AppSettings.defaults();
    final settings = json == null
        ? defaults
        : AppSettingsModel.fromJson(json, defaults);
    _apply(settings);
    return settings;
  });

  @override
  Future<Result<AppSettings>> save(AppSettings settings) => guard(() async {
    _apply(settings);
    await _local.write(AppSettingsModel.toJson(settings));
    return settings;
  });

  @override
  Future<Result<String?>> loadLocale() => guard(_local.readLocale);

  @override
  Future<Result<String?>> saveLocale(String? languageCode) => guard(() async {
    await _local.writeLocale(languageCode);
    return languageCode;
  });

  void _apply(AppSettings s) {
    _runtime
      ..apiKey = s.apiKey
      ..region = s.region
      ..language = s.language
      ..politicalView = s.politicalView;
  }
}
