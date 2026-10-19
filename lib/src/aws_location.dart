import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/aws_location_config.dart';
import 'core/entities/map_style_options.dart';
import 'core/network/aws_location_http_client.dart';
import 'features/geofencing/data/datasources/geofence_local_data_source.dart';
import 'features/geofencing/data/repositories/geofence_repository_impl.dart';
import 'features/geofencing/domain/repositories/geofence_repository.dart';
import 'features/maps/data/datasources/maps_remote_data_source.dart';
import 'features/maps/data/repositories/maps_repository_impl.dart';
import 'features/maps/domain/repositories/maps_repository.dart';
import 'features/maps/domain/usecases/get_map_style_url.dart';
import 'features/places/data/datasources/places_remote_data_source.dart';
import 'features/places/data/repositories/places_repository_impl.dart';
import 'features/places/domain/repositories/places_repository.dart';
import 'features/routes/data/datasources/routes_remote_data_source.dart';
import 'features/routes/data/repositories/routes_repository_impl.dart';
import 'features/routes/domain/repositories/routes_repository.dart';
import 'features/tracking/data/datasources/device_location_data_source.dart';
import 'features/tracking/data/repositories/cloud_tracking_repository_impl.dart';
import 'features/tracking/data/repositories/device_location_repository_impl.dart';
import 'features/tracking/domain/repositories/cloud_tracking_repository.dart';
import 'features/tracking/domain/repositories/device_location_repository.dart';
import 'platform/aws_location_platform.dart';

/// Entry point to every feature of the plugin, wired to one
/// [AwsLocationConfig].
///
/// ```dart
/// final aws = AwsLocation(
///   config: AwsLocationConfig(apiKey: 'v1.public...', region: 'eu-north-1'),
/// );
/// final result = await aws.places.searchText(
///   const SearchTextParams(queryText: 'coffee', biasPosition: cairo),
/// );
/// result.fold((failure) => print(failure.message), (page) => print(page));
/// ```
///
/// Every call returns a `Result` (`Ok` or `Err` with a `Failure`) and never
/// throws. The use case classes (e.g. `SearchText`, `CalculateRoutes`) add
/// input validation on top of these repositories.
class AwsLocation {
  /// [geofenceStorage] decides where geofences are kept: pass
  /// [SharedPreferences] to persist them on the device, or leave it null to
  /// keep them in memory.
  factory AwsLocation({
    required AwsLocationConfig config,
    http.Client? httpClient,
    SharedPreferences? geofenceStorage,
    DeviceLocationDataSource? deviceLocation,
    AwsLocationPlatform? platform,
  }) {
    final client = httpClient ?? http.Client();
    final location = deviceLocation ?? const GeolocatorDataSource();
    final api = AwsLocationHttpClient(client, config);
    return AwsLocation._(
      config: config,
      httpClient: client,
      ownsHttpClient: httpClient == null,
      maps: MapsRepositoryImpl(MapsRemoteDataSourceImpl(api)),
      places: PlacesRepositoryImpl(PlacesRemoteDataSourceImpl(api, config)),
      routes: RoutesRepositoryImpl(RoutesRemoteDataSourceImpl(api, config)),
      geofences: GeofenceRepositoryImpl(
        geofenceStorage == null
            ? InMemoryGeofenceLocalDataSource()
            : GeofenceLocalDataSourceImpl(geofenceStorage),
      ),
      deviceLocation: DeviceLocationRepositoryImpl(location),
      cloudTracking: CloudTrackingRepositoryImpl(
        platform ?? AwsLocationPlatform.instance,
        location,
      ),
    );
  }

  AwsLocation._({
    required this.config,
    required this._httpClient,
    required this._ownsHttpClient,
    required this.maps,
    required this.places,
    required this.routes,
    required this.geofences,
    required this.deviceLocation,
    required this.cloudTracking,
  });

  /// Shared, mutable connection settings; changes apply to the next call.
  final AwsLocationConfig config;

  /// Map style descriptors (for `AwsMapView`) and static map images.
  final MapsRepository maps;

  /// Geocode, reverse geocode, autocomplete, suggest, search text, search
  /// nearby and get place.
  final PlacesRepository places;

  /// Routes, isolines, route matrix, waypoint optimization, snap to roads.
  final RoutesRepository routes;

  /// Circle and polygon geofences evaluated on the device.
  final GeofenceRepository geofences;

  /// GPS / browser location through geolocator.
  final DeviceLocationRepository deviceLocation;

  /// Positions sent to an Amazon Location tracker (Amazon Location Mobile
  /// Tracking SDKs on Android and iOS, Dart on the web).
  final CloudTrackingRepository cloudTracking;

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  /// Style descriptor URL for `AwsMapView`, with the configured political
  /// view.
  String styleUrl([MapStyleOptions options = const MapStyleOptions()]) =>
      GetMapStyleUrl(maps)(
        MapStyleParams(options: options, politicalView: config.politicalView),
      );

  /// Closes the HTTP client when this object created it.
  void dispose() {
    if (_ownsHttpClient) _httpClient.close();
  }
}
