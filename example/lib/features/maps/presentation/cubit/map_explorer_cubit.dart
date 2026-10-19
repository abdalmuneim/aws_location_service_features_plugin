import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class MapExplorerState extends Equatable {
  const MapExplorerState({
    this.inspected,
    this.inspectedPlace,
    this.results = const [],
    this.resultsTitle,
    this.myLocation,
    this.status = LoadStatus.idle,
    this.failure,
  });

  /// Point the user tapped (reverse geocoded into [inspectedPlace]).
  final GeoPoint? inspected;
  final Place? inspectedPlace;

  /// Places from a search, drawn as numbered markers.
  final List<Place> results;
  final String? resultsTitle;
  final GeoPoint? myLocation;
  final LoadStatus status;
  final Failure? failure;

  MapExplorerState copyWith({
    GeoPoint? inspected,
    Place? inspectedPlace,
    bool clearInspection = false,
    List<Place>? results,
    String? resultsTitle,
    GeoPoint? myLocation,
    LoadStatus? status,
    Failure? failure,
  }) => MapExplorerState(
    inspected: clearInspection ? null : inspected ?? this.inspected,
    inspectedPlace: clearInspection
        ? null
        : inspectedPlace ?? this.inspectedPlace,
    results: results ?? this.results,
    resultsTitle: resultsTitle ?? this.resultsTitle,
    myLocation: myLocation ?? this.myLocation,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    inspected,
    inspectedPlace,
    results,
    resultsTitle,
    myLocation,
    status,
    failure,
  ];
}

class MapExplorerCubit extends Cubit<MapExplorerState> {
  MapExplorerCubit(this._reverseGeocode, this._searchText, this._location)
    : super(const MapExplorerState());

  final ReverseGeocode _reverseGeocode;
  final SearchText _searchText;
  final GetCurrentLocation _location;

  /// Reverse geocodes a tapped point.
  Future<void> inspect(GeoPoint point) async {
    emit(
      state
          .copyWith(clearInspection: true, status: LoadStatus.loading)
          .copyWith(inspected: point),
    );
    final result = await _reverseGeocode(
      ReverseGeocodeParams(
        position: point,
        features: const [
          PlaceFeature.timeZone,
          PlaceFeature.access,
          PlaceFeature.intersections,
        ],
      ),
    );
    if (isClosed || state.inspected != point) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (places) => emit(
        state.copyWith(
          inspectedPlace: places.firstOrNull,
          status: LoadStatus.success,
        ),
      ),
    );
  }

  void showPlace(Place place) => emit(
    state.copyWith(
      clearInspection: true,
      results: [place],
      resultsTitle: place.title,
      status: LoadStatus.success,
    ),
  );

  /// Expands a Suggest query refinement with SearchText.
  Future<void> searchQuery(String title, String queryId) async {
    emit(state.copyWith(status: LoadStatus.loading, clearInspection: true));
    final result = await _searchText(SearchTextParams(queryId: queryId));
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (page) => emit(
        state.copyWith(
          results: page.places.where((p) => p.position != null).toList(),
          resultsTitle: title,
          status: LoadStatus.success,
        ),
      ),
    );
  }

  void clear() => emit(MapExplorerState(myLocation: state.myLocation));

  Future<GeoPoint?> locate() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _location(const NoParams());
    if (isClosed) return null;
    return result.fold(
      (f) {
        emit(state.copyWith(status: LoadStatus.failure, failure: f));
        return null;
      },
      (pos) {
        emit(state.copyWith(myLocation: pos.point, status: LoadStatus.success));
        return pos.point;
      },
    );
  }
}
