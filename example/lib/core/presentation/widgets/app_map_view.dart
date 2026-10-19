import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../injection_container.dart';
import '../../config/aws_config.dart';

/// The plugin's [AwsMapView] with this app's defaults: the style follows
/// the user's map settings unless [styleOverride] is set, and maps open on
/// [AwsConfig.defaultCenter].
class AppMapView extends StatelessWidget {
  const AppMapView({
    super.key,
    this.overlay = const MapOverlay(),
    this.initialCenter,
    this.initialZoom = AwsConfig.defaultZoom,
    this.styleOverride,
    this.onTap,
    this.onLongPress,
    this.onMarkerTap,
    this.onMapReady,
    this.onCameraIdle,
  });

  final MapOverlay overlay;
  final GeoPoint? initialCenter;
  final double initialZoom;
  final MapStyleOptions? styleOverride;
  final ValueChanged<GeoPoint>? onTap;
  final ValueChanged<GeoPoint>? onLongPress;
  final ValueChanged<MapMarker>? onMarkerTap;
  final ValueChanged<AwsMapController>? onMapReady;
  final ValueChanged<AwsMapController>? onCameraIdle;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final styleUrl = sl<GetMapStyleUrl>()(
      MapStyleParams(
        options: styleOverride ?? settings.mapStyle,
        politicalView: settings.politicalView,
      ),
    );
    return AwsMapView(
      styleUrl: styleUrl,
      overlay: overlay,
      initialCenter: initialCenter ?? AwsConfig.defaultCenter,
      initialZoom: initialZoom,
      onTap: onTap,
      onLongPress: onLongPress,
      onMarkerTap: onMarkerTap,
      onMapReady: onMapReady,
      onCameraIdle: onCameraIdle,
    );
  }
}
