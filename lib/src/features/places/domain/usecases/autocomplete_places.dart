import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Type-ahead completion of partial addresses.
class AutocompletePlaces
    implements UseCase<List<AutocompleteSuggestion>, AutocompleteParams> {
  const AutocompletePlaces(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<List<AutocompleteSuggestion>>> call(
    AutocompleteParams params,
  ) async {
    if (params.queryText.trim().length < 2) return const Ok([]);
    return _repository.autocomplete(params);
  }
}
