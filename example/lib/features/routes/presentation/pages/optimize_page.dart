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
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/optimize_cubit.dart';
import '../widgets/route_controls.dart';

/// OptimizeWaypoints: the best order to visit a set of stops.
class OptimizePage extends StatelessWidget {
  const OptimizePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => OptimizeCubit(sl(), sl()),
    child: const _OptimizeView(),
  );
}

class _OptimizeView extends StatefulWidget {
  const _OptimizeView();

  @override
  State<_OptimizeView> createState() => _OptimizeViewState();
}

class _OptimizeViewState extends State<_OptimizeView> {
  AwsMapController? _map;

  /// Display name for a stop id from [OptimizeCubit.stopId]; other ids (as
  /// returned by the API) are shown unchanged.
  String _stopName(AppLocalizations l10n, String id, int stopCount) {
    for (var i = 0; i < stopCount; i++) {
      if (OptimizeCubit.stopId(i) == id) return l10n.optimizeStopName(i + 1);
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocConsumer<OptimizeCubit, OptimizeState>(
      listenWhen: (a, b) => a.path != b.path && b.path.isNotEmpty,
      listener: (_, s) => _map?.fitPoints(s.path),
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<OptimizeCubit>();
        final order = s.visitOrder;
        return MapScaffold(
          title: l10n.optimizeTitle,
          loading: s.status.isLoading,
          actions: [
            IconButton(
              tooltip: l10n.commonClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: cubit.clear,
            ),
          ],
          map: AppMapView(
            onMapReady: (c) => _map = c,
            onTap: cubit.tapAt,
            overlay: MapOverlay(
              polylines: [
                if (s.path.isNotEmpty)
                  MapPolyline(
                    id: 'tour',
                    points: s.path,
                    color: MapColors.primary,
                  ),
              ],
              markers: [
                if (s.start != null)
                  MapMarker(
                    id: 'start',
                    position: s.start!.point,
                    color: MapColors.origin,
                    label: 'S',
                    radius: 12,
                  ),
                if (s.end != null)
                  MapMarker(
                    id: 'end',
                    position: s.end!.point,
                    color: MapColors.destination,
                    label: 'E',
                    radius: 12,
                  ),
                for (final (i, stop) in s.stops.indexed)
                  MapMarker(
                    id: OptimizeCubit.stopId(i),
                    position: stop.point,
                    color: MapColors.waypoint,
                    label: '${order[OptimizeCubit.stopId(i)] ?? i + 1}',
                    radius: 11,
                  ),
              ],
            ),
          ),
          mapBanner: MapHint(
            s.start == null ? l10n.routeTapStart : l10n.optimizeTapStops,
          ),
          panel: [
            LocationField(
              icon: Icons.trip_origin,
              iconColor: MapColors.origin,
              hint: l10n.routeStart,
              value: s.start,
              onPick: () async {
                final l = await pickLocation(
                  context,
                  title: l10n.routeStart,
                  initial: s.start,
                  center: _map?.center,
                );
                if (l != null) cubit.setStart(l);
              },
            ),
            LocationField(
              icon: Icons.flag,
              iconColor: MapColors.destination,
              hint: s.roundTrip
                  ? l10n.optimizeReturnToStart
                  : l10n.optimizeEndAnywhere,
              value: s.end,
              onPick: () async {
                final l = await pickLocation(
                  context,
                  title: l10n.optimizeEnd,
                  initial: s.end,
                  center: _map?.center,
                );
                if (l != null) cubit.setEnd(l);
              },
              onClear: () => cubit.setEnd(null),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.optimizeRoundTrip),
              value: s.roundTrip,
              onChanged: cubit.setRoundTrip,
            ),
            SectionTitle(
              l10n.optimizeStops(s.stops.length),
              trailing: TextButton.icon(
                icon: const Icon(Icons.search, size: 18),
                label: Text(l10n.commonSearch),
                onPressed: () async {
                  final l = await pickLocation(
                    context,
                    title: l10n.routeAddStop,
                    center: _map?.center,
                  );
                  if (l != null) cubit.addStop(l);
                },
              ),
            ),
            for (final (i, stop) in s.stops.indexed)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: MapColors.waypoint,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 11)),
                ),
                title: Text(l10n.optimizeStopName(i + 1)),
                subtitle: Text(stop.label, maxLines: 1),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => cubit.removeStop(i),
                ),
              ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TravelModeSelector(
                value: s.travelMode,
                onChanged: cubit.setTravelMode,
              ),
            ),
            const SizedBox(height: 8),
            OptimizationSelector(
              value: s.optimizeFor,
              onChanged: cubit.setOptimization,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.optimizeRun),
              onPressed:
                  s.start == null || s.stops.isEmpty || s.status.isLoading
                  ? null
                  : cubit.optimize,
            ),
            if (s.failure != null) FailureBanner(failure: s.failure!),
            if (s.tour != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  StatChip(
                    icon: Icons.route,
                    label: Formatters.distance(l10n, s.tour!.distance, units),
                  ),
                  StatChip(
                    icon: Icons.timer_outlined,
                    label: Formatters.duration(l10n, s.tour!.duration),
                  ),
                ],
              ),
              SectionTitle(l10n.optimizeResult),
              for (final (i, stop) in s.tour!.stops.indexed)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 14, child: Text('$i')),
                  title: Text(_stopName(l10n, stop.id, s.stops.length)),
                  subtitle: Text(
                    [
                      if (stop.arrival != null)
                        l10n.optimizeArrive(
                          Formatters.time(l10n, stop.arrival),
                        ),
                      if (stop.departure != null)
                        l10n.optimizeDepart(
                          Formatters.time(l10n, stop.departure),
                        ),
                    ].join(' · '),
                  ),
                  trailing: i == 0 || i > s.tour!.connections.length
                      ? null
                      : Text(
                          '${Formatters.distance(l10n, s.tour!.connections[i - 1].distance, units)}\n'
                          '${Formatters.duration(l10n, s.tour!.connections[i - 1].duration)}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 12),
                        ),
                ),
              if (s.tour!.impedingStops.isNotEmpty)
                Text(
                  l10n.optimizeCouldNotVisit(
                    s.tour!.impedingStops
                        .map((id) => _stopName(l10n, id, s.stops.length))
                        .join(', '),
                  ),
                ),
              JsonViewer(
                data: s.tour!.raw,
                title: l10n.commonApiResponse('OptimizeWaypoints'),
              ),
            ],
          ],
        );
      },
    );
  }
}
