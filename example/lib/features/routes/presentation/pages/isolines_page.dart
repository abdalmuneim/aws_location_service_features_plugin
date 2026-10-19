import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../places/presentation/pages/location_picker_page.dart';
import '../cubit/isolines_cubit.dart';
import '../widgets/route_controls.dart';

/// CalculateIsolines: areas reachable within time or distance thresholds.
class IsolinesPage extends StatelessWidget {
  const IsolinesPage({super.key, this.origin});

  final NamedLocation? origin;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => IsolinesCubit(sl(), sl(), origin: origin),
    child: _IsolinesView(initial: origin),
  );
}

class _IsolinesView extends StatefulWidget {
  const _IsolinesView({this.initial});

  final NamedLocation? initial;

  @override
  State<_IsolinesView> createState() => _IsolinesViewState();
}

class _IsolinesViewState extends State<_IsolinesView> {
  AwsMapController? _map;

  String _label(int value, ThresholdKind kind) => kind == ThresholdKind.time
      ? Formatters.duration(context.l10n, value)
      : Formatters.distance(context.l10n, value);

  Color _color(int index) => MapColors.ramp[index % MapColors.ramp.length];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IsolinesCubit, IsolinesState>(
      listenWhen: (a, b) =>
          (b.savedGeofence != null && a.savedGeofence != b.savedGeofence) ||
          (b.result != null && a.result != b.result),
      listener: (context, s) {
        if (s.savedGeofence != null) {
          showSnack(context, context.l10n.isolinesSaved(s.savedGeofence!));
        }
        final outer = s.result?.isolines.lastOrNull?.polygons.firstOrNull;
        if (outer != null && s.savedGeofence == null) {
          _map?.fitPoints(outer.first, padding: 40);
        }
      },
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<IsolinesCubit>();
        final isolines = s.result?.isolines ?? const <Isoline>[];
        final presets = s.kind == ThresholdKind.time
            ? IsolinesCubit.timePresets
            : IsolinesCubit.distancePresets;
        return MapScaffold(
          title: l10n.isolinesTitle,
          loading: s.status.isLoading,
          map: AppMapView(
            initialCenter: widget.initial?.point,
            onMapReady: (c) => _map = c,
            onTap: cubit.setOrigin,
            overlay: MapOverlay(
              polygons: [
                // Outermost first so inner areas draw on top.
                for (final (i, iso) in isolines.indexed.toList().reversed)
                  for (final (j, poly) in iso.polygons.indexed)
                    MapPolygon(
                      id: 'iso-$i-$j',
                      rings: poly,
                      fillColor: _color(i),
                      fillOpacity: 0.22,
                      strokeWidth: 2,
                    ),
              ],
              markers: [
                if (s.origin != null)
                  MapMarker(
                    id: 'origin',
                    position: s.origin!.point,
                    color: MapColors.device,
                    radius: 10,
                  ),
                if (s.result?.snappedOrigin != null)
                  MapMarker(
                    id: 'snapped',
                    position: s.result!.snappedOrigin!,
                    color: MapColors.origin,
                    radius: 5,
                  ),
              ],
            ),
          ),
          mapBanner: MapHint(l10n.isolinesTapHint),
          panel: [
            LocationField(
              icon: Icons.my_location,
              iconColor: MapColors.device,
              hint: l10n.isolinesChooseStart,
              value: s.origin,
              onPick: () async {
                final l = await pickLocation(
                  context,
                  title: l10n.isolinesStartingPoint,
                  initial: s.origin,
                );
                if (l != null) cubit.setNamedOrigin(l);
              },
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TravelModeSelector(
                value: s.travelMode,
                onChanged: cubit.setTravelMode,
              ),
            ),
            SectionTitle(l10n.isolinesThreshold),
            SegmentedButton<ThresholdKind>(
              segments: [
                ButtonSegment(
                  value: ThresholdKind.time,
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(l10n.isolinesTime),
                ),
                ButtonSegment(
                  value: ThresholdKind.distance,
                  icon: const Icon(Icons.straighten),
                  label: Text(l10n.commonDistance),
                ),
              ],
              selected: {s.kind},
              onSelectionChanged: (v) => cubit.setKind(v.first),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in presets)
                  FilterChip(
                    label: Text(_label(v, s.kind)),
                    selected: s.thresholds.contains(v),
                    onSelected: (_) => cubit.toggleThreshold(v),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.isolinesMaxThresholds(5),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (s.travelMode != TravelMode.pedestrian) ...[
              SectionTitle(l10n.routeAvoid),
              AvoidChips(value: s.avoid, onChanged: cubit.setAvoid),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.isolinesUseTraffic),
              value: s.useTraffic,
              onChanged: cubit.setTraffic,
            ),
            if (s.failure != null) FailureBanner(failure: s.failure!),
            if (isolines.isNotEmpty) ...[
              SectionTitle(l10n.isolinesReachableAreas),
              for (final (i, iso) in isolines.indexed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: _color(i), radius: 12),
                  title: Text(
                    l10n.isolinesWithin(_label(iso.threshold, iso.kind)),
                  ),
                  subtitle: Text(
                    '${l10n.isolinesPolygonsCount(iso.polygons.length)} · '
                    '${l10n.commonPointsCount(iso.polygons.fold<int>(0, (n, p) => n + (p.firstOrNull?.length ?? 0)))}',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.isolinesSaveAsGeofence,
                    icon: const Icon(Icons.fence),
                    onPressed: () => cubit.saveAsGeofence(
                      iso,
                      l10n.isolinesGeofenceName(
                        s.travelMode.localizedLabel(l10n),
                        _label(iso.threshold, iso.kind),
                      ),
                      _color(i).toARGB32(),
                      '${s.travelMode.localizedLabel(l10n)} · ${s.origin?.label}',
                    ),
                  ),
                ),
              JsonViewer(
                data: s.result!.raw,
                title: l10n.commonApiResponse('CalculateIsolines'),
              ),
            ],
          ],
        );
      },
    );
  }
}
