import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/aws_config.dart';
import 'features/cloud_tracking/data/datasources/cloud_tracker_settings_local_data_source.dart';
import 'features/cloud_tracking/data/repositories/cloud_tracker_settings_repository_impl.dart';
import 'features/cloud_tracking/domain/repositories/cloud_tracker_settings_repository.dart';
import 'features/cloud_tracking/domain/usecases/cloud_tracker_settings_usecases.dart';
import 'features/settings/data/datasources/settings_local_data_source.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/settings_usecases.dart';

/// Service locator. Composition root for every layer.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---- External
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<http.Client>(http.Client.new)
    // ---- The plugin. Settings keep the config in sync with the user's
    // preferences, so a new key, region or language applies at once.
    ..registerSingleton<AwsLocationConfig>(
      AwsLocationConfig(
        apiKey: AwsConfig.defaultApiKey,
        region: AwsConfig.defaultRegion,
      ),
    )
    ..registerLazySingleton<AwsLocation>(
      () => AwsLocation(config: sl(), httpClient: sl(), geofenceStorage: sl()),
    );

  _settings();
  _maps();
  _places();
  _routes();
  _geofencing();
  _tracking();
  _cloudTracking();
}

void _settings() {
  sl
    ..registerLazySingleton<SettingsLocalDataSource>(
      () => SettingsLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => LoadSettings(sl()))
    ..registerLazySingleton(() => SaveSettings(sl()))
    ..registerLazySingleton(() => LoadAppLocale(sl()))
    ..registerLazySingleton(() => SaveAppLocale(sl()));
}

void _maps() {
  sl
    ..registerLazySingleton<MapsRepository>(() => sl<AwsLocation>().maps)
    ..registerLazySingleton(() => GetMapStyleUrl(sl()))
    ..registerLazySingleton(() => GetStaticMap(sl()));
}

void _places() {
  sl
    ..registerLazySingleton<PlacesRepository>(() => sl<AwsLocation>().places)
    ..registerLazySingleton(() => Geocode(sl()))
    ..registerLazySingleton(() => ReverseGeocode(sl()))
    ..registerLazySingleton(() => AutocompletePlaces(sl()))
    ..registerLazySingleton(() => SuggestPlaces(sl()))
    ..registerLazySingleton(() => SearchText(sl()))
    ..registerLazySingleton(() => SearchNearby(sl()))
    ..registerLazySingleton(() => GetPlace(sl()));
}

void _routes() {
  sl
    ..registerLazySingleton<RoutesRepository>(() => sl<AwsLocation>().routes)
    ..registerLazySingleton(() => CalculateRoutes(sl()))
    ..registerLazySingleton(() => CalculateIsolines(sl()))
    ..registerLazySingleton(() => CalculateRouteMatrix(sl()))
    ..registerLazySingleton(() => OptimizeWaypoints(sl()))
    ..registerLazySingleton(() => SnapToRoads(sl()));
}

void _geofencing() {
  sl
    ..registerLazySingleton<GeofenceRepository>(
      () => sl<AwsLocation>().geofences,
    )
    ..registerLazySingleton(() => GetGeofences(sl()))
    ..registerLazySingleton(() => SaveGeofence(sl()))
    ..registerLazySingleton(() => DeleteGeofence(sl()))
    ..registerLazySingleton(() => ClearGeofences(sl()))
    ..registerLazySingleton(() => const EvaluateGeofences());
}

void _tracking() {
  sl
    ..registerLazySingleton<DeviceLocationRepository>(
      () => sl<AwsLocation>().deviceLocation,
    )
    ..registerLazySingleton(() => GetCurrentLocation(sl()))
    ..registerLazySingleton(() => WatchLocation(sl()))
    ..registerLazySingleton(() => SimulateTrip(sl()));
}

void _cloudTracking() {
  sl
    ..registerLazySingleton<CloudTrackingRepository>(
      () => sl<AwsLocation>().cloudTracking,
    )
    ..registerLazySingleton(() => ConfigureCloudTracker(sl()))
    ..registerLazySingleton(() => StartCloudTracking(sl()))
    ..registerLazySingleton(() => StopCloudTracking(sl()))
    ..registerLazySingleton(() => StartBackgroundTracking(sl()))
    ..registerLazySingleton(() => StopBackgroundTracking(sl()))
    ..registerLazySingleton(() => GetTrackerPosition(sl()))
    ..registerLazySingleton(() => GetTrackerHistory(sl()))
    ..registerLazySingleton(() => WatchCloudTracking(sl()))
    ..registerLazySingleton<CloudTrackerSettingsLocalDataSource>(
      () => CloudTrackerSettingsLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CloudTrackerSettingsRepository>(
      () => CloudTrackerSettingsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => LoadCloudTrackerSettings(sl()))
    ..registerLazySingleton(() => SaveCloudTrackerSettings(sl()));
}
