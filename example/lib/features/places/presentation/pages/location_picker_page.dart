import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../injection_container.dart';
import '../cubit/location_picker_cubit.dart';
import '../widgets/place_search_bar.dart';

/// Opens a full-screen picker and returns the chosen location.
Future<NamedLocation?> pickLocation(
  BuildContext context, {
  String? title,
  NamedLocation? initial,
  GeoPoint? center,
}) {
  return Navigator.of(context).push<NamedLocation>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => BlocProvider(
        create: (_) => LocationPickerCubit(sl(), sl(), initial: initial),
        child: LocationPickerPage(
          title: title,
          center: initial?.point ?? center,
        ),
      ),
    ),
  );
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.title, this.center});

  /// Defaults to a generic "Choose a location".
  final String? title;
  final GeoPoint? center;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  AwsMapController? _map;

  GeoPoint _bias() =>
      _map?.center ?? widget.center ?? const GeoPoint(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationPickerCubit, LocationPickerState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, state) =>
          showSnack(context, state.failure!.localizedMessage(context.l10n)),
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<LocationPickerCubit>();
        final selected = state.selected;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title ?? l10n.pickerTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LoadingBar(visible: state.loading),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: AppMapView(
                  initialCenter: widget.center,
                  initialZoom: widget.center == null ? 12 : 15,
                  onMapReady: (c) => _map = c,
                  onTap: cubit.selectPoint,
                  overlay: MapOverlay(
                    markers: [
                      if (selected != null)
                        MapMarker(
                          id: 'picked',
                          position: selected.point,
                          color: MapColors.destination,
                          radius: 11,
                        ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                end: 72,
                child: OverMap(
                  child: PlaceSearchBar(
                    biasPosition: _bias,
                    onPlace: (place) {
                      cubit.selectPlace(place);
                      _map?.moveTo(place.position!, zoom: 16);
                    },
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: OverMap(
                  child: MapControlButton(
                    icon: Icons.my_location,
                    tooltip: l10n.commonMyLocation,
                    onPressed: () async {
                      final p = await cubit.useMyLocation();
                      if (p != null) _map?.moveTo(p, zoom: 16);
                    },
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: OverMap(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selected?.label ?? l10n.pickerEmptyHint,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: selected == null
                                    ? null
                                    : () => Navigator.pop(context, selected),
                                child: Text(l10n.pickerUse),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
