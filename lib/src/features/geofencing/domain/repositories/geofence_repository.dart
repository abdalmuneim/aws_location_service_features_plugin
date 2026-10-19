import '../../../../core/result/result.dart';
import '../entities/geofence.dart';

abstract interface class GeofenceRepository {
  Future<Result<List<Geofence>>> getAll();

  /// Inserts or replaces by id.
  Future<Result<List<Geofence>>> save(Geofence geofence);

  Future<Result<List<Geofence>>> delete(String id);

  Future<Result<List<Geofence>>> clear();
}
