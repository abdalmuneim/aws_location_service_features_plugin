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
import '../../../routes/presentation/pages/isolines_page.dart';
import '../../../tracking/presentation/pages/tracker_page.dart';
import '../cubit/geofences_cubit.dart';

/// Draw, store and test geofences (circle, polygon or isoline-based).
class GeofencesPage extends StatelessWidget {
  const GeofencesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GeofencesCubit(sl(), sl(), sl(), sl(), sl())..load(),
    child: const _GeofencesView(),
  );
}

class _GeofencesView extends StatefulWidget {
  const _GeofencesView();

  @override
  State<_GeofencesView> createState() => _GeofencesViewState();
}

class _GeofencesViewState extends State<_GeofencesView> {
  final _name = TextEditingController();
  AwsMapController? _map;
  bool _fitted = false;

  /// Frames the saved geofences once, as soon as both map and data exist.
  void _fitOnce(GeofencesState s) {
    if (_fitted || _map == null || s.geofences.isEmpty) return;
    _fitted = true;
    _map!.fitPoints(s.geofences.expand((g) => g.shape.outline));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  int _nextColor(GeofencesState s) => MapColors
      .geofences[s.geofences.length % MapColors.geofences.length]
      .toARGB32();

  Future<void> _save(GeofencesCubit cubit) async {
    final s = cubit.state;
    final l10n = context.l10n;
    final name = _name.text.trim().isEmpty
        ? l10n.geofencesDefaultName(s.tool._label(l10n), s.geofences.length + 1)
        : _name.text.trim();
    if (await cubit.saveDraft(name, _nextColor(s))) _name.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeofencesCubit, GeofencesState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          (!_fitted && b.geofences.isNotEmpty),
      listener: (context, s) {
        if (s.failure != null) {
          showSnack(context, s.failure!.localizedMessage(context.l10n));
        }
        _fitOnce(s);
      },
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<GeofencesCubit>();
        final draftColor = Color(_nextColor(s));
        return MapScaffold(
          title: l10n.geofencesTitle,
          loading: s.status.isLoading,
          actions: [
            IconButton(
              tooltip: l10n.geofencesOpenTracker,
              icon: const Icon(Icons.track_changes),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackerPage()),
              ),
            ),
          ],
          map: AppMapView(
            onMapReady: (c) {
              _map = c;
              _fitOnce(s);
            },
            onTap: cubit.tap,
            overlay: MapOverlay(
              polygons: [
                for (final g in s.geofences)
                  MapPolygon(
                    id: g.id,
                    rings: [g.shape.outline],
                    fillColor: Color(g.colorValue),
                    fillOpacity: s.inside.contains(g.id) ? 0.4 : 0.15,
                    strokeWidth: s.inside.contains(g.id) ? 4 : 2,
                  ),
                if (s.tool == GeofenceTool.circle && s.circleCenter != null)
                  MapPolygon(
                    id: 'draft-circle',
                    rings: [GeoUtils.circle(s.circleCenter!, s.radius)],
                    fillColor: draftColor,
                    fillOpacity: 0.25,
                  ),
                if (s.tool == GeofenceTool.polygon && s.vertices.length >= 3)
                  MapPolygon(
                    id: 'draft-polygon',
                    rings: [s.vertices],
                    fillColor: draftColor,
                    fillOpacity: 0.25,
                  ),
              ],
              polylines: [
                if (s.tool == GeofenceTool.polygon && s.vertices.length == 2)
                  MapPolyline(
                    id: 'draft-edge',
                    points: s.vertices,
                    color: draftColor,
                    width: 3,
                    dashed: true,
                    casing: false,
                  ),
              ],
              markers: [
                if (s.tool == GeofenceTool.polygon)
                  for (final (i, v) in s.vertices.indexed)
                    MapMarker(
                      id: 'v$i',
                      position: v,
                      color: draftColor,
                      radius: 6,
                    ),
                if (s.tool == GeofenceTool.circle && s.circleCenter != null)
                  MapMarker(
                    id: 'cc',
                    position: s.circleCenter!,
                    color: draftColor,
                    radius: 6,
                  ),
                if (s.testPoint != null)
                  MapMarker(
                    id: 'test',
                    position: s.testPoint!,
                    color: s.inside.isEmpty
                        ? MapColors.alternative
                        : MapColors.origin,
                    radius: 10,
                  ),
              ],
            ),
          ),
          mapBanner: MapHint(switch (s.tool) {
            GeofenceTool.test => l10n.geofencesTapTest,
            GeofenceTool.circle => l10n.geofencesTapCircle,
            GeofenceTool.polygon => l10n.geofencesTapPolygon,
          }),
          panel: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.geofencesInfo,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<GeofenceTool>(
              segments: [
                ButtonSegment(
                  value: GeofenceTool.test,
                  icon: const Icon(Icons.ads_click),
                  label: Text(l10n.geofencesToolTest),
                ),
                ButtonSegment(
                  value: GeofenceTool.circle,
                  icon: const Icon(Icons.circle_outlined),
                  label: Text(l10n.geofencesShapeCircle),
                ),
                ButtonSegment(
                  value: GeofenceTool.polygon,
                  icon: const Icon(Icons.pentagon_outlined),
                  label: Text(l10n.geofencesShapePolygon),
                ),
              ],
              selected: {s.tool},
              onSelectionChanged: (v) => cubit.setTool(v.first),
            ),
            if (s.tool == GeofenceTool.test && s.testPoint != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  s.inside.isEmpty
                      ? l10n.geofencesOutsideAll
                      : l10n.geofencesInside(
                          s.geofences
                              .where((g) => s.inside.contains(g.id))
                              .map((g) => g.name)
                              .join(', '),
                        ),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            if (s.tool == GeofenceTool.circle) ...[
              SectionTitle(
                l10n.commonRadius(Formatters.distance(l10n, s.radius)),
              ),
              Slider(
                value: s.radius,
                min: 50,
                max: 10000,
                divisions: 199,
                onChanged: cubit.setRadius,
              ),
            ],
            if (s.tool == GeofenceTool.polygon)
              Row(
                children: [
                  Text(l10n.geofencesVerticesCount(s.vertices.length)),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.undo),
                    label: Text(l10n.commonUndo),
                    onPressed: s.vertices.isEmpty ? null : cubit.undoVertex,
                  ),
                ],
              ),
            if (s.tool != GeofenceTool.test) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l10n.geofencesName,
                  hintText: l10n.geofencesNameHint,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.geofencesSave),
                onPressed: s.hasDraft ? () => _save(cubit) : null,
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.blur_circular),
              label: Text(l10n.geofencesFromIsoline),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IsolinesPage()),
                );
                cubit.load();
              },
            ),
            SectionTitle(
              l10n.geofencesCount(s.geofences.length),
              trailing: s.geofences.isEmpty
                  ? null
                  : TextButton(
                      onPressed: cubit.clearAll,
                      child: Text(l10n.geofencesDeleteAll),
                    ),
            ),
            if (s.geofences.isEmpty)
              EmptyHint(icon: Icons.fence, message: l10n.geofencesEmpty),
            for (final g in s.geofences)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(g.colorValue),
                  child: Icon(
                    switch (g.source) {
                      GeofenceSource.circle => Icons.circle_outlined,
                      GeofenceSource.polygon => Icons.pentagon_outlined,
                      GeofenceSource.isoline => Icons.blur_circular,
                    },
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(g.name),
                subtitle: Text(
                  [
                    switch (g.shape) {
                      CircleShape(:final radiusMeters) =>
                        '${l10n.geofencesShapeCircle} · '
                            '${Formatters.distance(l10n, radiusMeters)}',
                      PolygonShape(:final vertices) =>
                        '${l10n.geofencesShapePolygon} · '
                            '${l10n.geofencesVerticesCount(vertices.length)}',
                    },
                    if (g.description != null) g.description!,
                  ].join(' · '),
                  maxLines: 2,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => cubit.delete(g.id),
                ),
                onTap: () => _map?.fitPoints(g.shape.outline),
              ),
          ],
        );
      },
    );
  }
}

extension on GeofenceTool {
  String _label(AppLocalizations l10n) => switch (this) {
    GeofenceTool.test => l10n.geofencesToolTest,
    GeofenceTool.circle => l10n.geofencesShapeCircle,
    GeofenceTool.polygon => l10n.geofencesShapePolygon,
  };
}
