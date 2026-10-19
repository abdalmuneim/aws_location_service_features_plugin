import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/route.dart';
import '../repositories/routes_repository.dart';

/// Turn-by-turn directions between an origin and a destination.
class CalculateRoutes implements UseCase<RouteResult, RouteRequest> {
  const CalculateRoutes(this._repository);

  final RoutesRepository _repository;

  static const maxWaypoints = 23;

  @override
  Future<Result<RouteResult>> call(RouteRequest params) async {
    if (params.origin == params.destination && params.waypoints.isEmpty) {
      return const Err(
        ValidationFailure(
          'Origin and destination are the same place.',
          code: FailureCode.routeSameOriginAndDestination,
        ),
      );
    }
    if (params.waypoints.length > maxWaypoints) {
      return const Err(
        ValidationFailure(
          'A route can have at most $maxWaypoints stops.',
          code: FailureCode.routeTooManyStops,
          args: {'max': maxWaypoints},
        ),
      );
    }
    return _repository.calculateRoutes(params);
  }
}
