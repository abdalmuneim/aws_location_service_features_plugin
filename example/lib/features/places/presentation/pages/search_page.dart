import 'dart:async';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/load_status.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../cubit/search_cubit.dart';
import '../widgets/place_actions.dart';
import '../widgets/place_details_sheet.dart';
import '../widgets/place_icons.dart';
import '../widgets/place_labels.dart';
import '../widgets/place_tile.dart';

/// SearchText, Suggest and Autocomplete side by side.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SearchCubit(sl(), sl(), sl(), sl()),
    child: const _SearchView(),
  );
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _text = TextEditingController();
  final _country = TextEditingController();
  AwsMapController? _map;
  Timer? _debounce;
  GeoPoint _center = AwsConfig.defaultCenter;

  GeoPoint get _bias => _map?.center ?? _center;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    _country.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final cubit = context.read<SearchCubit>();
    if (cubit.state.mode == SearchMode.searchText) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (value.trim().length >= 2) cubit.search(value, _bias);
    });
  }

  Future<void> _submit() async {
    final cubit = context.read<SearchCubit>();
    await cubit.search(_text.text, _bias);
    if (!mounted) return;
    final pts = cubit.state.mappable.map((p) => p.position!);
    if (pts.isNotEmpty) _map?.fitPoints(pts);
  }

  void _open(Place place) {
    if (place.position != null) _map?.moveTo(place.position!, zoom: 16);
    showPlaceDetailsSheet(context, place, actions: placeActions(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<SearchCubit>();
        final mappable = state.mappable;
        return MapScaffold(
          title: l10n.searchTitle,
          loading: state.status.isLoading,
          map: AppMapView(
            onMapReady: (c) => _map = c,
            onCameraIdle: (c) {
              if (state.useCircle && c.center != null) {
                setState(() => _center = c.center!);
              }
            },
            onMarkerTap: (m) {
              final p = mappable.where((p) => p.placeId == m.id).firstOrNull;
              if (p != null) _open(p);
            },
            overlay: MapOverlay(
              markers: [
                for (final (i, p) in mappable.indexed)
                  MapMarker(
                    id: p.placeId,
                    position: p.position!,
                    color: MapColors.result,
                    label: '${i + 1}',
                    radius: 10,
                  ),
              ],
              polygons: [
                if (state.useCircle && state.mode == SearchMode.searchText)
                  MapPolygon(
                    id: 'circle',
                    rings: [
                      GeoUtils.circle(_center, state.circleRadius.toDouble()),
                    ],
                    fillOpacity: 0.06,
                  ),
              ],
            ),
          ),
          mapBanner: MapHint(l10n.searchBiasHint),
          panel: [
            SegmentedButton<SearchMode>(
              segments: [
                for (final m in SearchMode.values)
                  ButtonSegment(value: m, label: Text(m._label(l10n))),
              ],
              selected: {state.mode},
              onSelectionChanged: (v) => cubit.setMode(v.first),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                state.mode._description(l10n),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchHint,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _submit,
                ),
              ),
              onChanged: _onChanged,
              onSubmitted: (_) => _submit(),
            ),
            if (state.mode != SearchMode.suggest)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _country,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.flag_outlined),
                    hintText: l10n.searchCountryHint,
                    counterText: '',
                  ),
                  onChanged: cubit.setCountry,
                ),
              ),
            if (state.mode == SearchMode.searchText) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.searchOnlyInCircle),
                value: state.useCircle,
                onChanged: (v) => cubit.setCircle(enabled: v),
              ),
              if (state.useCircle)
                Slider(
                  value: state.circleRadius.toDouble(),
                  min: 500,
                  max: 50000,
                  divisions: 99,
                  label: Formatters.distance(l10n, state.circleRadius),
                  onChanged: (v) => cubit.setCircle(radius: v.round()),
                ),
            ],
            if (state.failure != null) FailureBanner(failure: state.failure!),
            ..._results(context, state),
            if (state.nextToken != null)
              Center(
                child: TextButton(
                  onPressed: () => cubit.loadMore(_bias),
                  child: Text(l10n.commonLoadMore),
                ),
              ),
            if (state.raw != null) JsonViewer(data: state.raw),
          ],
        );
      },
    );
  }

  List<Widget> _results(BuildContext context, SearchState s) {
    final l10n = context.l10n;
    final cubit = context.read<SearchCubit>();
    switch (s.mode) {
      case SearchMode.autocomplete:
        if (s.completions.isEmpty) return [_empty(s, l10n)];
        return [
          SectionTitle(l10n.searchCompletionsCount(s.completions.length)),
          for (final c in s.completions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(placeTypeIcon(c.placeType))),
              title: Text(c.title),
              subtitle: Text(placeTypeLabel(l10n, c.placeType)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final place = await cubit.resolve(c);
                if (place != null && mounted) _open(place);
              },
            ),
        ];
      case SearchMode.suggest:
        if (s.suggestions.isEmpty) return [_empty(s, l10n)];
        return [
          SectionTitle(l10n.searchSuggestionsCount(s.suggestions.length)),
          for (final sug in s.suggestions)
            if (sug.place != null)
              PlaceTile(place: sug.place!, onTap: () => _open(sug.place!))
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.manage_search)),
                title: Text(sug.title),
                subtitle: Text(l10n.searchQueryRefinement),
                onTap: () async {
                  await cubit.runQuery(sug);
                  final pts = cubit.state.mappable.map((p) => p.position!);
                  if (pts.isNotEmpty) _map?.fitPoints(pts);
                },
              ),
        ];
      case SearchMode.searchText:
        if (s.places.isEmpty) return [_empty(s, l10n)];
        return [
          SectionTitle(l10n.commonResultsCount(s.places.length)),
          for (final (i, p) in s.places.indexed)
            PlaceTile(place: p, index: i, onTap: () => _open(p)),
        ];
    }
  }

  Widget _empty(SearchState s, AppLocalizations l10n) => EmptyHint(
    icon: Icons.travel_explore,
    message: s.status == LoadStatus.success
        ? l10n.searchNoResults(s.query)
        : l10n.searchTypeQuery(s.mode._label(l10n)),
  );
}

extension on SearchMode {
  String _label(AppLocalizations l10n) => switch (this) {
    SearchMode.searchText => l10n.searchModeSearchText,
    SearchMode.suggest => l10n.searchModeSuggest,
    SearchMode.autocomplete => l10n.searchModeAutocomplete,
  };

  String _description(AppLocalizations l10n) => switch (this) {
    SearchMode.searchText => l10n.searchModeSearchTextDescription,
    SearchMode.suggest => l10n.searchModeSuggestDescription,
    SearchMode.autocomplete => l10n.searchModeAutocompleteDescription,
  };
}
