import 'dart:ui' show Locale;

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features_example/core/l10n/l10n.dart';
import 'package:aws_location_service_features_example/core/utils/formatters.dart';
import 'package:aws_location_service_features_example/features/cloud_tracking/data/repositories/cloud_tracker_settings_repository_impl.dart';
import 'package:aws_location_service_features_example/features/settings/data/models/app_settings_model.dart';
import 'package:aws_location_service_features_example/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings JSON round trip', () {
    final s = AppSettings.defaults().copyWith(
      politicalView: 'EGY',
      language: 'ar',
      mapStyle: const MapStyleOptions(
        style: MapStyle.monochrome,
        colorScheme: MapColorScheme.dark,
        traffic: true,
      ),
    );
    expect(
      AppSettingsModel.fromJson(
        AppSettingsModel.toJson(s).cast<String, dynamic>(),
        AppSettings.defaults(),
      ),
      s,
    );
  });

  test('cloud tracker settings JSON round trip', () {
    const config = CloudTrackerConfig(
      identityPoolId: 'eu-north-1:00000000-0000-0000-0000-000000000000',
      trackerName: 'studio',
      minTimeBetweenUploads: Duration(seconds: 45),
      minDistanceMeters: null,
      accuracyFilter: true,
    );
    final json = CloudTrackerSettingsRepositoryImpl.toJson(config);
    expect(CloudTrackerSettingsRepositoryImpl.fromJson(json.cast()), config);
  });

  test('Formatters', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(Formatters.distance(en, 850), '850 m');
    expect(Formatters.distance(en, 12345), '12 km');
    expect(Formatters.duration(en, 3900), '1 h 5 min');
    expect(Formatters.humanize('PointOfInterest'), 'Point of interest');
  });
}
