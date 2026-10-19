import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/entities/geo_point.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

List<double> _lngLat(GeoPoint p) => [p.longitude, p.latitude];

/// A circle marker with an optional short [label] drawn inside it and an
/// optional [title] drawn below it.
class MapMarker extends Equatable {
  const MapMarker({
    required this.id,
    required this.position,
    this.color = const Color(0xFF1A73E8),
    this.label,
    this.title,
    this.radius = 9,
  });

  final String id;
  final GeoPoint position;
  final Color color;
  final String? label;
  final String? title;
  final double radius;

  @override
  List<Object?> get props => [id, position, color, label, title, radius];
}

class MapPolyline extends Equatable {
  const MapPolyline({
    required this.id,
    required this.points,
    this.color = const Color(0xFF1A73E8),
    this.width = 5,
    this.opacity = 1,
    this.dashed = false,
    this.casing = true,
  });

  final String id;
  final List<GeoPoint> points;
  final Color color;
  final double width;
  final double opacity;
  final bool dashed;

  /// Draw a white outline under the line so it stands out from roads.
  final bool casing;

  @override
  List<Object?> get props => [
    id,
    points,
    color,
    width,
    opacity,
    dashed,
    casing,
  ];
}

class MapPolygon extends Equatable {
  const MapPolygon({
    required this.id,
    required this.rings,
    this.fillColor = const Color(0xFF1A73E8),
    this.fillOpacity = 0.2,
    this.strokeColor,
    this.strokeWidth = 2,
  });

  final String id;

  /// Outer ring first, then holes.
  final List<List<GeoPoint>> rings;
  final Color fillColor;
  final double fillOpacity;
  final Color? strokeColor;
  final double strokeWidth;

  @override
  List<Object?> get props => [
    id,
    rings,
    fillColor,
    fillOpacity,
    strokeColor,
    strokeWidth,
  ];
}

/// Everything a screen wants drawn on top of the base map.
///
/// [AwsMapView] diffs overlays by value, so building a new instance on every
/// rebuild is cheap when nothing changed.
class MapOverlay extends Equatable {
  const MapOverlay({
    this.markers = const [],
    this.polylines = const [],
    this.polygons = const [],
  });

  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final List<MapPolygon> polygons;

  bool get isEmpty => markers.isEmpty && polylines.isEmpty && polygons.isEmpty;

  /// All coordinates, for fitting the camera.
  Iterable<GeoPoint> get allPoints sync* {
    for (final m in markers) {
      yield m.position;
    }
    for (final l in polylines) {
      yield* l.points;
    }
    for (final p in polygons) {
      if (p.rings.isNotEmpty) yield* p.rings.first;
    }
  }

  Map<String, dynamic> pointsGeoJson() => _collection([
    for (final m in markers)
      _feature(
        m.id,
        {'type': 'Point', 'coordinates': _lngLat(m.position)},
        {
          'color': _hex(m.color),
          'radius': m.radius,
          'label': m.label ?? '',
          'title': m.title ?? '',
        },
      ),
  ]);

  Map<String, dynamic> linesGeoJson() => _collection([
    for (final l in polylines)
      if (l.points.length >= 2)
        _feature(
          l.id,
          {
            'type': 'LineString',
            'coordinates': [for (final p in l.points) _lngLat(p)],
          },
          {
            'color': _hex(l.color),
            'width': l.width,
            'opacity': l.opacity,
            'dashed': l.dashed,
            'casing': l.casing,
          },
        ),
  ]);

  Map<String, dynamic> polygonsGeoJson() => _collection([
    for (final p in polygons)
      if (p.rings.isNotEmpty && p.rings.first.length >= 3)
        _feature(
          p.id,
          {
            'type': 'Polygon',
            'coordinates': [
              for (final ring in p.rings)
                [
                  for (final pt in ring) _lngLat(pt),
                  if (ring.first != ring.last) _lngLat(ring.first),
                ],
            ],
          },
          {
            'fillColor': _hex(p.fillColor),
            'fillOpacity': p.fillOpacity,
            'strokeColor': _hex(p.strokeColor ?? p.fillColor),
            'strokeWidth': p.strokeWidth,
          },
        ),
  ]);

  static Map<String, dynamic> _collection(List<Map<String, dynamic>> f) => {
    'type': 'FeatureCollection',
    'features': f,
  };

  static Map<String, dynamic> _feature(
    String id,
    Map<String, dynamic> geometry,
    Map<String, dynamic> properties,
  ) => {
    'type': 'Feature',
    'id': id,
    'geometry': geometry,
    'properties': {'id': id, ...properties},
  };

  @override
  List<Object?> get props => [markers, polylines, polygons];
}
