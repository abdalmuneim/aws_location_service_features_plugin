import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Full details (contacts, hours, time zone…) for a place ID.
class GetPlace implements UseCase<Place, GetPlaceParams> {
  const GetPlace(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<Place>> call(GetPlaceParams params) =>
      _repository.getPlace(params);
}
