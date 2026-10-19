import 'dart:async';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import 'place_icons.dart';
import 'place_labels.dart';

/// Type-ahead place search.
///
/// With [useSuggest] off it uses Autocomplete (addresses) and resolves the
/// chosen item with GetPlace. With [useSuggest] on it uses Suggest, which
/// also returns businesses and query refinements ("coffee shops near…")
/// delivered to [onQuery].
class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({
    super.key,
    required this.onPlace,
    this.onQuery,
    this.biasPosition,
    this.useSuggest = false,
    this.hintText,
  });

  final ValueChanged<Place> onPlace;
  final ValueChanged<Suggestion>? onQuery;
  final GeoPoint Function()? biasPosition;
  final bool useSuggest;

  /// Defaults to a generic "Search places or addresses".
  final String? hintText;

  @override
  State<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<PlaceSearchBar> {
  final _controller = SearchController();
  Timer? _debounce;
  String _lastQuery = '';
  List<Widget> _lastTiles = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Waits for typing to pause; returns false if a newer keystroke arrived.
  Future<bool> _settle(String query) {
    _debounce?.cancel();
    final completer = Completer<bool>();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => completer.complete(_controller.text == query),
    );
    return completer.future;
  }

  Future<Iterable<Widget>> _suggestions(
    BuildContext context,
    SearchController controller,
  ) async {
    final l10n = context.l10n;
    final query = controller.text.trim();
    if (query.length < 2) return const [];
    if (query == _lastQuery) return _lastTiles;
    if (!await _settle(controller.text)) return _lastTiles;

    final tiles = widget.useSuggest
        ? await _suggestTiles(query, l10n)
        : await _autocompleteTiles(query, l10n);
    _lastQuery = query;
    _lastTiles = tiles;
    return tiles;
  }

  Future<List<Widget>> _autocompleteTiles(
    String query,
    AppLocalizations l10n,
  ) async {
    final result = await sl<AutocompletePlaces>()(
      AutocompleteParams(
        queryText: query,
        biasPosition: widget.biasPosition?.call(),
      ),
    );
    return result.fold((f) => [_errorTile(f.localizedMessage(l10n))], (items) {
      if (items.isEmpty) return [_emptyTile(l10n)];
      return [
        for (final item in items)
          ListTile(
            leading: Icon(placeTypeIcon(item.placeType)),
            title: Text(item.title),
            subtitle: Text(
              [
                placeTypeLabel(l10n, item.placeType),
                if (item.distance != null)
                  Formatters.distance(l10n, item.distance),
              ].join(' · '),
            ),
            onTap: () => _resolve(item),
          ),
      ];
    });
  }

  Future<List<Widget>> _suggestTiles(
    String query,
    AppLocalizations l10n,
  ) async {
    final bias = widget.biasPosition?.call();
    if (bias == null) return [_errorTile(l10n.placeSearchMoveMap)];
    final result = await sl<SuggestPlaces>()(
      SuggestParams(queryText: query, biasPosition: bias),
    );
    return result.fold((f) => [_errorTile(f.localizedMessage(l10n))], (items) {
      if (items.isEmpty) return [_emptyTile(l10n)];
      return [
        for (final s in items)
          if (s.kind == SuggestionKind.query)
            ListTile(
              leading: const Icon(Icons.manage_search),
              title: Text(s.title),
              subtitle: Text(suggestQueryLabel(l10n, s.queryType)),
              onTap: () {
                _controller.closeView(s.title);
                widget.onQuery?.call(s);
              },
            )
          else if (s.place != null)
            ListTile(
              leading: Icon(placeTypeIcon(s.place!.placeType)),
              title: Text(s.title),
              subtitle: Text(
                [
                  s.place!.primaryCategory?.displayName ??
                      placeTypeLabel(l10n, s.place!.placeType),
                  if (s.place!.distance != null)
                    Formatters.distance(l10n, s.place!.distance),
                ].join(' · '),
              ),
              onTap: () {
                _controller.closeView(s.title);
                if (s.place!.position != null) {
                  widget.onPlace(s.place!);
                } else {
                  _resolveId(s.place!.placeId);
                }
              },
            ),
      ];
    });
  }

  Future<void> _resolve(AutocompleteSuggestion item) async {
    _controller.closeView(item.title);
    await _resolveId(item.placeId);
  }

  Future<void> _resolveId(String placeId) async {
    final result = await sl<GetPlace>()(GetPlaceParams(placeId: placeId));
    if (!mounted) return;
    result.fold(
      (f) => showSnack(context, f.localizedMessage(context.l10n)),
      (place) => place.position == null
          ? showSnack(context, context.l10n.placeNoCoordinates)
          : widget.onPlace(place),
    );
  }

  Widget _errorTile(String message) =>
      ListTile(leading: const Icon(Icons.error_outline), title: Text(message));

  Widget _emptyTile(AppLocalizations l10n) => ListTile(
    leading: const Icon(Icons.search_off),
    title: Text(l10n.placeSearchNoMatches),
  );

  @override
  Widget build(BuildContext context) {
    final hintText = widget.hintText ?? context.l10n.placeSearchHint;
    return SearchAnchor.bar(
      searchController: _controller,
      barHintText: hintText,
      barElevation: const WidgetStatePropertyAll(2),
      barLeading: const Icon(Icons.search),
      viewHintText: hintText,
      suggestionsBuilder: _suggestions,
      viewBuilder: (suggestions) => OverMap(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(children: suggestions.toList()),
        ),
      ),
    );
  }
}
