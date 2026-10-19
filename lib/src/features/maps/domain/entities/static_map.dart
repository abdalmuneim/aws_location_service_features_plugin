import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/entities/map_style_options.dart';

/// Styles accepted by GetStaticMap.
enum StaticMapStyle {
  standard('Standard'),
  satellite('Satellite');

  const StaticMapStyle(this.apiValue);

  final String apiValue;
}

enum StaticLabelSize {
  small('Small'),
  large('Large');

  const StaticLabelSize(this.apiValue);

  final String apiValue;
}

enum ScaleBarUnit {
  off('Off', null),
  kilometers('Kilometers', 'Kilometers'),
  miles('Miles', 'Miles'),
  kilometersMiles('Km + Miles', 'KilometersMiles'),
  milesKilometers('Miles + Km', 'MilesKilometers');

  const ScaleBarUnit(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

/// How the static image is framed.
enum StaticFraming {
  centerZoom('Center & zoom'),
  centerRadius('Center & radius'),
  fitMarkers('Fit markers');

  const StaticFraming(this.label);

  final String label;
}

class StaticMapMarker extends Equatable {
  const StaticMapMarker({
    required this.position,
    this.label,
    this.colorHex = '#E53935',
  });

  final GeoPoint position;
  final String? label;
  final String colorHex;

  @override
  List<Object?> get props => [position, label, colorHex];
}

class StaticMapRequest extends Equatable {
  const StaticMapRequest({
    required this.center,
    this.framing = StaticFraming.centerZoom,
    this.zoom = 13,
    this.radiusMeters = 2000,
    this.markers = const [],
    this.connectMarkers = false,
    this.width = 640,
    this.height = 400,
    this.style = StaticMapStyle.standard,
    this.colorScheme = MapColorScheme.light,
    this.labelSize = StaticLabelSize.small,
    this.language,
    this.politicalView,
    this.showPointsOfInterest = true,
    this.scaleUnit = ScaleBarUnit.kilometers,
    this.cropLabels = false,
    this.padding = 40,
    this.highDpi = false,
  });

  final GeoPoint center;
  final StaticFraming framing;
  final double zoom;
  final int radiusMeters;
  final List<StaticMapMarker> markers;
  final bool connectMarkers;
  final int width;
  final int height;
  final StaticMapStyle style;
  final MapColorScheme colorScheme;
  final StaticLabelSize labelSize;
  final String? language;
  final String? politicalView;
  final bool showPointsOfInterest;
  final ScaleBarUnit scaleUnit;
  final bool cropLabels;
  final int padding;
  final bool highDpi;

  /// Label, language, color-scheme and POI options only apply to Standard.
  bool get isStandard => style == StaticMapStyle.standard;

  StaticMapRequest copyWith({
    GeoPoint? center,
    StaticFraming? framing,
    double? zoom,
    int? radiusMeters,
    List<StaticMapMarker>? markers,
    bool? connectMarkers,
    int? width,
    int? height,
    StaticMapStyle? style,
    MapColorScheme? colorScheme,
    StaticLabelSize? labelSize,
    String? language,
    bool clearLanguage = false,
    String? politicalView,
    bool clearPoliticalView = false,
    bool? showPointsOfInterest,
    ScaleBarUnit? scaleUnit,
    bool? cropLabels,
    int? padding,
    bool? highDpi,
  }) => StaticMapRequest(
    center: center ?? this.center,
    framing: framing ?? this.framing,
    zoom: zoom ?? this.zoom,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    markers: markers ?? this.markers,
    connectMarkers: connectMarkers ?? this.connectMarkers,
    width: width ?? this.width,
    height: height ?? this.height,
    style: style ?? this.style,
    colorScheme: colorScheme ?? this.colorScheme,
    labelSize: labelSize ?? this.labelSize,
    language: clearLanguage ? null : language ?? this.language,
    politicalView: clearPoliticalView
        ? null
        : politicalView ?? this.politicalView,
    showPointsOfInterest: showPointsOfInterest ?? this.showPointsOfInterest,
    scaleUnit: scaleUnit ?? this.scaleUnit,
    cropLabels: cropLabels ?? this.cropLabels,
    padding: padding ?? this.padding,
    highDpi: highDpi ?? this.highDpi,
  );

  @override
  List<Object?> get props => [
    center,
    framing,
    zoom,
    radiusMeters,
    markers,
    connectMarkers,
    width,
    height,
    style,
    colorScheme,
    labelSize,
    language,
    politicalView,
    showPointsOfInterest,
    scaleUnit,
    cropLabels,
    padding,
    highDpi,
  ];
}

class StaticMapImage extends Equatable {
  const StaticMapImage({required this.bytes, required this.url});

  final Uint8List bytes;

  /// The request URL with the API key redacted, for display.
  final String url;

  @override
  List<Object?> get props => [bytes.length, url];
}
