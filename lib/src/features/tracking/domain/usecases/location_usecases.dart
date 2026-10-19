import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/device_position.dart';
import '../repositories/device_location_repository.dart';

class GetCurrentLocation implements UseCase<DevicePosition, NoParams> {
  const GetCurrentLocation(this._repository);

  final DeviceLocationRepository _repository;

  @override
  Future<Result<DevicePosition>> call(NoParams params) =>
      _repository.currentPosition();
}

class WatchLocation implements StreamUseCase<Result<DevicePosition>, int> {
  const WatchLocation(this._repository);

  final DeviceLocationRepository _repository;

  /// [params] is the minimum distance in meters between updates.
  @override
  Stream<Result<DevicePosition>> call(int params) =>
      _repository.watchPosition(distanceFilterMeters: params);
}
