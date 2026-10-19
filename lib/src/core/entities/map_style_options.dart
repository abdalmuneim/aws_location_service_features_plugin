import 'package:equatable/equatable.dart';

/// Map styles offered by the Amazon Location Maps API.
enum MapStyle {
  standard('Standard', 'Standard'),
  monochrome('Monochrome', 'Monochrome'),
  hybrid('Hybrid', 'Hybrid'),
  satellite('Satellite', 'Satellite');

  const MapStyle(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

enum MapColorScheme {
  light('Light', 'Light'),
  dark('Dark', 'Dark');

  const MapColorScheme(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

enum MapTerrain {
  none('Off', null),
  hillshade('Hillshade', 'Hillshade'),
  terrain3d('3D terrain', 'Terrain3D');

  const MapTerrain(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

enum ContourDensity {
  none('Off', null),
  low('Low', 'Low'),
  medium('Medium', 'Medium'),
  high('High', 'High');

  const ContourDensity(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

enum TravelModesOverlay {
  none('Off', null),
  transit('Transit', 'Transit'),
  truck('Truck', 'Truck');

  const TravelModesOverlay(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

/// Everything that shapes a GetStyleDescriptor request.
///
/// Not every style accepts every option (the API answers 400 otherwise), so
/// the `supports*` getters describe what the current [style] allows and
/// [sanitized] drops the rest.
class MapStyleOptions extends Equatable {
  const MapStyleOptions({
    this.style = MapStyle.standard,
    this.colorScheme = MapColorScheme.light,
    this.terrain = MapTerrain.none,
    this.contourDensity = ContourDensity.none,
    this.traffic = false,
    this.travelModes = TravelModesOverlay.none,
  });

  final MapStyle style;
  final MapColorScheme colorScheme;
  final MapTerrain terrain;
  final ContourDensity contourDensity;
  final bool traffic;
  final TravelModesOverlay travelModes;

  bool get supportsHillshade =>
      style == MapStyle.standard || style == MapStyle.monochrome;
  bool get supportsContours => style != MapStyle.satellite;
  bool get supportsTraffic => style != MapStyle.satellite;
  bool get supportsTravelModes => style != MapStyle.satellite;
  bool get supportsPoliticalView => style != MapStyle.satellite;

  MapStyleOptions sanitized() => MapStyleOptions(
    style: style,
    colorScheme: colorScheme,
    terrain: terrain == MapTerrain.hillshade && !supportsHillshade
        ? MapTerrain.none
        : terrain,
    contourDensity: supportsContours ? contourDensity : ContourDensity.none,
    traffic: supportsTraffic && traffic,
    travelModes: supportsTravelModes ? travelModes : TravelModesOverlay.none,
  );

  MapStyleOptions copyWith({
    MapStyle? style,
    MapColorScheme? colorScheme,
    MapTerrain? terrain,
    ContourDensity? contourDensity,
    bool? traffic,
    TravelModesOverlay? travelModes,
  }) => MapStyleOptions(
    style: style ?? this.style,
    colorScheme: colorScheme ?? this.colorScheme,
    terrain: terrain ?? this.terrain,
    contourDensity: contourDensity ?? this.contourDensity,
    traffic: traffic ?? this.traffic,
    travelModes: travelModes ?? this.travelModes,
  );

  @override
  List<Object?> get props => [
    style,
    colorScheme,
    terrain,
    contourDensity,
    traffic,
    travelModes,
  ];
}
