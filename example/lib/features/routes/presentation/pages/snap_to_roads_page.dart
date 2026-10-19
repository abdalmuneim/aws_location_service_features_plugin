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
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/snap_cubit.dart';
import '../widgets/route_controls.dart';

/// SnapToRoads: matches a noisy GPS trace to the road network.
class SnapToRoadsPage extends StatelessWidget {
  const SnapToRoadsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SnapCubit(sl(), sl()),
    child: const _SnapView(),
  );
}

class _SnapView extends StatefulWidget {
  const _SnapView();

  @override
  State<_SnapView> createState() => _SnapViewState();
}

class _SnapViewState extends State<_SnapView> {
  AwsMapController? _map;

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocConsumer<SnapCubit, SnapState>(
      listenWhen: (a, b) => a.trace.length + 2 < b.trace.length,
      listener: (_, s) => _map?.fitPoints(s.trace.map((t) => t.position)),
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<SnapCubit>();
        final raw = [for (final t in s.trace) t.position];
        final dense = s.trace.length > 60;
        return MapScaffold(
          title: l10n.snapTitle,
          loading: s.status.isLoading,
          map: AppMapView(
            onMapReady: (c) => _map = c,
            onTap: cubit.addPoint,
            overlay: MapOverlay(
              polylines: [
                if (raw.length >= 2)
                  MapPolyline(
                    id: 'trace',
                    points: raw,
                    color: MapColors.trace,
                    width: 2,
                    dashed: true,
                    casing: false,
                  ),
                if (s.result != null && s.result!.geometry.length >= 2)
                  MapPolyline(
                    id: 'snapped',
                    points: s.result!.geometry,
                    color: MapColors.primary,
                    width: 6,
                  ),
              ],
              // Dense traces show only the dashed line: hundreds of dots would
              // bury the snapped line drawn beneath them.
              markers: [
                if (!dense) ...[
                  for (final (i, p) in raw.indexed)
                    MapMarker(
                      id: 'raw-$i',
                      position: p,
                      color: MapColors.trace,
                      radius: 5,
                    ),
                  for (final (i, p) in (s.result?.points ?? const []).indexed)
                    MapMarker(
                      id: 'snap-$i',
                      position: p.snapped,
                      color: MapColors.primary,
                      radius: 4,
                    ),
                ],
              ],
            ),
          ),
          mapBanner: MapHint(l10n.snapTapHint),
          panel: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.snapTracePointsCount(s.trace.length)} · '
                    '${Formatters.distance(l10n, GeoUtils.pathLength(raw), units)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonUndo,
                  icon: const Icon(Icons.undo),
                  onPressed: s.trace.isEmpty ? null : cubit.undo,
                ),
                IconButton(
                  tooltip: l10n.commonClear,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: s.trace.isEmpty ? null : cubit.clear,
                ),
              ],
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.scatter_plot_outlined),
              label: Text(l10n.snapGenerateNoisyTrace),
              onPressed: s.trace.length >= 2 && !s.status.isLoading
                  ? cubit.generateNoisyTrace
                  : null,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TravelModeSelector(
                value: s.travelMode,
                onChanged: cubit.setTravelMode,
              ),
            ),
            SectionTitle(l10n.snapRadius(Formatters.number(l10n, s.radius))),
            Slider(
              value: s.radius.toDouble(),
              min: 10,
              max: 500,
              divisions: 49,
              onChanged: (v) => cubit.setRadius(v.round()),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.alt_route),
              label: Text(l10n.snapRun),
              onPressed: s.trace.length >= 2 && !s.status.isLoading
                  ? cubit.snap
                  : null,
            ),
            if (s.failure != null) FailureBanner(failure: s.failure!),
            if (s.result != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatChip(
                    icon: Icons.verified_outlined,
                    label: l10n.snapConfidence(
                      Formatters.number(l10n, s.averageConfidence * 100),
                    ),
                  ),
                  StatChip(
                    icon: Icons.route,
                    label: Formatters.distance(
                      l10n,
                      GeoUtils.pathLength(s.result!.geometry),
                      units,
                    ),
                  ),
                ],
              ),
              for (final n in s.result!.notices)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.warning_amber),
                  title: Text(n),
                ),
              SectionTitle(l10n.snapSnappedPoints),
              for (final (i, p) in s.result!.points.take(50).indexed)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text('#${i + 1}'),
                  title: Text(Formatters.point(p.snapped)),
                  subtitle: Text(
                    l10n.snapMoved(
                      Formatters.distance(
                        l10n,
                        GeoUtils.distance(p.original, p.snapped),
                        units,
                      ),
                    ),
                  ),
                  trailing: SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(value: p.confidence),
                  ),
                ),
              JsonViewer(
                data: s.result!.raw,
                title: l10n.commonApiResponse('SnapToRoads'),
              ),
            ],
          ],
        );
      },
    );
  }
}
