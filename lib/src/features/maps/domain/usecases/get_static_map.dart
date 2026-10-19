import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/static_map.dart';
import '../repositories/maps_repository.dart';

class GetStaticMap implements UseCase<StaticMapImage, StaticMapRequest> {
  const GetStaticMap(this._repository);

  final MapsRepository _repository;

  @override
  Future<Result<StaticMapImage>> call(StaticMapRequest params) =>
      _repository.getStaticMap(params);
}
