import 'dart:convert';

import '../../../../core/entities/geo_point.dart';
import '../../domain/entities/static_map.dart';

/// Maps a [StaticMapRequest] to GetStaticMap query parameters.
abstract final class StaticMapQuery {
  static String _pos(GeoPoint p) => '${p.longitude},${p.latitude}';

  static Map<String, Object?> fromRequest(StaticMapRequest r) {
    final markers = r.markers;
    final fit = r.framing == StaticFraming.fitMarkers && markers.length >= 2;
    final query = <String, Object?>{
      'width': r.width,
      'height': r.height,
      'style': r.style.apiValue,
      'padding': fit ? r.padding : null,
      'scale-unit': r.scaleUnit.apiValue,
    };

    if (fit) {
      query['bounded-positions'] = markers
          .map((m) => _pos(m.position))
          .join(',');
    } else {
      query['center'] = _pos(r.center);
      if (r.framing == StaticFraming.centerRadius) {
        query['radius'] = r.radiusMeters;
      } else {
        query['zoom'] = r.zoom.toStringAsFixed(1);
      }
    }

    if (r.isStandard) {
      query['color-scheme'] = r.colorScheme.apiValue;
      query['label-size'] = r.labelSize.apiValue;
      query['language'] = r.language;
      query['political-view'] = r.politicalView;
      query['points-of-interests'] = r.showPointsOfInterest ? null : 'Disabled';
      query['crop-labels'] = r.cropLabels ? 'true' : null;
    }

    final overlay = _overlay(r);
    if (overlay != null) query['geojson-overlay'] = jsonEncode(overlay);
    return query;
  }

  static Map<String, Object?>? _overlay(StaticMapRequest r) {
    if (r.markers.isEmpty) return null;
    final features = <Map<String, Object?>>[];
    if (r.connectMarkers && r.markers.length >= 2) {
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            for (final m in r.markers)
              [m.position.longitude, m.position.latitude],
          ],
        },
        'properties': {
          'color': '#1A73E8',
          'width': '5px',
          'outline-color': '#FFFFFF',
          'outline-width': '2px',
        },
      });
    }
    for (final m in r.markers) {
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [m.position.longitude, m.position.latitude],
        },
        'properties': {
          'color': m.colorHex,
          'size': 'large',
          if (m.label != null && m.label!.isNotEmpty) 'label': m.label,
        },
      });
    }
    return {'type': 'FeatureCollection', 'features': features};
  }
}
