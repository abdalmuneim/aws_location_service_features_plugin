import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/entities/geo_point.dart';
import 'aws_map_controller.dart';
import 'map_overlay.dart';

/// An Amazon Location map (rendered by MapLibre) that draws a declarative
/// [MapOverlay] on top of the base style.
///
/// [styleUrl] is a GetStyleDescriptor URL, usually from
/// `MapsRepository.styleDescriptorUrl` or the `GetMapStyleUrl` use case.
/// Changing it swaps the style; overlay layers are re-created after every
/// style change.
class AwsMapView extends StatefulWidget {
  const AwsMapView({
    super.key,
    required this.styleUrl,
    this.overlay = const MapOverlay(),
    this.initialCenter = const GeoPoint(0, 0),
    this.initialZoom = 2,
    this.onTap,
    this.onLongPress,
    this.onMarkerTap,
    this.onMapReady,
    this.onCameraIdle,
  });

  final String styleUrl;
  final MapOverlay overlay;
  final GeoPoint initialCenter;
  final double initialZoom;
  final ValueChanged<GeoPoint>? onTap;
  final ValueChanged<GeoPoint>? onLongPress;
  final ValueChanged<MapMarker>? onMarkerTap;
  final ValueChanged<AwsMapController>? onMapReady;
  final ValueChanged<AwsMapController>? onCameraIdle;

  @override
  State<AwsMapView> createState() => _AwsMapViewState();
}

class _AwsMapViewState extends State<AwsMapView> {
  static const _polygonSource = 'app-polygons';
  static const _lineSource = 'app-lines';
  static const _pointSource = 'app-points';
  static const _markerLayer = 'app-points-circle';
  static const _boldFont = ['Amazon Ember Bold,Noto Sans Bold'];
  static const _regularFont = ['Amazon Ember Regular,Noto Sans Regular'];
  static const _emptyCollection = <String, dynamic>{
    'type': 'FeatureCollection',
    'features': <dynamic>[],
  };

  MapLibreMapController? _controller;
  AwsMapController? _wrapper;
  bool _layersReady = false;
  MapOverlay? _synced;
  bool _syncing = false;
  bool _resync = false;
  String? _styleUrl;

  @override
  void didUpdateWidget(covariant AwsMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.overlay != widget.overlay) _scheduleSync();
  }

  @override
  void dispose() {
    _controller?.onFeatureTapped.remove(_onFeatureTapped);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleUrl = widget.styleUrl;
    if (_styleUrl != null && _styleUrl != styleUrl) {
      // The style is about to be replaced together with our sources; hold
      // overlay updates until it has loaded and the layers are re-added.
      _layersReady = false;
    }
    _styleUrl = styleUrl;
    final center = widget.initialCenter;

    return MapLibreMap(
      styleString: styleUrl,
      initialCameraPosition: CameraPosition(
        target: center.toLatLng(),
        zoom: widget.initialZoom,
      ),
      trackCameraPosition: true,
      compassEnabled: true,
      attributionButtonPosition: AttributionButtonPosition.bottomRight,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      onMapClick: (_, latLng) {
        if (_interactive) widget.onTap?.call(latLng.toGeoPoint());
      },
      onMapLongClick: (_, latLng) {
        if (_interactive) widget.onLongPress?.call(latLng.toGeoPoint());
      },
      onCameraIdle: () {
        final c = _wrapper;
        if (c != null) widget.onCameraIdle?.call(c);
      },
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _wrapper = AwsMapController(controller);
    controller.onFeatureTapped.add(_onFeatureTapped);
    widget.onMapReady?.call(_wrapper!);
  }

  /// False while a sheet, dialog or menu covers the map's route. On the web
  /// those clicks would otherwise also land on the map underneath.
  bool get _interactive =>
      mounted && (ModalRoute.of(context)?.isCurrent ?? true);

  void _onFeatureTapped(
    Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (!_interactive) return;
    final marker = widget.overlay.markers.where((m) => m.id == id).firstOrNull;
    if (marker != null && widget.onMarkerTap != null) {
      widget.onMarkerTap!(marker);
    } else {
      widget.onTap?.call(coordinates.toGeoPoint());
    }
  }

  Future<void> _onStyleLoaded() async {
    final c = _controller;
    if (c == null) return;
    _layersReady = false;
    _synced = null;
    try {
      await _installLayers(c);
      _layersReady = true;
      _scheduleSync();
    } catch (e) {
      debugPrint('Could not add overlay layers: $e');
    }
  }

  Future<void> _installLayers(MapLibreMapController c) async {
    for (final source in [_polygonSource, _lineSource, _pointSource]) {
      try {
        await c.addGeoJsonSource(source, _emptyCollection, promoteId: 'id');
      } catch (_) {
        // Source survived the style reload; keep it.
      }
    }
    Future<void> add(Future<void> Function() addLayer) async {
      try {
        await addLayer();
      } catch (_) {
        // Layer already present.
      }
    }

    await add(
      () => c.addFillLayer(
        _polygonSource,
        'app-polygons-fill',
        const FillLayerProperties(
          fillColor: ['get', 'fillColor'],
          fillOpacity: ['get', 'fillOpacity'],
        ),
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addLineLayer(
        _polygonSource,
        'app-polygons-outline',
        const LineLayerProperties(
          lineColor: ['get', 'strokeColor'],
          lineWidth: ['get', 'strokeWidth'],
          lineJoin: 'round',
        ),
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addLineLayer(
        _lineSource,
        'app-lines-casing',
        const LineLayerProperties(
          lineColor: '#FFFFFF',
          lineWidth: [
            '+',
            ['get', 'width'],
            4,
          ],
          lineOpacity: ['get', 'opacity'],
          lineJoin: 'round',
          lineCap: 'round',
        ),
        filter: [
          '==',
          ['get', 'casing'],
          true,
        ],
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addLineLayer(
        _lineSource,
        'app-lines',
        const LineLayerProperties(
          lineColor: ['get', 'color'],
          lineWidth: ['get', 'width'],
          lineOpacity: ['get', 'opacity'],
          lineJoin: 'round',
          lineCap: 'round',
        ),
        filter: [
          '!=',
          ['get', 'dashed'],
          true,
        ],
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addLineLayer(
        _lineSource,
        'app-lines-dashed',
        const LineLayerProperties(
          lineColor: ['get', 'color'],
          lineWidth: ['get', 'width'],
          lineOpacity: ['get', 'opacity'],
          lineDasharray: [2, 1.5],
        ),
        filter: [
          '==',
          ['get', 'dashed'],
          true,
        ],
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addCircleLayer(
        _pointSource,
        _markerLayer,
        const CircleLayerProperties(
          circleRadius: ['get', 'radius'],
          circleColor: ['get', 'color'],
          circleStrokeColor: '#FFFFFF',
          // Thin outline for small dots so dense sets stay readable.
          circleStrokeWidth: [
            'case',
            [
              '<',
              ['get', 'radius'],
              6,
            ],
            1,
            2.5,
          ],
        ),
      ),
    );
    await add(
      () => c.addSymbolLayer(
        _pointSource,
        'app-points-label',
        const SymbolLayerProperties(
          textField: ['get', 'label'],
          textFont: _boldFont,
          textSize: 11,
          textColor: '#FFFFFF',
          textAllowOverlap: true,
          textIgnorePlacement: true,
        ),
        enableInteraction: false,
      ),
    );
    await add(
      () => c.addSymbolLayer(
        _pointSource,
        'app-points-title',
        const SymbolLayerProperties(
          textField: ['get', 'title'],
          textFont: _regularFont,
          textSize: 12,
          textColor: '#202124',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1.6,
          textOffset: [0, 1.2],
          textAnchor: 'top',
          textOptional: true,
          textMaxWidth: 12,
        ),
        enableInteraction: false,
      ),
    );
  }

  void _scheduleSync() {
    if (!_layersReady) return;
    if (_syncing) {
      _resync = true;
      return;
    }
    _syncing = true;
    _sync().whenComplete(() {
      _syncing = false;
      if (_resync && mounted) {
        _resync = false;
        _scheduleSync();
      }
    });
  }

  Future<void> _sync() async {
    final c = _controller;
    if (c == null || !mounted || !_layersReady) return;
    final overlay = widget.overlay;
    if (overlay == _synced) return;
    try {
      // On the web, setData may return a promise that never settles (for
      // example when the style is swapped mid-update). The data is applied
      // synchronously, so a bounded wait keeps the queue from stalling.
      await Future.wait([
        c.setGeoJsonSource(_polygonSource, overlay.polygonsGeoJson()),
        c.setGeoJsonSource(_lineSource, overlay.linesGeoJson()),
        c.setGeoJsonSource(_pointSource, overlay.pointsGeoJson()),
      ]).timeout(const Duration(seconds: 2));
      _synced = overlay;
    } on TimeoutException {
      _synced = overlay;
    } catch (e) {
      debugPrint('Could not update overlay: $e');
    }
  }
}
