import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/core_labels.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../places/presentation/widgets/place_actions.dart';
import '../../../places/presentation/widgets/place_details_sheet.dart';
import '../../../places/presentation/widgets/place_icons.dart';
import '../../../places/presentation/widgets/place_search_bar.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/map_explorer_cubit.dart';
import '../widgets/map_style_sheet.dart';

/// Interactive map: every style option, Suggest search, tap-to-inspect
/// (reverse geocoding) and quick links into the other APIs.
class MapExplorerPage extends StatelessWidget {
  const MapExplorerPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MapExplorerCubit(sl(), sl(), sl()),
    child: const _MapExplorerView(),
  );
}

class _MapExplorerView extends StatefulWidget {
  const _MapExplorerView();

  @override
  State<_MapExplorerView> createState() => _MapExplorerViewState();
}

class _MapExplorerViewState extends State<_MapExplorerView> {
  AwsMapController? _map;
  String _camera = '';

  GeoPoint _bias() => _map?.center ?? const GeoPoint(30.0444, 31.2357);

  List<PlaceAction> _actions(BuildContext context) => placeActions(context);

  void _details(Place place) =>
      showPlaceDetailsSheet(context, place, actions: _actions(context));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (style, colorScheme) = context.select(
      (SettingsCubit c) =>
          (c.state.mapStyle.style, c.state.mapStyle.colorScheme),
    );
    return BlocConsumer<MapExplorerCubit, MapExplorerState>(
      listenWhen: (a, b) => b.failure != null && a.failure != b.failure,
      listener: (context, s) =>
          showSnack(context, s.failure!.localizedMessage(context.l10n)),
      builder: (context, state) {
        final cubit = context.read<MapExplorerCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.mapExplorerTitle),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.layers),
                label: Text(
                  '${style.localizedLabel(l10n)} · '
                  '${colorScheme.localizedLabel(l10n)}',
                ),
                onPressed: () => showMapStyleSheet(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LoadingBar(visible: state.status.isLoading),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: AppMapView(
                  onMapReady: (c) => _map = c,
                  onCameraIdle: (c) => setState(
                    () => _camera = context.l10n.mapExplorerCamera(
                      c.zoom == null
                          ? '—'
                          : Formatters.number(context.l10n, c.zoom!, 1),
                      Formatters.point(c.center, 4),
                    ),
                  ),
                  onTap: cubit.inspect,
                  onMarkerTap: (m) {
                    final place = state.results
                        .where((p) => p.placeId == m.id)
                        .firstOrNull;
                    if (place != null) _details(place);
                  },
                  overlay: _overlay(state),
                ),
              ),
              PositionedDirectional(
                top: 12,
                start: 12,
                end: 72,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: OverMap(
                      child: PlaceSearchBar(
                        useSuggest: true,
                        biasPosition: _bias,
                        hintText: l10n.mapExplorerSearchHint,
                        onPlace: (p) {
                          cubit.showPlace(p);
                          _map?.moveTo(p.position!, zoom: 16);
                        },
                        onQuery: (s) async {
                          await cubit.searchQuery(s.title, s.queryId!);
                          _map?.fitPoints(
                            cubit.state.results.map((p) => p.position!),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 12,
                end: 12,
                child: OverMap(
                  child: Column(
                    children: [
                      MapControlButton(
                        icon: Icons.layers,
                        tooltip: l10n.mapStyleTitle,
                        onPressed: () => showMapStyleSheet(context),
                      ),
                      const SizedBox(height: 8),
                      MapControlButton(
                        icon: Icons.my_location,
                        tooltip: l10n.commonMyLocation,
                        onPressed: () async {
                          final p = await cubit.locate();
                          if (p != null) _map?.moveTo(p, zoom: 15);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_camera.isNotEmpty)
                PositionedDirectional(
                  start: 12,
                  top: 76,
                  child: OverMap(
                    child: MapHint(_camera, icon: Icons.center_focus_weak),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 28,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: OverMap(child: _bottomCard(context, state)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MapOverlay _overlay(MapExplorerState s) => MapOverlay(
    markers: [
      for (final (i, p) in s.results.indexed)
        if (p.position != null)
          MapMarker(
            id: p.placeId,
            position: p.position!,
            color: MapColors.result,
            label: s.results.length > 1 ? '${i + 1}' : null,
            title: p.title,
            radius: s.results.length > 1 ? 10 : 11,
          ),
      if (s.inspected != null)
        MapMarker(
          id: 'inspected',
          position: s.inspected!,
          color: MapColors.destination,
          radius: 8,
        ),
      if (s.myLocation != null)
        MapMarker(id: 'me', position: s.myLocation!, color: MapColors.device),
    ],
  );

  Widget _bottomCard(BuildContext context, MapExplorerState s) {
    final l10n = context.l10n;
    final cubit = context.read<MapExplorerCubit>();
    if (s.inspected != null) {
      final place = s.inspectedPlace;
      return Card(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.push_pin_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      place?.title ??
                          (s.status.isLoading
                              ? l10n.mapExplorerLookingUpAddress
                              : l10n.mapExplorerNoAddress),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: cubit.clear,
                  ),
                ],
              ),
              if (place?.address?.label != null)
                Text(place!.address!.label!, maxLines: 2),
              Text(
                [
                  Formatters.point(s.inspected, 5),
                  if (place?.timeZone != null) place!.timeZone!.name,
                ].join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: [
                  if (place != null)
                    TextButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: Text(l10n.commonDetails),
                      onPressed: () => _details(place),
                    ),
                  for (final a in _actions(context))
                    TextButton.icon(
                      icon: Icon(a.icon),
                      label: Text(a.label),
                      onPressed: () => a.onSelected(
                        Place(
                          placeId: place?.placeId ?? '',
                          placeType: place?.placeType ?? 'Point',
                          title: place?.title ?? s.inspected!.format(),
                          position: s.inspected,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    if (s.results.isNotEmpty) {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              title: Text(
                '${s.resultsTitle ?? l10n.commonResults} · ${s.results.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: cubit.clear,
              ),
            ),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: s.results.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final p = s.results[i];
                  return ActionChip(
                    avatar: Icon(placeTypeIcon(p.placeType), size: 18),
                    label: Text(
                      p.distance == null
                          ? p.title
                          : '${p.title} · ${Formatters.distance(l10n, p.distance)}',
                    ),
                    onPressed: () {
                      _map?.moveTo(p.position!, zoom: 16);
                      _details(p);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    return MapHint(l10n.mapExplorerTapHint);
  }
}
