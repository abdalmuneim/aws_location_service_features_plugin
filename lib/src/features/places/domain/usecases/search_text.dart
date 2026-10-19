import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/place.dart';
import '../entities/place_queries.dart';
import '../repositories/places_repository.dart';

/// Free-text search for places, businesses and addresses.
class SearchText implements UseCase<PlacePage, SearchTextParams> {
  const SearchText(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<PlacePage>> call(SearchTextParams params) async {
    final hasText = params.queryText?.trim().isNotEmpty ?? false;
    if (!hasText && params.queryId == null && params.nextToken == null) {
      return const Err(
        ValidationFailure(
          'Enter something to search for.',
          code: FailureCode.searchQueryRequired,
        ),
      );
    }
    return _repository.searchText(params);
  }
}
