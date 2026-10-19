import '../../../../core/config/aws_location_config.dart';
import '../../../../core/network/aws_location_http_client.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_analysis.dart';
import '../models/routes_mapper.dart';

abstract interface class RoutesRemoteDataSource {
  Future<RouteResult> calculateRoutes(RouteRequest request);

  Future<IsolineResult> calculateIsolines(IsolineRequest request);

  Future<RouteMatrix> calculateRouteMatrix(RouteMatrixRequest request);

  Future<OptimizedTour> optimizeWaypoints(OptimizeWaypointsRequest request);

  Future<SnapResult> snapToRoads(SnapRequest request);
}

class RoutesRemoteDataSourceImpl implements RoutesRemoteDataSource {
  const RoutesRemoteDataSourceImpl(this._client, this._config);

  final AwsLocationHttpClient _client;
  final AwsLocationConfig _config;

  static const _service = AwsLocationService.routes;

  @override
  Future<RouteResult> calculateRoutes(RouteRequest request) async {
    final json = await _client.postJson(
      _service,
      '/routes',
      RoutesMapper.routeBody(request, _config.language),
    );
    return RoutesMapper.parseRoutes(json);
  }

  @override
  Future<IsolineResult> calculateIsolines(IsolineRequest request) async {
    final json = await _client.postJson(
      _service,
      '/isolines',
      RoutesMapper.isolineBody(request),
    );
    return RoutesMapper.parseIsolines(json, request.kind);
  }

  @override
  Future<RouteMatrix> calculateRouteMatrix(RouteMatrixRequest request) async {
    final json = await _client.postJson(
      _service,
      '/route-matrix',
      RoutesMapper.matrixBody(request),
    );
    return RoutesMapper.parseMatrix(json);
  }

  @override
  Future<OptimizedTour> optimizeWaypoints(
    OptimizeWaypointsRequest request,
  ) async {
    final json = await _client.postJson(
      _service,
      '/optimize-waypoints',
      RoutesMapper.optimizeBody(request),
    );
    return RoutesMapper.parseOptimized(json);
  }

  @override
  Future<SnapResult> snapToRoads(SnapRequest request) async {
    final json = await _client.postJson(
      _service,
      '/snap-to-roads',
      RoutesMapper.snapBody(request),
    );
    return RoutesMapper.parseSnap(json);
  }
}
