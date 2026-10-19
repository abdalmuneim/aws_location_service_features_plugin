import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../cubit/nearby_cubit.dart';
import '../widgets/place_actions.dart';
import '../widgets/place_details_sheet.dart';
import '../widgets/place_icons.dart';
import '../widgets/place_labels.dart';
import '../widgets/place_tile.dart';

/// SearchNearby: points of interest around a center, filtered by category.
class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key, this.center});

  final GeoPoint? center;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        NearbyCubit(sl(), center ?? AwsConfig.defaultCenter)..search(),
    child: _NearbyView(center: center ?? AwsConfig.defaultCenter),
  );
}

class _NearbyView extends StatefulWidget {
  const _NearbyView({required this.center});

  final GeoPoint center;

  @override
  State<_NearbyView> createState() => _NearbyViewState();
}

class _NearbyViewState extends State<_NearbyView> {
  AwsMapController? _map;

  void _open(Place p) {
    if (p.position != null) _map?.moveTo(p.position!, zoom: 17);
    showPlaceDetailsSheet(context, p, actions: placeActions(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyCubit, NearbyState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<NearbyCubit>();
        return MapScaffold(
          title: l10n.nearbyTitle,
          loading: state.status.isLoading,
          map: AppMapView(
            initialCenter: widget.center,
            initialZoom: 14,
            onMapReady: (c) => _map = c,
            onTap: cubit.setCenter,
            onMarkerTap: (m) {
              final p = state.places
                  .where((p) => p.placeId == m.id)
                  .firstOrNull;
              if (p != null) _open(p);
            },
            overlay: MapOverlay(
              polygons: [
                MapPolygon(
                  id: 'radius',
                  rings: [
                    GeoUtils.circle(state.center, state.radius.toDouble()),
                  ],
                  fillOpacity: 0.08,
                ),
              ],
              markers: [
                MapMarker(
                  id: 'center',
                  position: state.center,
                  color: MapColors.device,
                  radius: 8,
                ),
                for (final (i, p) in state.places.indexed)
                  if (p.position != null)
                    MapMarker(
                      id: p.placeId,
                      position: p.position!,
                      color: MapColors.result,
                      label: '${i + 1}',
                      radius: 10,
                    ),
              ],
            ),
          ),
          mapBanner: MapHint(l10n.nearbyTapHint),
          panel: [
            Text(
              l10n.commonRadius(Formatters.distance(l10n, state.radius)),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: state.radius.toDouble(),
              min: 100,
              max: 20000,
              divisions: 199,
              label: Formatters.distance(l10n, state.radius),
              onChanged: (v) => cubit.setRadius(v.round()),
              onChangeEnd: (_) => cubit.search(),
            ),
            SectionTitle(
              l10n.nearbyCategories,
              trailing: state.categories.isEmpty
                  ? null
                  : TextButton(
                      onPressed: cubit.clearCategories,
                      child: Text(l10n.commonClear),
                    ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in nearbyCategories.entries)
                  FilterChip(
                    avatar: Icon(e.value, size: 16),
                    label: Text(nearbyCategoryLabel(l10n, e.key)),
                    selected: state.categories.contains(e.key),
                    onSelected: (_) => cubit.toggleCategory(e.key),
                  ),
              ],
            ),
            if (state.failure != null) FailureBanner(failure: state.failure!),
            SectionTitle(l10n.nearbyPlacesCount(state.places.length)),
            if (state.places.isEmpty && !state.status.isLoading)
              EmptyHint(
                icon: Icons.location_searching,
                message: l10n.nearbyEmpty,
              ),
            for (final (i, p) in state.places.indexed)
              PlaceTile(place: p, index: i, onTap: () => _open(p)),
            if (state.nextToken != null)
              Center(
                child: TextButton(
                  onPressed: cubit.loadMore,
                  child: Text(l10n.commonLoadMore),
                ),
              ),
            if (state.raw != null) JsonViewer(data: state.raw),
          ],
        );
      },
    );
  }
}
