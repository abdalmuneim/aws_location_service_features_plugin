import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../../domain/entities/app_settings.dart';

/// JSON (de)serialization for [AppSettings].
abstract final class AppSettingsModel {
  static Map<String, Object?> toJson(AppSettings s) => {
    'apiKey': s.apiKey,
    'region': s.region,
    'language': s.language,
    'politicalView': s.politicalView,
    'units': s.units.name,
    'theme': s.theme.name,
    'mapStyle': {
      'style': s.mapStyle.style.name,
      'colorScheme': s.mapStyle.colorScheme.name,
      'terrain': s.mapStyle.terrain.name,
      'contourDensity': s.mapStyle.contourDensity.name,
      'traffic': s.mapStyle.traffic,
      'travelModes': s.mapStyle.travelModes.name,
    },
  };

  static AppSettings fromJson(Map<String, dynamic> json, AppSettings fallback) {
    final map = json['mapStyle'] is Map<String, dynamic>
        ? json['mapStyle'] as Map<String, dynamic>
        : const <String, dynamic>{};
    T pick<T extends Enum>(List<T> values, Object? name, T orElse) =>
        values.where((v) => v.name == name).firstOrNull ?? orElse;
    final apiKey = (json['apiKey'] as String?)?.trim();
    final region = (json['region'] as String?)?.trim();
    return AppSettings(
      apiKey: apiKey == null || apiKey.isEmpty ? fallback.apiKey : apiKey,
      region: region == null || region.isEmpty ? fallback.region : region,
      language: json['language'] as String? ?? fallback.language,
      politicalView: json['politicalView'] as String?,
      units: pick(MeasurementUnits.values, json['units'], fallback.units),
      theme: pick(AppThemePreference.values, json['theme'], fallback.theme),
      mapStyle: MapStyleOptions(
        style: pick(MapStyle.values, map['style'], MapStyle.standard),
        colorScheme: pick(
          MapColorScheme.values,
          map['colorScheme'],
          MapColorScheme.light,
        ),
        terrain: pick(MapTerrain.values, map['terrain'], MapTerrain.none),
        contourDensity: pick(
          ContourDensity.values,
          map['contourDensity'],
          ContourDensity.none,
        ),
        traffic: map['traffic'] == true,
        travelModes: pick(
          TravelModesOverlay.values,
          map['travelModes'],
          TravelModesOverlay.none,
        ),
      ),
    );
  }
}
