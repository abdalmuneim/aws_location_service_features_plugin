import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../error/app_failure_code.dart';
import 'l10n.dart';

extension FailureMessage on Failure {
  /// [message] in the UI language. Failures the app raises itself are
  /// translated; messages that came from the API are shown as they are.
  String localizedMessage(AppLocalizations l10n) => switch (code) {
    final FailureCode code => _plugin(code, l10n),
    final AppFailureCode code => _app(code, l10n),
    _ => message,
  };

  /// Codes the plugin raises.
  String _plugin(FailureCode code, AppLocalizations l10n) {
    int max() => args['max']! as int;
    int status() => args['status']! as int;
    String detail() => '${args['detail']}';
    return switch (code) {
      FailureCode.requestTimedOut => l10n.errorRequestTimedOut,
      FailureCode.networkError => l10n.errorNetwork(detail()),
      FailureCode.httpStatus => l10n.errorHttpStatus(status()),
      FailureCode.apiKeyRejected => l10n.errorApiKeyRejected(
        status(),
        detail(),
      ),
      FailureCode.credentialsRejected => l10n.errorCredentialsRejected(
        status(),
        detail(),
      ),
      FailureCode.notFound => l10n.errorNotFound(detail()),
      FailureCode.tooManyRequests => l10n.errorTooManyRequests,
      FailureCode.locationServicesOff => l10n.errorLocationServicesOff,
      FailureCode.locationPermissionDenied =>
        l10n.errorLocationPermissionDenied,
      FailureCode.locationPermissionDeniedForever =>
        l10n.errorLocationPermissionDeniedForever,
      FailureCode.geofencesNotRead => l10n.errorGeofencesNotRead,
      FailureCode.geofencesNotSaved => l10n.errorGeofencesNotSaved,
      FailureCode.geocodeAddressRequired => l10n.errorGeocodeAddressRequired,
      FailureCode.searchQueryRequired => l10n.errorSearchQueryRequired,
      FailureCode.geofenceNameRequired => l10n.errorGeofenceNameRequired,
      FailureCode.geofencePolygonTooFewPoints =>
        l10n.errorGeofencePolygonTooFewPoints,
      FailureCode.geofenceRadiusNotPositive =>
        l10n.errorGeofenceRadiusNotPositive,
      FailureCode.isolineThresholdRequired =>
        l10n.errorIsolineThresholdRequired,
      FailureCode.isolineTooManyThresholds =>
        l10n.errorIsolineTooManyThresholds(max()),
      FailureCode.routeSameOriginAndDestination =>
        l10n.errorRouteSameOriginAndDestination,
      FailureCode.routeTooManyStops => l10n.errorRouteTooManyStops(max()),
      FailureCode.matrixPointsRequired => l10n.errorMatrixPointsRequired,
      FailureCode.matrixTooManyPoints => l10n.errorMatrixTooManyPoints(max()),
      FailureCode.optimizeStopsRequired => l10n.errorOptimizeStopsRequired,
      FailureCode.optimizeTooManyStops => l10n.errorOptimizeTooManyStops(max()),
      FailureCode.snapTooFewPoints => l10n.errorSnapTooFewPoints,
      FailureCode.snapTooManyPoints => l10n.errorSnapTooManyPoints(max()),
      FailureCode.trackerConfigIncomplete => l10n.errorTrackerConfigIncomplete,
      FailureCode.identityPoolIdInvalid => l10n.errorIdentityPoolIdInvalid,
      FailureCode.trackerNotConfigured => l10n.errorTrackerNotConfigured,
      FailureCode.backgroundTrackingUnsupported =>
        l10n.errorBackgroundTrackingUnsupported,
      FailureCode.cognitoSignInFailed => l10n.errorCognitoSignInFailed(
        detail(),
      ),
      FailureCode.trackingPlatformError => l10n.errorTrackingPlatform(detail()),
    };
  }

  /// Codes this app raises.
  String _app(AppFailureCode code, AppLocalizations l10n) => switch (code) {
    AppFailureCode.settingsNotSaved => l10n.errorSettingsNotSaved,
    AppFailureCode.appLanguageNotSaved => l10n.errorAppLanguageNotSaved,
    AppFailureCode.cloudTrackerSettingsNotSaved =>
      l10n.errorCloudTrackerSettingsNotSaved,
    AppFailureCode.snapNoRoute => l10n.errorSnapNoRoute,
    AppFailureCode.trackerPickTripEnds => l10n.errorTrackerPickTripEnds,
    AppFailureCode.trackerNoRoute => l10n.errorTrackerNoRoute,
  };
}
