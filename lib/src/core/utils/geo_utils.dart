import 'dart:math' as math;

import '../entities/geo_point.dart';

/// Pure geometry helpers used by geofencing, tracking and drawing.
abstract final class GeoUtils {
  static const double earthRadiusMeters = 6371008.8;

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;

  /// Great-circle distance in meters.
  static double distance(GeoPoint a, GeoPoint b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadiusMeters * math.asin(math.min(1, math.sqrt(h)));
  }

  static double pathLength(List<GeoPoint> path) {
    var total = 0.0;
    for (var i = 1; i < path.length; i++) {
      total += distance(path[i - 1], path[i]);
    }
    return total;
  }

  /// Initial bearing from [a] to [b] in degrees (0 = north).
  static double bearing(GeoPoint a, GeoPoint b) {
    final lat1 = _rad(a.latitude), lat2 = _rad(b.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (_deg(math.atan2(y, x)) + 360) % 360;
  }

  /// The point [meters] away from [origin] heading [bearingDeg].
  static GeoPoint offset(GeoPoint origin, double meters, double bearingDeg) {
    final d = meters / earthRadiusMeters;
    final b = _rad(bearingDeg);
    final lat1 = _rad(origin.latitude), lng1 = _rad(origin.longitude);
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(d) + math.cos(lat1) * math.sin(d) * math.cos(b),
    );
    final lng2 =
        lng1 +
        math.atan2(
          math.sin(b) * math.sin(d) * math.cos(lat1),
          math.cos(d) - math.sin(lat1) * math.sin(lat2),
        );
    return GeoPoint(_deg(lat2), (_deg(lng2) + 540) % 360 - 180);
  }

  /// A closed ring approximating a circle, for drawing circular geofences.
  static List<GeoPoint> circle(
    GeoPoint center,
    double radiusMeters, {
    int segments = 64,
  }) {
    final ring = <GeoPoint>[
      for (var i = 0; i < segments; i++)
        offset(center, radiusMeters, 360 * i / segments),
    ];
    ring.add(ring.first);
    return ring;
  }

  /// Ray-casting point-in-polygon test (ring may be open or closed).
  static bool containsPoint(List<GeoPoint> ring, GeoPoint p) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i].longitude, yi = ring[i].latitude;
      final xj = ring[j].longitude, yj = ring[j].latitude;
      final intersects =
          (yi > p.latitude) != (yj > p.latitude) &&
          p.longitude < (xj - xi) * (p.latitude - yi) / (yj - yi) + xi;
      if (intersects) inside = !inside;
    }
    return inside;
  }

  /// Linear interpolation between two points (fine for short segments).
  static GeoPoint lerp(GeoPoint a, GeoPoint b, double t) => GeoPoint(
    a.latitude + (b.latitude - a.latitude) * t,
    a.longitude + (b.longitude - a.longitude) * t,
  );

  /// Resamples [path] so consecutive points are at most [stepMeters] apart.
  static List<GeoPoint> densify(List<GeoPoint> path, double stepMeters) {
    if (path.length < 2) return List.of(path);
    final out = <GeoPoint>[path.first];
    for (var i = 1; i < path.length; i++) {
      final a = path[i - 1], b = path[i];
      final d = distance(a, b);
      final steps = (d / stepMeters).floor();
      for (var s = 1; s <= steps; s++) {
        out.add(lerp(a, b, s * stepMeters / d));
      }
      if (out.last != b) out.add(b);
    }
    return out;
  }

  /// Simulated GPS noise: moves [p] by up to [meters] in a random direction.
  static GeoPoint jitter(GeoPoint p, double meters, math.Random random) =>
      offset(p, random.nextDouble() * meters, random.nextDouble() * 360);
}
