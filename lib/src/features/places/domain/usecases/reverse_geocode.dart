import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Reverse geocoding: coordinates to the nearest address(es).
class ReverseGeocode implements UseCase<List<Place>, ReverseGeocodeParams> {
  const ReverseGeocode(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<List<Place>>> call(ReverseGeocodeParams params) =>
      _repository.reverseGeocode(params);
}
