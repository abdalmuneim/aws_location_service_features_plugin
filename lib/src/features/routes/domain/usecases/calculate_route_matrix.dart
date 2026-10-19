import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/route_analysis.dart';
import '../repositories/routes_repository.dart';

/// Travel time and distance between every origin and destination.
class CalculateRouteMatrix implements UseCase<RouteMatrix, RouteMatrixRequest> {
  const CalculateRouteMatrix(this._repository);

  final RoutesRepository _repository;

  static const maxPoints = 15;

  @override
  Future<Result<RouteMatrix>> call(RouteMatrixRequest params) async {
    if (params.origins.isEmpty || params.destinations.isEmpty) {
      return const Err(
        ValidationFailure(
          'Add at least one origin and one destination.',
          code: FailureCode.matrixPointsRequired,
        ),
      );
    }
    if (params.origins.length > maxPoints ||
        params.destinations.length > maxPoints) {
      return const Err(
        ValidationFailure(
          'Use at most $maxPoints origins and $maxPoints destinations.',
          code: FailureCode.matrixTooManyPoints,
          args: {'max': maxPoints},
        ),
      );
    }
    return _repository.calculateRouteMatrix(params);
  }
}
