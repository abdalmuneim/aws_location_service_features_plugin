import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Suggests places and query refinements (e.g. "coffee near me").
class SuggestPlaces implements UseCase<List<Suggestion>, SuggestParams> {
  const SuggestPlaces(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<List<Suggestion>>> call(SuggestParams params) async {
    if (params.queryText.trim().length < 2) return const Ok([]);
    return _repository.suggest(params);
  }
}
