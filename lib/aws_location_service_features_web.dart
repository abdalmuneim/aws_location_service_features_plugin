import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/features/tracking/data/datasources/dart_cloud_tracker.dart';
import 'src/platform/aws_location_platform.dart';

/// Web implementation of [AwsLocationPlatform]: cloud tracking in Dart
/// (Cognito + SigV4 + browser geolocation), since AWS ships no tracking SDK
/// for the browser. Maps, Places and Routes are plain HTTPS on every
/// platform and need nothing here.
class AwsLocationWeb extends DartCloudTracker {
  AwsLocationWeb();

  static void registerWith(Registrar registrar) {
    AwsLocationPlatform.instance = AwsLocationWeb();
  }
}
