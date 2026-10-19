import '../../../../core/result/result.dart';
import '../entities/device_position.dart';

abstract interface class DeviceLocationRepository {
  /// One-shot position fix (asks for permission when needed).
  Future<Result<DevicePosition>> currentPosition();

  /// Continuous updates; failures are delivered as [Err] events.
  Stream<Result<DevicePosition>> watchPosition({int distanceFilterMeters});
}
