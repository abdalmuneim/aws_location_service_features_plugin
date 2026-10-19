import 'package:geolocator/geolocator.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/device_position.dart';

abstract interface class DeviceLocationDataSource {
  /// Throws [LocationPermissionException] when location services are off or
  /// the user refuses (asking first when the choice is still open).
  Future<void> ensurePermission();

  Future<DevicePosition> current();

  Stream<DevicePosition> watch(int distanceFilterMeters);
}

/// GPS / browser geolocation through the geolocator plugin.
class GeolocatorDataSource implements DeviceLocationDataSource {
  const GeolocatorDataSource();

  @override
  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationPermissionException(
        'Location services are turned off on this device.',
        code: FailureCode.locationServicesOff,
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(
        'Location permission denied.',
        code: FailureCode.locationPermissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Location permission is permanently denied. Enable it in system '
        'settings.',
        code: FailureCode.locationPermissionDeniedForever,
      );
    }
  }

  static DevicePosition _map(Position p) => DevicePosition(
    point: GeoPoint(p.latitude, p.longitude),
    timestamp: p.timestamp,
    accuracyMeters: p.accuracy,
    speedMps: p.speed >= 0 ? p.speed : null,
    heading: p.heading >= 0 ? p.heading : null,
  );

  @override
  Future<DevicePosition> current() async {
    await ensurePermission();
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return _map(p);
  }

  @override
  Stream<DevicePosition> watch(int distanceFilterMeters) async* {
    await ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    ).map(_map);
  }
}
