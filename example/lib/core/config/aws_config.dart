import 'package:aws_location_service_features/aws_location_service_features.dart';

/// Static defaults for the Amazon Location Service connection.
///
/// No API key ships with the example. Pass yours at build time:
/// `flutter run --dart-define=AWS_LOCATION_API_KEY=... --dart-define=AWS_LOCATION_REGION=...`
/// or enter it on the Settings screen (saved on the device).
abstract final class AwsConfig {
  static const String defaultApiKey = String.fromEnvironment(
    'AWS_LOCATION_API_KEY',
  );

  static const String defaultRegion = String.fromEnvironment(
    'AWS_LOCATION_REGION',
    defaultValue: 'eu-north-1',
  );

  /// Lists offered in Settings; they come from the plugin.
  static const List<String> supportedRegions =
      AwsLocationConfig.supportedRegions;
  static const Map<String, String> languages = AwsLocationConfig.languages;
  static const Map<String, String> politicalViews =
      AwsLocationConfig.politicalViews;

  /// Cloud tracking defaults (Cognito identity pool and Amazon Location
  /// tracker). Trackers don't accept API keys. Override at build time with
  /// `--dart-define=AWS_COGNITO_IDENTITY_POOL_ID=...` and
  /// `--dart-define=AWS_TRACKER_NAME=...`, or enter them on the Cloud
  /// tracking screen.
  static const String defaultIdentityPoolId = String.fromEnvironment(
    'AWS_COGNITO_IDENTITY_POOL_ID',
  );
  static const String defaultTrackerName = String.fromEnvironment(
    'AWS_TRACKER_NAME',
  );

  /// Where maps open before the device location is known (Cairo).
  static const GeoPoint defaultCenter = GeoPoint(30.0444, 31.2357);
  static const double defaultZoom = 12;
}
