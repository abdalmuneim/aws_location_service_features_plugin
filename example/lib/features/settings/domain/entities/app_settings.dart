import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/config/aws_config.dart';

enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemePreference(this.label);

  final String label;
}

/// User preferences, persisted between sessions.
class AppSettings extends Equatable {
  const AppSettings({
    required this.apiKey,
    required this.region,
    this.language = 'en',
    this.politicalView,
    this.units = MeasurementUnits.metric,
    this.theme = AppThemePreference.system,
    this.mapStyle = const MapStyleOptions(),
  });

  factory AppSettings.defaults() => const AppSettings(
    apiKey: AwsConfig.defaultApiKey,
    region: AwsConfig.defaultRegion,
  );

  final String apiKey;
  final String region;

  /// Preferred language for Places results and route instructions.
  final String language;

  /// ISO alpha-3 political view for maps & places, or null for the default.
  final String? politicalView;
  final MeasurementUnits units;
  final AppThemePreference theme;
  final MapStyleOptions mapStyle;

  AppSettings copyWith({
    String? apiKey,
    String? region,
    String? language,
    String? politicalView,
    bool clearPoliticalView = false,
    MeasurementUnits? units,
    AppThemePreference? theme,
    MapStyleOptions? mapStyle,
  }) => AppSettings(
    apiKey: apiKey ?? this.apiKey,
    region: region ?? this.region,
    language: language ?? this.language,
    politicalView: clearPoliticalView
        ? null
        : politicalView ?? this.politicalView,
    units: units ?? this.units,
    theme: theme ?? this.theme,
    mapStyle: mapStyle ?? this.mapStyle,
  );

  @override
  List<Object?> get props => [
    apiKey,
    region,
    language,
    politicalView,
    units,
    theme,
    mapStyle,
  ];
}
