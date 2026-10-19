import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_analysis.dart';
import '../../domain/repositories/routes_repository.dart';
import '../datasources/routes_remote_data_source.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  const RoutesRepositoryImpl(this._remote);

  final RoutesRemoteDataSource _remote;

  @override
  Future<Result<RouteResult>> calculateRoutes(RouteRequest request) =>
      guard(() => _remote.calculateRoutes(request));

  @override
  Future<Result<IsolineResult>> calculateIsolines(IsolineRequest request) =>
      guard(() => _remote.calculateIsolines(request));

  @override
  Future<Result<RouteMatrix>> calculateRouteMatrix(
    RouteMatrixRequest request,
  ) => guard(() => _remote.calculateRouteMatrix(request));

  @override
  Future<Result<OptimizedTour>> optimizeWaypoints(
    OptimizeWaypointsRequest request,
  ) => guard(() => _remote.optimizeWaypoints(request));

  @override
  Future<Result<SnapResult>> snapToRoads(SnapRequest request) =>
      guard(() => _remote.snapToRoads(request));
}
