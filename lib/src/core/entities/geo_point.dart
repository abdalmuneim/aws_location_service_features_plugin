import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// A WGS84 coordinate. Amazon Location transmits positions as
/// `[longitude, latitude]`; the data layer converts to and from this type.
class GeoPoint extends Equatable {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  String format([int fractionDigits = 5]) =>
      '${latitude.toStringAsFixed(fractionDigits)}, '
      '${longitude.toStringAsFixed(fractionDigits)}';

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoPoint(${format()})';
}

/// An axis-aligned bounding box.
class GeoBounds extends Equatable {
  const GeoBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  });

  factory GeoBounds.fromPoints(Iterable<GeoPoint> points) {
    var south = 90.0, north = -90.0, west = 180.0, east = -180.0;
    for (final p in points) {
      south = math.min(south, p.latitude);
      north = math.max(north, p.latitude);
      west = math.min(west, p.longitude);
      east = math.max(east, p.longitude);
    }
    return GeoBounds(south: south, west: west, north: north, east: east);
  }

  final double south;
  final double west;
  final double north;
  final double east;

  GeoPoint get southWest => GeoPoint(south, west);
  GeoPoint get northEast => GeoPoint(north, east);
  GeoPoint get center => GeoPoint((south + north) / 2, (west + east) / 2);

  @override
  List<Object?> get props => [south, west, north, east];
}
