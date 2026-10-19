/// Amazon Location Service for Flutter (Android, iOS, web).
///
/// * Maps: style descriptors for MapLibre, `AwsMapView`, static maps.
/// * Places: geocode, reverse geocode, autocomplete, suggest, search text,
///   search nearby, get place.
/// * Routes: routes, isolines, route matrix, waypoint optimization, snap to
///   roads.
/// * Geofencing: circle/polygon geofences with ENTER/EXIT evaluation.
/// * Tracking: device location, simulated trips, and cloud tracking to an
///   Amazon Location tracker through the Amazon Location Mobile SDKs.
///
/// Start with [AwsLocation].
library;

// Entry point
export 'src/aws_location.dart';

// Core
export 'src/core/auth/aws_credentials.dart';
export 'src/core/auth/cognito_credentials_provider.dart';
export 'src/core/auth/sigv4_signer.dart';
export 'src/core/config/aws_location_config.dart';
export 'src/core/entities/geo_point.dart';
export 'src/core/entities/map_style_options.dart';
export 'src/core/entities/measurement_units.dart';
export 'src/core/entities/named_location.dart';
export 'src/core/error/exceptions.dart';
export 'src/core/error/failures.dart';
export 'src/core/error/guard.dart';
export 'src/core/network/aws_location_http_client.dart';
export 'src/core/network/aws_signed_http_client.dart';
export 'src/core/result/result.dart';
export 'src/core/usecase/usecase.dart';
export 'src/core/utils/geo_utils.dart';
export 'src/core/utils/json_utils.dart';

// Maps
export 'src/features/maps/data/datasources/maps_remote_data_source.dart';
export 'src/features/maps/data/repositories/maps_repository_impl.dart';
export 'src/features/maps/domain/entities/static_map.dart';
export 'src/features/maps/domain/repositories/maps_repository.dart';
export 'src/features/maps/domain/usecases/get_map_style_url.dart';
export 'src/features/maps/domain/usecases/get_static_map.dart';
export 'src/features/maps/presentation/widgets/aws_map_controller.dart';
export 'src/features/maps/presentation/widgets/aws_map_view.dart';
export 'src/features/maps/presentation/widgets/map_overlay.dart';

// Places
export 'src/features/places/data/datasources/places_remote_data_source.dart';
export 'src/features/places/data/repositories/places_repository_impl.dart';
export 'src/features/places/domain/entities/place.dart';
export 'src/features/places/domain/entities/place_queries.dart';
export 'src/features/places/domain/repositories/places_repository.dart';
export 'src/features/places/domain/usecases/autocomplete_places.dart';
export 'src/features/places/domain/usecases/geocode.dart';
export 'src/features/places/domain/usecases/get_place.dart';
export 'src/features/places/domain/usecases/reverse_geocode.dart';
export 'src/features/places/domain/usecases/search_nearby.dart';
export 'src/features/places/domain/usecases/search_text.dart';
export 'src/features/places/domain/usecases/suggest_places.dart';

// Routes
export 'src/features/routes/data/datasources/routes_remote_data_source.dart';
export 'src/features/routes/data/repositories/routes_repository_impl.dart';
export 'src/features/routes/domain/entities/route.dart';
export 'src/features/routes/domain/entities/route_analysis.dart';
export 'src/features/routes/domain/entities/route_options.dart';
export 'src/features/routes/domain/repositories/routes_repository.dart';
export 'src/features/routes/domain/usecases/calculate_isolines.dart';
export 'src/features/routes/domain/usecases/calculate_route_matrix.dart';
export 'src/features/routes/domain/usecases/calculate_routes.dart';
export 'src/features/routes/domain/usecases/optimize_waypoints.dart';
export 'src/features/routes/domain/usecases/snap_to_roads.dart';

// Geofencing
export 'src/features/geofencing/data/datasources/geofence_local_data_source.dart';
export 'src/features/geofencing/data/models/geofence_model.dart';
export 'src/features/geofencing/data/repositories/geofence_repository_impl.dart';
export 'src/features/geofencing/domain/entities/geofence.dart';
export 'src/features/geofencing/domain/repositories/geofence_repository.dart';
export 'src/features/geofencing/domain/usecases/evaluate_geofences.dart';
export 'src/features/geofencing/domain/usecases/geofence_usecases.dart';

// Tracking
export 'src/features/tracking/data/datasources/dart_cloud_tracker.dart';
export 'src/features/tracking/data/datasources/device_location_data_source.dart';
export 'src/features/tracking/data/datasources/tracker_remote_data_source.dart';
export 'src/features/tracking/data/repositories/cloud_tracking_repository_impl.dart';
export 'src/features/tracking/data/repositories/device_location_repository_impl.dart';
export 'src/features/tracking/domain/entities/cloud_tracking.dart';
export 'src/features/tracking/domain/entities/device_position.dart';
export 'src/features/tracking/domain/repositories/cloud_tracking_repository.dart';
export 'src/features/tracking/domain/repositories/device_location_repository.dart';
export 'src/features/tracking/domain/usecases/cloud_tracking_usecases.dart';
export 'src/features/tracking/domain/usecases/location_usecases.dart';
export 'src/features/tracking/domain/usecases/simulate_trip.dart';
