import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_queries.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_data_source.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  const PlacesRepositoryImpl(this._remote);

  final PlacesRemoteDataSource _remote;

  @override
  Future<Result<List<Place>>> geocode(GeocodeParams params) =>
      guard(() => _remote.geocode(params));

  @override
  Future<Result<List<Place>>> reverseGeocode(ReverseGeocodeParams params) =>
      guard(() => _remote.reverseGeocode(params));

  @override
  Future<Result<List<AutocompleteSuggestion>>> autocomplete(
    AutocompleteParams params,
  ) => guard(() => _remote.autocomplete(params));

  @override
  Future<Result<List<Suggestion>>> suggest(SuggestParams params) =>
      guard(() => _remote.suggest(params));

  @override
  Future<Result<PlacePage>> searchText(SearchTextParams params) =>
      guard(() => _remote.searchText(params));

  @override
  Future<Result<PlacePage>> searchNearby(SearchNearbyParams params) =>
      guard(() => _remote.searchNearby(params));

  @override
  Future<Result<Place>> getPlace(GetPlaceParams params) =>
      guard(() => _remote.getPlace(params));
}
