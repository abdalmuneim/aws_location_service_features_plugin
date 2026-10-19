import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/geofence.dart';
import '../models/geofence_model.dart';

abstract interface class GeofenceLocalDataSource {
  Future<List<Geofence>> readAll();

  Future<void> writeAll(List<Geofence> geofences);
}

/// Stores geofences as JSON in shared preferences (key `geofences_v1`).
class GeofenceLocalDataSourceImpl implements GeofenceLocalDataSource {
  const GeofenceLocalDataSourceImpl(this._prefs);

  static const _key = 'geofences_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<Geofence>> readAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final item in list)
          GeofenceModel.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      throw const CacheException(
        'Saved geofences could not be read.',
        code: FailureCode.geofencesNotRead,
      );
    }
  }

  @override
  Future<void> writeAll(List<Geofence> geofences) async {
    final ok = await _prefs.setString(
      _key,
      jsonEncode([for (final g in geofences) GeofenceModel.toJson(g)]),
    );
    if (!ok) {
      throw const CacheException(
        'Could not save geofences.',
        code: FailureCode.geofencesNotSaved,
      );
    }
  }
}

/// Keeps geofences in memory only, e.g. for tests or apps that persist them
/// elsewhere.
class InMemoryGeofenceLocalDataSource implements GeofenceLocalDataSource {
  InMemoryGeofenceLocalDataSource([List<Geofence> initial = const []])
    : _items = List.of(initial);

  List<Geofence> _items;

  @override
  Future<List<Geofence>> readAll() async => List.of(_items);

  @override
  Future<void> writeAll(List<Geofence> geofences) async {
    _items = List.of(geofences);
  }
}
