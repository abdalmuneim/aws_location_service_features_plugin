import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/route_analysis.dart';
import '../repositories/routes_repository.dart';

/// Reachable areas ("how far can I get in 10 minutes?").
class CalculateIsolines implements UseCase<IsolineResult, IsolineRequest> {
  const CalculateIsolines(this._repository);

  final RoutesRepository _repository;

  static const maxThresholds = 5;

  @override
  Future<Result<IsolineResult>> call(IsolineRequest params) async {
    if (params.thresholds.isEmpty) {
      return const Err(
        ValidationFailure(
          'Choose at least one threshold.',
          code: FailureCode.isolineThresholdRequired,
        ),
      );
    }
    if (params.thresholds.length > maxThresholds) {
      return const Err(
        ValidationFailure(
          'At most $maxThresholds thresholds are allowed.',
          code: FailureCode.isolineTooManyThresholds,
          args: {'max': maxThresholds},
        ),
      );
    }
    final sorted = [...params.thresholds]..sort();
    return _repository.calculateIsolines(
      IsolineRequest(
        origin: params.origin,
        thresholds: sorted,
        kind: params.kind,
        travelMode: params.travelMode,
        avoid: params.avoid,
        useTraffic: params.useTraffic,
      ),
    );
  }
}
