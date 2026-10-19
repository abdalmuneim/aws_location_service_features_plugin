import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../routes/presentation/widgets/route_controls.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/tracker_cubit.dart';

/// Live (GPS) or simulated tracking with geofence ENTER/EXIT events.
class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => TrackerCubit(sl(), sl(), sl(), sl(), sl(), sl())..init(),
    child: const _TrackerView(),
  );
}

class _TrackerView extends StatefulWidget {
  const _TrackerView();

  @override
  State<_TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends State<_TrackerView> {
  AwsMapController? _map;
  bool _follow = true;

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocConsumer<TrackerCubit, TrackerState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          a.current != b.current ||
          (b.events.isNotEmpty && a.events.length != b.events.length),
      listener: (context, s) {
        if (s.failure != null) {
          showSnack(context, s.failure!.localizedMessage(context.l10n));
        }
        if (_follow && s.current != null) _map?.moveTo(s.current!.point);
        // Announce events produced by the newest position.
        final e = s.events.firstOrNull;
        if (e != null && e.time == s.current?.timestamp) {
          showSnack(
            context,
            '${e.transition._label(context.l10n)} · ${e.geofenceName}',
          );
        }
      },
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<TrackerCubit>();
        final sim = s.source == TrackingSource.simulation;
        return MapScaffold(
          title: l10n.trackerTitle,
          loading: s.status.isLoading,
          map: AppMapView(
            initialZoom: 14,
            onMapReady: (c) => _map = c,
            onTap: cubit.tapAt,
            overlay: MapOverlay(
              polygons: [
                for (final g in s.geofences)
                  MapPolygon(
                    id: g.id,
                    rings: [g.shape.outline],
                    fillColor: Color(g.colorValue),
                    fillOpacity: s.inside.contains(g.id) ? 0.4 : 0.12,
                    strokeWidth: s.inside.contains(g.id) ? 4 : 2,
                  ),
              ],
              polylines: [
                if (s.trail.length >= 2)
                  MapPolyline(
                    id: 'trail',
                    points: s.trail,
                    color: MapColors.trace,
                    width: 4,
                  ),
                if (s.snapped.length >= 2)
                  MapPolyline(
                    id: 'snapped',
                    points: s.snapped,
                    color: MapColors.primary,
                    width: 5,
                  ),
              ],
              markers: [
                if (sim && s.simFrom != null)
                  MapMarker(
                    id: 'from',
                    position: s.simFrom!,
                    color: MapColors.origin,
                    label: 'A',
                    radius: 11,
                  ),
                if (sim && s.simTo != null)
                  MapMarker(
                    id: 'to',
                    position: s.simTo!,
                    color: MapColors.destination,
                    label: 'B',
                    radius: 11,
                  ),
                if (s.current != null)
                  MapMarker(
                    id: 'device',
                    position: s.current!.point,
                    color: MapColors.device,
                    radius: 10,
                  ),
              ],
            ),
          ),
          mapBanner: sim && !s.tracking
              ? MapHint(
                  s.simFrom == null
                      ? l10n.trackerTapStart
                      : s.simTo == null
                      ? l10n.trackerTapEnd
                      : l10n.trackerReady,
                )
              : null,
          mapControls: [
            MapControlButton(
              icon: _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
              tooltip: l10n.trackerFollow,
              selected: _follow,
              onPressed: () => setState(() => _follow = !_follow),
            ),
          ],
          panel: [
            SegmentedButton<TrackingSource>(
              segments: [
                ButtonSegment(
                  value: TrackingSource.simulation,
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: Text(l10n.trackerSimulate),
                ),
                ButtonSegment(
                  value: TrackingSource.gps,
                  icon: const Icon(Icons.gps_fixed),
                  label: Text(l10n.trackerDeviceGps),
                ),
              ],
              selected: {s.source},
              onSelectionChanged: (v) => cubit.setSource(v.first),
            ),
            if (sim) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TravelModeSelector(
                  value: s.simMode,
                  onChanged: cubit.setSimMode,
                ),
              ),
              SectionTitle(l10n.trackerPlaybackSpeed(s.speedUp)),
              Slider(
                value: s.speedUp.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                onChanged: (v) => cubit.setSpeedUp(v.round()),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: s.tracking
                      ? FilledButton.tonalIcon(
                          icon: const Icon(Icons.stop),
                          label: Text(l10n.trackerStop),
                          onPressed: cubit.stop,
                        )
                      : FilledButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: Text(l10n.trackerStart),
                          onPressed: cubit.start,
                        ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.alt_route),
                  label: Text(l10n.trackerSnapTrail),
                  onPressed: s.positions.length >= 2 && !s.tracking
                      ? cubit.snapTrail
                      : null,
                ),
              ],
            ),
            if (s.current != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatChip(
                    icon: Icons.route,
                    label: Formatters.distance(l10n, s.distance, units),
                  ),
                  StatChip(
                    icon: Icons.timer_outlined,
                    label: Formatters.duration(l10n, s.elapsed.inSeconds),
                  ),
                  StatChip(
                    icon: Icons.speed,
                    label: Formatters.speed(l10n, s.current!.speedMps, units),
                  ),
                  StatChip(
                    icon: Icons.scatter_plot,
                    label: l10n.trackerFixesCount(s.positions.length),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined),
                title: Text(s.address ?? l10n.trackerLocatingAddress),
                subtitle: Text(
                  '${Formatters.point(s.current!.point)} · '
                  '${Formatters.time(l10n, s.current!.timestamp)}',
                ),
              ),
            ],
            SectionTitle(
              l10n.trackerGeofences(s.geofences.length),
              trailing: s.inside.isEmpty
                  ? null
                  : Text(l10n.trackerInsideCount(s.inside.length)),
            ),
            if (s.geofences.isEmpty) Text(l10n.trackerNoGeofences),
            SectionTitle(l10n.trackerEvents(s.events.length)),
            for (final e in s.events.take(30))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  e.transition == GeofenceTransition.enter
                      ? Icons.login
                      : Icons.logout,
                  color: e.transition == GeofenceTransition.enter
                      ? MapColors.origin
                      : MapColors.destination,
                ),
                title: Text('${e.transition._label(l10n)} · ${e.geofenceName}'),
                subtitle: Text(
                  '${Formatters.time(l10n, e.time)} · '
                  '${Formatters.point(e.position)}',
                ),
              ),
          ],
        );
      },
    );
  }
}

extension on GeofenceTransition {
  String _label(AppLocalizations l10n) => switch (this) {
    GeofenceTransition.enter => l10n.trackerEventEnter,
    GeofenceTransition.exit => l10n.trackerEventExit,
  };
}
