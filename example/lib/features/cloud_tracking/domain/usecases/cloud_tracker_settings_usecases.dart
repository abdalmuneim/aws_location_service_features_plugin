import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../repositories/cloud_tracker_settings_repository.dart';

class LoadCloudTrackerSettings
    implements UseCase<CloudTrackerConfig, NoParams> {
  const LoadCloudTrackerSettings(this._repository);

  final CloudTrackerSettingsRepository _repository;

  @override
  Future<Result<CloudTrackerConfig>> call(NoParams params) =>
      _repository.load();
}

class SaveCloudTrackerSettings
    implements UseCase<CloudTrackerConfig, CloudTrackerConfig> {
  const SaveCloudTrackerSettings(this._repository);

  final CloudTrackerSettingsRepository _repository;

  @override
  Future<Result<CloudTrackerConfig>> call(CloudTrackerConfig params) =>
      _repository.save(params);
}
