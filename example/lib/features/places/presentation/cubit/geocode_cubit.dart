import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

enum GeocodeMode {
  text('Free text'),
  structured('Structured'),
  reverse('Reverse');

  const GeocodeMode(this.label);

  final String label;
}

class GeocodeState extends Equatable {
  const GeocodeState({
    this.mode = GeocodeMode.text,
    this.results = const [],
    this.placeTypes = const {},
    this.reversePoint,
    this.reverseRadius = 200,
    this.maxResults = 5,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final GeocodeMode mode;
  final List<Place> results;
  final Set<PlaceTypeFilter> placeTypes;
  final GeoPoint? reversePoint;
  final int reverseRadius;
  final int maxResults;
  final LoadStatus status;
  final Failure? failure;

  /// PostalCode is not a valid reverse-geocode filter.
  List<PlaceTypeFilter> get availableTypes => mode == GeocodeMode.reverse
      ? PlaceTypeFilter.values
            .where((t) => t != PlaceTypeFilter.postalCode)
            .toList()
      : PlaceTypeFilter.values;

  GeocodeState copyWith({
    GeocodeMode? mode,
    List<Place>? results,
    Set<PlaceTypeFilter>? placeTypes,
    GeoPoint? reversePoint,
    int? reverseRadius,
    int? maxResults,
    LoadStatus? status,
    Failure? failure,
  }) => GeocodeState(
    mode: mode ?? this.mode,
    results: results ?? this.results,
    placeTypes: placeTypes ?? this.placeTypes,
    reversePoint: reversePoint ?? this.reversePoint,
    reverseRadius: reverseRadius ?? this.reverseRadius,
    maxResults: maxResults ?? this.maxResults,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    mode,
    results,
    placeTypes,
    reversePoint,
    reverseRadius,
    maxResults,
    status,
    failure,
  ];
}

class GeocodeCubit extends Cubit<GeocodeState> {
  GeocodeCubit(this._geocode, this._reverse) : super(const GeocodeState());

  final Geocode _geocode;
  final ReverseGeocode _reverse;

  static const _features = [
    PlaceFeature.timeZone,
    PlaceFeature.access,
    PlaceFeature.intersections,
  ];

  void setMode(GeocodeMode mode) =>
      emit(GeocodeState(mode: mode, maxResults: state.maxResults));

  void togglePlaceType(PlaceTypeFilter type) {
    final next = {...state.placeTypes};
    if (!next.remove(type)) next.add(type);
    emit(state.copyWith(placeTypes: next));
  }

  void setMaxResults(int value) => emit(state.copyWith(maxResults: value));

  void setReverseRadius(int value) =>
      emit(state.copyWith(reverseRadius: value));

  Future<void> geocodeText(String text, GeoPoint bias) => _run(
    () => _geocode(
      GeocodeParams(
        queryText: text,
        biasPosition: bias,
        includePlaceTypes: state.placeTypes.toList(),
        maxResults: state.maxResults,
        features: [..._features, PlaceFeature.secondaryAddresses],
      ),
    ),
  );

  Future<void> geocodeComponents(AddressComponents components) => _run(
    () => _geocode(
      GeocodeParams(
        components: components,
        includePlaceTypes: state.placeTypes.toList(),
        maxResults: state.maxResults,
        features: _features,
      ),
    ),
  );

  Future<void> reverse(GeoPoint point) {
    emit(state.copyWith(reversePoint: point));
    return _run(
      () => _reverse(
        ReverseGeocodeParams(
          position: point,
          radiusMeters: state.reverseRadius,
          maxResults: state.maxResults,
          includePlaceTypes: state.placeTypes.toList(),
          features: _features,
        ),
      ),
    );
  }

  Future<void> _run(Future<Result<List<Place>>> Function() call) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await call();
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (places) =>
          emit(state.copyWith(results: places, status: LoadStatus.success)),
    );
  }
}
