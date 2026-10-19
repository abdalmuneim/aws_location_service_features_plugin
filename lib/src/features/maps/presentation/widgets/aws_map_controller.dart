import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/utils/geo_utils.dart';

extension GeoPointLatLng on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngGeoPoint on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

/// Camera helpers over [MapLibreMapController], expressed in domain types.
class AwsMapController {
  AwsMapController(this.raw);

  final MapLibreMapController raw;

  static const _animation = Duration(milliseconds: 700);

  GeoPoint? get center => raw.cameraPosition?.target.toGeoPoint();

  double? get zoom => raw.cameraPosition?.zoom;

  Future<void> moveTo(GeoPoint point, {double? zoom}) async {
    await raw.animateCamera(
      zoom == null
          ? CameraUpdate.newLatLng(point.toLatLng())
          : CameraUpdate.newLatLngZoom(point.toLatLng(), zoom),
      duration: _animation,
    );
  }

  /// Fits the camera to [points]; a single point is centered at [maxZoom].
  Future<void> fitPoints(
    Iterable<GeoPoint> points, {
    double padding = 64,
    double maxZoom = 15,
  }) async {
    final list = points.toList();
    if (list.isEmpty) return;
    final bounds = GeoBounds.fromPoints(list);
    if (list.length == 1 ||
        GeoUtils.distance(bounds.southWest, bounds.northEast) < 50) {
      return moveTo(bounds.center, zoom: maxZoom);
    }
    await raw.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: bounds.southWest.toLatLng(),
          northeast: bounds.northEast.toLatLng(),
        ),
        left: padding,
        top: padding,
        right: padding,
        bottom: padding,
      ),
      duration: _animation,
    );
  }

  Future<GeoBounds> visibleBounds() async {
    final region = await raw.getVisibleRegion();
    return GeoBounds(
      south: region.southwest.latitude,
      west: region.southwest.longitude,
      north: region.northeast.latitude,
      east: region.northeast.longitude,
    );
  }
}
