import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/utils/geo_utils.dart';

/// Geometry of a geofence, mirroring Amazon Location geofence shapes.
sealed class GeofenceShape extends Equatable {
  const GeofenceShape();

  bool contains(GeoPoint point);

  /// Closed ring for drawing.
  List<GeoPoint> get outline;

  GeoPoint get center;
}

final class CircleShape extends GeofenceShape {
  const CircleShape({required this.centerPoint, required this.radiusMeters});

  final GeoPoint centerPoint;
  final double radiusMeters;

  @override
  bool contains(GeoPoint point) =>
      GeoUtils.distance(centerPoint, point) <= radiusMeters;

  @override
  List<GeoPoint> get outline => GeoUtils.circle(centerPoint, radiusMeters);

  @override
  GeoPoint get center => centerPoint;

  @override
  List<Object?> get props => [centerPoint, radiusMeters];
}

final class PolygonShape extends GeofenceShape {
  const PolygonShape(this.vertices);

  final List<GeoPoint> vertices;

  @override
  bool contains(GeoPoint point) => GeoUtils.containsPoint(vertices, point);

  @override
  List<GeoPoint> get outline =>
      vertices.isEmpty || vertices.first == vertices.last
      ? vertices
      : [...vertices, vertices.first];

  @override
  GeoPoint get center => GeoBounds.fromPoints(vertices).center;

  @override
  List<Object?> get props => [vertices];
}

/// How a geofence was created.
enum GeofenceSource {
  circle('Circle'),
  polygon('Polygon'),
  isoline('Isoline');

  const GeofenceSource(this.label);

  final String label;
}

class Geofence extends Equatable {
  const Geofence({
    required this.id,
    required this.name,
    required this.shape,
    required this.colorValue,
    required this.createdAt,
    this.source = GeofenceSource.circle,
    this.description,
  });

  final String id;
  final String name;
  final GeofenceShape shape;

  /// ARGB color for drawing.
  final int colorValue;
  final DateTime createdAt;
  final GeofenceSource source;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    name,
    shape,
    colorValue,
    createdAt,
    source,
    description,
  ];
}

enum GeofenceTransition {
  enter('ENTER'),
  exit('EXIT');

  const GeofenceTransition(this.label);

  final String label;
}

/// Same shape as an Amazon Location geofence event (EventBridge).
class GeofenceEvent extends Equatable {
  const GeofenceEvent({
    required this.geofenceId,
    required this.geofenceName,
    required this.transition,
    required this.position,
    required this.time,
  });

  final String geofenceId;
  final String geofenceName;
  final GeofenceTransition transition;
  final GeoPoint position;
  final DateTime time;

  @override
  List<Object?> get props => [geofenceId, transition, position, time];
}
