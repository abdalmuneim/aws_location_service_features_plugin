import '../../../../core/entities/geo_point.dart';
import '../../domain/entities/geofence.dart';

/// JSON (de)serialization for [Geofence].
abstract final class GeofenceModel {
  static List<double> _p(GeoPoint p) => [p.longitude, p.latitude];

  static GeoPoint _point(Object? v) {
    final list = v as List;
    return GeoPoint((list[1] as num).toDouble(), (list[0] as num).toDouble());
  }

  static Map<String, Object?> toJson(Geofence g) => {
    'id': g.id,
    'name': g.name,
    'color': g.colorValue,
    'createdAt': g.createdAt.toIso8601String(),
    'source': g.source.name,
    'description': g.description,
    'shape': switch (g.shape) {
      CircleShape(:final centerPoint, :final radiusMeters) => {
        'type': 'circle',
        'center': _p(centerPoint),
        'radius': radiusMeters,
      },
      PolygonShape(:final vertices) => {
        'type': 'polygon',
        'vertices': [for (final v in vertices) _p(v)],
      },
    },
  };

  static Geofence fromJson(Map<String, dynamic> json) {
    final shape = json['shape'] as Map<String, dynamic>;
    return Geofence(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      source:
          GeofenceSource.values
              .where((s) => s.name == json['source'])
              .firstOrNull ??
          GeofenceSource.circle,
      description: json['description'] as String?,
      shape: shape['type'] == 'circle'
          ? CircleShape(
              centerPoint: _point(shape['center']),
              radiusMeters: (shape['radius'] as num).toDouble(),
            )
          : PolygonShape([
              for (final v in shape['vertices'] as List) _point(v),
            ]),
    );
  }
}
