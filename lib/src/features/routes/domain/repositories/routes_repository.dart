import '../../../../core/result/result.dart';
import '../entities/route.dart';
import '../entities/route_analysis.dart';

/// Amazon Location Routes (v2) operations.
abstract interface class RoutesRepository {
  Future<Result<RouteResult>> calculateRoutes(RouteRequest request);

  Future<Result<IsolineResult>> calculateIsolines(IsolineRequest request);

  Future<Result<RouteMatrix>> calculateRouteMatrix(RouteMatrixRequest request);

  Future<Result<OptimizedTour>> optimizeWaypoints(
    OptimizeWaypointsRequest request,
  );

  Future<Result<SnapResult>> snapToRoads(SnapRequest request);
}
