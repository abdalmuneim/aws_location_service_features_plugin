import 'package:aws_location_service_features/aws_location_service_features.dart';

abstract interface class CloudTrackerSettingsRepository {
  /// Saved settings, or the build-time defaults.
  Future<Result<CloudTrackerConfig>> load();

  Future<Result<CloudTrackerConfig>> save(CloudTrackerConfig config);
}
