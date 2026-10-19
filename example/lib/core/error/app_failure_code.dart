import 'package:aws_location_service_features/aws_location_service_features.dart';

/// Failures this app raises itself, on top of the plugin's [FailureCode]s.
/// Translated by `localizedMessage` like the plugin's codes.
enum AppFailureCode implements ErrorCode {
  settingsNotSaved,
  appLanguageNotSaved,
  cloudTrackerSettingsNotSaved,
  snapNoRoute,
  trackerPickTripEnds,
  trackerNoRoute,
}
