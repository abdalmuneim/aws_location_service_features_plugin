import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';

/// A position update from the device (or the trip simulator).
class DevicePosition extends Equatable {
  const DevicePosition({
    required this.point,
    required this.timestamp,
    this.accuracyMeters,
    this.speedMps,
    this.heading,
  });

  final GeoPoint point;
  final DateTime timestamp;
  final double? accuracyMeters;

  /// Meters per second.
  final double? speedMps;

  /// Degrees from north.
  final double? heading;

  @override
  List<Object?> get props => [
    point,
    timestamp,
    accuracyMeters,
    speedMps,
    heading,
  ];
}
