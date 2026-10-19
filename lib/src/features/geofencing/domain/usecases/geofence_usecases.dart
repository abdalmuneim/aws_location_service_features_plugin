import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/geofence.dart';
import '../repositories/geofence_repository.dart';

class GetGeofences implements UseCase<List<Geofence>, NoParams> {
  const GetGeofences(this._repository);

  final GeofenceRepository _repository;

  @override
  Future<Result<List<Geofence>>> call(NoParams params) => _repository.getAll();
}

class SaveGeofence implements UseCase<List<Geofence>, Geofence> {
  const SaveGeofence(this._repository);

  final GeofenceRepository _repository;

  @override
  Future<Result<List<Geofence>>> call(Geofence params) async {
    if (params.name.trim().isEmpty) {
      return const Err(
        ValidationFailure(
          'Give the geofence a name.',
          code: FailureCode.geofenceNameRequired,
        ),
      );
    }
    final shape = params.shape;
    if (shape is PolygonShape && shape.vertices.length < 3) {
      return const Err(
        ValidationFailure(
          'A polygon needs at least 3 points.',
          code: FailureCode.geofencePolygonTooFewPoints,
        ),
      );
    }
    if (shape is CircleShape && shape.radiusMeters <= 0) {
      return const Err(
        ValidationFailure(
          'The radius must be positive.',
          code: FailureCode.geofenceRadiusNotPositive,
        ),
      );
    }
    return _repository.save(params);
  }
}

class DeleteGeofence implements UseCase<List<Geofence>, String> {
  const DeleteGeofence(this._repository);

  final GeofenceRepository _repository;

  @override
  Future<Result<List<Geofence>>> call(String params) =>
      _repository.delete(params);
}

class ClearGeofences implements UseCase<List<Geofence>, NoParams> {
  const ClearGeofences(this._repository);

  final GeofenceRepository _repository;

  @override
  Future<Result<List<Geofence>>> call(NoParams params) => _repository.clear();
}
