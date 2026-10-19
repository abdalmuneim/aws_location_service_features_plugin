import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/route_analysis.dart';
import '../repositories/routes_repository.dart';

/// Matches a noisy GPS trace to the road network.
class SnapToRoads implements UseCase<SnapResult, SnapRequest> {
  const SnapToRoads(this._repository);

  final RoutesRepository _repository;

  static const maxPoints = 5000;

  @override
  Future<Result<SnapResult>> call(SnapRequest params) async {
    if (params.points.length < 2) {
      return const Err(
        ValidationFailure(
          'A trace needs at least 2 points.',
          code: FailureCode.snapTooFewPoints,
        ),
      );
    }
    if (params.points.length > maxPoints) {
      return const Err(
        ValidationFailure(
          'A trace can have at most $maxPoints points.',
          code: FailureCode.snapTooManyPoints,
          args: {'max': maxPoints},
        ),
      );
    }
    return _repository.snapToRoads(params);
  }
}
