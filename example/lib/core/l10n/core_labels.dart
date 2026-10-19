import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../config/aws_config.dart';
import 'l10n.dart';

// UI names for core enums, in the current language. The enums' own `label`
// fields are English and are no longer used for display.

extension MeasurementUnitsL10n on MeasurementUnits {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MeasurementUnits.metric => l10n.unitsMetric,
    MeasurementUnits.imperial => l10n.unitsImperial,
  };
}

extension MapStyleL10n on MapStyle {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MapStyle.standard => l10n.mapStyleStandard,
    MapStyle.monochrome => l10n.mapStyleMonochrome,
    MapStyle.hybrid => l10n.mapStyleHybrid,
    MapStyle.satellite => l10n.mapStyleSatellite,
  };
}

extension MapColorSchemeL10n on MapColorScheme {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MapColorScheme.light => l10n.commonLight,
    MapColorScheme.dark => l10n.commonDark,
  };
}

extension MapTerrainL10n on MapTerrain {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MapTerrain.none => l10n.commonOff,
    MapTerrain.hillshade => l10n.mapTerrainHillshade,
    MapTerrain.terrain3d => l10n.mapTerrain3d,
  };
}

extension ContourDensityL10n on ContourDensity {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ContourDensity.none => l10n.commonOff,
    ContourDensity.low => l10n.mapContoursLow,
    ContourDensity.medium => l10n.mapContoursMedium,
    ContourDensity.high => l10n.mapContoursHigh,
  };
}

extension TravelModesOverlayL10n on TravelModesOverlay {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TravelModesOverlay.none => l10n.commonOff,
    TravelModesOverlay.transit => l10n.mapTravelModesTransit,
    TravelModesOverlay.truck => l10n.mapTravelModesTruck,
  };
}

/// Country name for an [AwsConfig.politicalViews] code (ISO alpha-3).
String politicalViewName(AppLocalizations l10n, String code) => switch (code) {
  'ARG' => l10n.countryArgentina,
  'CYP' => l10n.countryCyprus,
  'EGY' => l10n.countryEgypt,
  'GEO' => l10n.countryGeorgia,
  'GRC' => l10n.countryGreece,
  'IND' => l10n.countryIndia,
  'KEN' => l10n.countryKenya,
  'MAR' => l10n.countryMorocco,
  'PSE' => l10n.countryPalestine,
  'RUS' => l10n.countryRussia,
  'SDN' => l10n.countrySudan,
  'SRB' => l10n.countrySerbia,
  'SUR' => l10n.countrySuriname,
  'SYR' => l10n.countrySyria,
  'TUR' => l10n.countryTurkey,
  'TZA' => l10n.countryTanzania,
  'URY' => l10n.countryUruguay,
  'VNM' => l10n.countryVietnam,
  _ => AwsConfig.politicalViews[code] ?? code,
};
