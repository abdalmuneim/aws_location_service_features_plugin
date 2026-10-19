import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../../../../core/config/aws_config.dart';
import '../../domain/repositories/cloud_tracker_settings_repository.dart';
import '../datasources/cloud_tracker_settings_local_data_source.dart';

class CloudTrackerSettingsRepositoryImpl
    implements CloudTrackerSettingsRepository {
  const CloudTrackerSettingsRepositoryImpl(this._local);

  final CloudTrackerSettingsLocalDataSource _local;

  static const defaults = CloudTrackerConfig(
    identityPoolId: AwsConfig.defaultIdentityPoolId,
    trackerName: AwsConfig.defaultTrackerName,
  );

  @override
  Future<Result<CloudTrackerConfig>> load() => guard(() async {
    final json = await _local.read();
    return json == null ? defaults : fromJson(json);
  });

  @override
  Future<Result<CloudTrackerConfig>> save(CloudTrackerConfig config) =>
      guard(() async {
        await _local.write(toJson(config));
        return config;
      });

  static Map<String, Object?> toJson(CloudTrackerConfig c) => {
    'identityPoolId': c.identityPoolId,
    'trackerName': c.trackerName,
    'timeFilterSeconds': c.minTimeBetweenUploads?.inSeconds,
    'distanceMeters': c.minDistanceMeters,
    'accuracyFilter': c.accuracyFilter,
  };

  static CloudTrackerConfig fromJson(Map<String, dynamic> json) {
    final seconds = json['timeFilterSeconds'];
    final meters = json['distanceMeters'];
    return CloudTrackerConfig(
      identityPoolId:
          json['identityPoolId'] as String? ?? defaults.identityPoolId,
      trackerName: json['trackerName'] as String? ?? defaults.trackerName,
      minTimeBetweenUploads: seconds is num
          ? Duration(seconds: seconds.toInt())
          : null,
      minDistanceMeters: meters is num ? meters.toDouble() : null,
      accuracyFilter: json['accuracyFilter'] as bool? ?? false,
    );
  }
}
