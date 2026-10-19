import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Points of interest around a position, optionally filtered by category.
class SearchNearby implements UseCase<PlacePage, SearchNearbyParams> {
  const SearchNearby(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<PlacePage>> call(SearchNearbyParams params) =>
      _repository.searchNearby(params);
}
