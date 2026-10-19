import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/route_analysis.dart';
import '../repositories/routes_repository.dart';

/// Finds the best order to visit a set of stops.
class OptimizeWaypoints
    implements UseCase<OptimizedTour, OptimizeWaypointsRequest> {
  const OptimizeWaypoints(this._repository);

  final RoutesRepository _repository;

  static const maxStops = 50;

  @override
  Future<Result<OptimizedTour>> call(OptimizeWaypointsRequest params) async {
    if (params.stops.isEmpty) {
      return const Err(
        ValidationFailure(
          'Add at least one stop besides the start.',
          code: FailureCode.optimizeStopsRequired,
        ),
      );
    }
    if (params.stops.length > maxStops) {
      return const Err(
        ValidationFailure(
          'At most $maxStops stops can be optimized.',
          code: FailureCode.optimizeTooManyStops,
          args: {'max': maxStops},
        ),
      );
    }
    return _repository.optimizeWaypoints(params);
  }
}
