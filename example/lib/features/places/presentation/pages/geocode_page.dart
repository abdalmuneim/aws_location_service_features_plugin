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
import '../cubit/geocode_cubit.dart';
import '../widgets/place_actions.dart';
import '../widgets/place_details_sheet.dart';
import '../widgets/place_labels.dart';
import '../widgets/place_tile.dart';

/// Geocode (free text or structured address) and ReverseGeocode.
class GeocodePage extends StatelessWidget {
  const GeocodePage({super.key, this.initialMode = GeocodeMode.text});

  final GeocodeMode initialMode;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GeocodeCubit(sl(), sl())..setMode(initialMode),
    child: const _GeocodeView(),
  );
}

class _GeocodeView extends StatefulWidget {
  const _GeocodeView();

  @override
  State<_GeocodeView> createState() => _GeocodeViewState();
}

class _GeocodeViewState extends State<_GeocodeView> {
  final _text = TextEditingController();
  final _fields = {
    for (final f in const [
      AddressField.country,
      AddressField.region,
      AddressField.subRegion,
      AddressField.locality,
      AddressField.district,
      AddressField.street,
      AddressField.number,
      AddressField.postalCode,
    ])
      f: TextEditingController(),
  };
  AwsMapController? _map;

  @override
  void dispose() {
    _text.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _f(AddressField field) {
    final v = _fields[field]!.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _run(GeocodeCubit cubit) async {
    switch (cubit.state.mode) {
      case GeocodeMode.text:
        await cubit.geocodeText(
          _text.text,
          _map?.center ?? AwsConfig.defaultCenter,
        );
      case GeocodeMode.structured:
        await cubit.geocodeComponents(
          AddressComponents(
            country: _f(AddressField.country)?.toUpperCase(),
            region: _f(AddressField.region),
            subRegion: _f(AddressField.subRegion),
            locality: _f(AddressField.locality),
            district: _f(AddressField.district),
            street: _f(AddressField.street),
            addressNumber: _f(AddressField.number),
            postalCode: _f(AddressField.postalCode),
          ),
        );
      case GeocodeMode.reverse:
        final p = cubit.state.reversePoint;
        if (p != null) await cubit.reverse(p);
        return;
    }
    final pts = cubit.state.results
        .map((p) => p.position)
        .whereType<GeoPoint>();
    if (pts.isNotEmpty) _map?.fitPoints(pts);
  }

  void _open(Place p) {
    if (p.position != null) _map?.moveTo(p.position!, zoom: 17);
    showPlaceDetailsSheet(context, p, actions: placeActions(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeocodeCubit, GeocodeState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<GeocodeCubit>();
        final reverse = state.mode == GeocodeMode.reverse;
        return MapScaffold(
          title: l10n.geocodeTitle,
          loading: state.status.isLoading,
          map: AppMapView(
            onMapReady: (c) => _map = c,
            onTap: reverse ? cubit.reverse : null,
            onMarkerTap: (m) {
              final p = state.results
                  .where((p) => p.placeId == m.id)
                  .firstOrNull;
              if (p != null) _open(p);
            },
            overlay: MapOverlay(
              polygons: [
                if (reverse && state.reversePoint != null)
                  MapPolygon(
                    id: 'radius',
                    rings: [
                      GeoUtils.circle(
                        state.reversePoint!,
                        state.reverseRadius.toDouble(),
                      ),
                    ],
                    fillOpacity: 0.08,
                  ),
              ],
              markers: [
                if (reverse && state.reversePoint != null)
                  MapMarker(
                    id: 'query',
                    position: state.reversePoint!,
                    color: MapColors.destination,
                    radius: 7,
                  ),
                for (final (i, p) in state.results.indexed)
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
          mapBanner: reverse ? MapHint(l10n.geocodeReverseTapHint) : null,
          panel: [
            SegmentedButton<GeocodeMode>(
              segments: [
                for (final m in GeocodeMode.values)
                  ButtonSegment(value: m, label: Text(m._label(l10n))),
              ],
              selected: {state.mode},
              onSelectionChanged: (v) => cubit.setMode(v.first),
            ),
            const SizedBox(height: 12),
            if (state.mode == GeocodeMode.text)
              TextField(
                controller: _text,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.home_work_outlined),
                  hintText: l10n.geocodeTextHint,
                ),
                onSubmitted: (_) => _run(cubit),
              ),
            if (state.mode == GeocodeMode.structured)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _fields.entries)
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          labelText: e.key == AddressField.country
                              ? l10n.geocodeCountryField
                              : e.key.localizedLabel(l10n),
                        ),
                      ),
                    ),
                ],
              ),
            if (reverse) ...[
              Text(
                l10n.geocodeSearchRadius(
                  Formatters.distance(l10n, state.reverseRadius),
                ),
              ),
              Slider(
                value: state.reverseRadius.toDouble(),
                min: 10,
                max: 5000,
                divisions: 100,
                onChanged: (v) => cubit.setReverseRadius(v.round()),
                onChangeEnd: (_) => _run(cubit),
              ),
              if (state.reversePoint != null)
                Text(
                  l10n.geocodeQueryPosition(
                    Formatters.point(state.reversePoint, 6),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            SectionTitle(l10n.geocodeMaxResults(state.maxResults)),
            Slider(
              value: state.maxResults.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (v) => cubit.setMaxResults(v.round()),
            ),
            SectionTitle(l10n.geocodePlaceTypes),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in state.availableTypes)
                  FilterChip(
                    label: Text(placeTypeLabel(l10n, t.apiValue)),
                    selected: state.placeTypes.contains(t),
                    onSelected: (_) => cubit.togglePlaceType(t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!reverse)
              FilledButton.icon(
                icon: const Icon(Icons.search),
                label: Text(l10n.geocodeAction),
                onPressed: state.status.isLoading ? null : () => _run(cubit),
              ),
            if (state.failure != null) FailureBanner(failure: state.failure!),
            SectionTitle(l10n.commonResultsCount(state.results.length)),
            for (final (i, p) in state.results.indexed)
              PlaceTile(place: p, index: i, onTap: () => _open(p)),
            if (state.results.isNotEmpty)
              JsonViewer(data: [for (final p in state.results) p.raw]),
          ],
        );
      },
    );
  }
}

extension on GeocodeMode {
  String _label(AppLocalizations l10n) => switch (this) {
    GeocodeMode.text => l10n.geocodeModeText,
    GeocodeMode.structured => l10n.geocodeModeStructured,
    GeocodeMode.reverse => l10n.geocodeModeReverse,
  };
}
