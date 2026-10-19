import 'package:aws_location_service_features/aws_location_service_features.dart';

/// Static defaults for the Amazon Location Service connection.
///
/// The API key and region can be overridden at build time:
/// `flutter run --dart-define=AWS_LOCATION_API_KEY=... --dart-define=AWS_LOCATION_REGION=...`
/// and at runtime from the Settings screen.
abstract final class AwsConfig {
  static const String defaultApiKey = String.fromEnvironment(
    'AWS_LOCATION_API_KEY',
    defaultValue: 'v1.public.eyJqdGkiOiJlYTcwNGM2My1jYzhiLTQ3MTctYmFhZi03ZTYzYmZkOTUzZmYifaHLpmEIevY48gog3Qwmhb9gZJxVdVhcMfv27BnYjWAt4aB7gqlFCMutLW9-ActYbgllsDVLhRY_1OaYdNyADFLCLLduXFFZzPBawKpS6jJ0JQtUFufJNssY0fQ2hcpbHxGM76IhJVfMeiWD_qy8265ybBfY_D_wRCHDGt-SISi4NIKztFulLU_wPbayiRoJI7wuAS9JBgOg3yhyw-cvl646jQTVikVY6CKYrvPfDSn7_hpaO6Hd2VIVwFXw0ACdn4FsrsJ_wR7NyYeMAndQh16GwOkG4onEtL9V2fTMREGkDjphVZoaYX5pkuczkXL2OOIrM4Y5Ng-I2JwUMS1gzXk.N2IyNTQ2ODQtOWE1YS00MmI2LTkyOTItMGJlNGMxODU1Mzc2',
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
