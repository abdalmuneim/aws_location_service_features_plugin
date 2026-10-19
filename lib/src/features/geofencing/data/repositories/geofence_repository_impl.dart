import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/geofence.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/geofence_local_data_source.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  const GeofenceRepositoryImpl(this._local);

  final GeofenceLocalDataSource _local;

  @override
  Future<Result<List<Geofence>>> getAll() => guard(_local.readAll);

  @override
  Future<Result<List<Geofence>>> save(Geofence geofence) => guard(() async {
    final all = await _local.readAll();
    final index = all.indexWhere((g) => g.id == geofence.id);
    if (index >= 0) {
      all[index] = geofence;
    } else {
      all.add(geofence);
    }
    await _local.writeAll(all);
    return all;
  });

  @override
  Future<Result<List<Geofence>>> delete(String id) => guard(() async {
    final all = await _local.readAll()
      ..removeWhere((g) => g.id == id);
    await _local.writeAll(all);
    return all;
  });

  @override
  Future<Result<List<Geofence>>> clear() => guard(() async {
    await _local.writeAll(const []);
    return <Geofence>[];
  });
}
