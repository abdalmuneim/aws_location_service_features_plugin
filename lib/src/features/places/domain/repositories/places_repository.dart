import '../../../../core/result/result.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';

/// Amazon Location Places (v2) operations.
abstract interface class PlacesRepository {
  Future<Result<List<Place>>> geocode(GeocodeParams params);

  Future<Result<List<Place>>> reverseGeocode(ReverseGeocodeParams params);

  Future<Result<List<AutocompleteSuggestion>>> autocomplete(
    AutocompleteParams params,
  );

  Future<Result<List<Suggestion>>> suggest(SuggestParams params);

  Future<Result<PlacePage>> searchText(SearchTextParams params);

  Future<Result<PlacePage>> searchNearby(SearchNearbyParams params);

  Future<Result<Place>> getPlace(GetPlaceParams params);
}
