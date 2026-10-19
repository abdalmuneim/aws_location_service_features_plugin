import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

enum SearchMode {
  searchText('Search text', 'Businesses, POIs and addresses, paged'),
  suggest('Suggest', 'Places plus query refinements as you type'),
  autocomplete('Autocomplete', 'Fast address completion as you type');

  const SearchMode(this.label, this.description);

  final String label;
  final String description;
}

class SearchState extends Equatable {
  const SearchState({
    this.mode = SearchMode.searchText,
    this.query = '',
    this.places = const [],
    this.completions = const [],
    this.suggestions = const [],
    this.nextToken,
    this.country,
    this.useCircle = false,
    this.circleRadius = 5000,
    this.raw,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final SearchMode mode;
  final String query;

  /// SearchText results (and resolved selections).
  final List<Place> places;
  final List<AutocompleteSuggestion> completions;
  final List<Suggestion> suggestions;
  final String? nextToken;

  /// ISO alpha-3 country filter, e.g. "EGY".
  final String? country;

  /// SearchText only: restrict to a circle around the map center.
  final bool useCircle;
  final int circleRadius;
  final Object? raw;
  final LoadStatus status;
  final Failure? failure;

  /// Places that can be drawn on the map.
  List<Place> get mappable => [
    ...places,
    for (final s in suggestions)
      if (s.place?.position != null) s.place!,
  ].where((p) => p.position != null).toList();

  SearchState copyWith({
    SearchMode? mode,
    String? query,
    List<Place>? places,
    List<AutocompleteSuggestion>? completions,
    List<Suggestion>? suggestions,
    String? nextToken,
    bool clearNextToken = false,
    String? country,
    bool clearCountry = false,
    bool? useCircle,
    int? circleRadius,
    Object? raw,
    LoadStatus? status,
    Failure? failure,
  }) => SearchState(
    mode: mode ?? this.mode,
    query: query ?? this.query,
    places: places ?? this.places,
    completions: completions ?? this.completions,
    suggestions: suggestions ?? this.suggestions,
    nextToken: clearNextToken ? null : nextToken ?? this.nextToken,
    country: clearCountry ? null : country ?? this.country,
    useCircle: useCircle ?? this.useCircle,
    circleRadius: circleRadius ?? this.circleRadius,
    raw: raw ?? this.raw,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    mode,
    query,
    places,
    completions,
    suggestions,
    nextToken,
    country,
    useCircle,
    circleRadius,
    raw,
    status,
    failure,
  ];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._searchText,
    this._suggest,
    this._autocomplete,
    this._getPlace,
  ) : super(const SearchState());

  final SearchText _searchText;
  final SuggestPlaces _suggest;
  final AutocompletePlaces _autocomplete;
  final GetPlace _getPlace;

  void setMode(SearchMode mode) => emit(
    SearchState(
      mode: mode,
      query: state.query,
      country: state.country,
      useCircle: state.useCircle,
      circleRadius: state.circleRadius,
    ),
  );

  void setCountry(String? code) => emit(
    code == null || code.trim().isEmpty
        ? state.copyWith(clearCountry: true)
        : state.copyWith(country: code.trim().toUpperCase()),
  );

  void setCircle({bool? enabled, int? radius}) =>
      emit(state.copyWith(useCircle: enabled, circleRadius: radius));

  List<String> get _countries =>
      state.country == null ? const [] : [state.country!];

  Future<void> search(String query, GeoPoint bias) async {
    emit(state.copyWith(query: query, status: LoadStatus.loading));
    switch (state.mode) {
      case SearchMode.searchText:
        final r = await _searchText(
          SearchTextParams(
            queryText: query,
            biasPosition: bias,
            circleCenter: state.useCircle ? bias : null,
            circleRadius: state.useCircle ? state.circleRadius : null,
            includeCountries: _countries,
          ),
        );
        if (isClosed || state.query != query) return;
        r.fold(
          _fail,
          (page) => emit(
            state.copyWith(
              places: page.places,
              nextToken: page.nextToken,
              clearNextToken: page.nextToken == null,
              raw: page.raw,
              status: LoadStatus.success,
            ),
          ),
        );
      case SearchMode.suggest:
        final r = await _suggest(
          SuggestParams(queryText: query, biasPosition: bias),
        );
        if (isClosed || state.query != query) return;
        r.fold(
          _fail,
          (items) => emit(
            state.copyWith(
              suggestions: items,
              places: const [],
              raw: [for (final i in items) i.raw],
              status: LoadStatus.success,
            ),
          ),
        );
      case SearchMode.autocomplete:
        final r = await _autocomplete(
          AutocompleteParams(
            queryText: query,
            biasPosition: bias,
            includeCountries: _countries,
          ),
        );
        if (isClosed || state.query != query) return;
        r.fold(
          _fail,
          (items) => emit(
            state.copyWith(
              completions: items,
              places: const [],
              raw: [for (final i in items) i.raw],
              status: LoadStatus.success,
            ),
          ),
        );
    }
  }

  Future<void> loadMore(GeoPoint bias) async {
    final token = state.nextToken;
    if (token == null) return;
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _searchText(
      SearchTextParams(
        queryText: state.query,
        biasPosition: bias,
        nextToken: token,
        includeCountries: _countries,
      ),
    );
    if (isClosed) return;
    r.fold(
      _fail,
      (page) => emit(
        state.copyWith(
          places: [...state.places, ...page.places],
          nextToken: page.nextToken,
          clearNextToken: page.nextToken == null,
          raw: page.raw,
          status: LoadStatus.success,
        ),
      ),
    );
  }

  /// Expands a Suggest query refinement with SearchText(QueryId).
  Future<void> runQuery(Suggestion s) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _searchText(SearchTextParams(queryId: s.queryId));
    if (isClosed) return;
    r.fold(
      _fail,
      (page) => emit(
        state.copyWith(
          mode: SearchMode.searchText,
          query: s.title,
          places: page.places,
          suggestions: const [],
          raw: page.raw,
          status: LoadStatus.success,
        ),
      ),
    );
  }

  /// Autocomplete has no coordinates: resolve the pick with GetPlace.
  Future<Place?> resolve(AutocompleteSuggestion item) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _getPlace(GetPlaceParams(placeId: item.placeId));
    if (isClosed) return null;
    return r.fold(
      (f) {
        _fail(f);
        return null;
      },
      (place) {
        emit(state.copyWith(places: [place], status: LoadStatus.success));
        return place;
      },
    );
  }

  void _fail(Failure f) =>
      emit(state.copyWith(status: LoadStatus.failure, failure: f));
}
