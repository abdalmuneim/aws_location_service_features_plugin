import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Forward geocoding: free-text or structured address to coordinates.
class Geocode implements UseCase<List<Place>, GeocodeParams> {
  const Geocode(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<List<Place>>> call(GeocodeParams params) async {
    final hasText = params.queryText?.trim().isNotEmpty ?? false;
    final hasComponents = !(params.components?.isEmpty ?? true);
    if (!hasText && !hasComponents) {
      return const Err(
        ValidationFailure(
          'Enter an address to geocode.',
          code: FailureCode.geocodeAddressRequired,
        ),
      );
    }
    return _repository.geocode(params);
  }
}
