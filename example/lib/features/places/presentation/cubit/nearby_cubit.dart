import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class NearbyState extends Equatable {
  const NearbyState({
    required this.center,
    this.radius = 1000,
    this.categories = const {},
    this.places = const [],
    this.nextToken,
    this.raw,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final GeoPoint center;
  final int radius;
  final Set<String> categories;
  final List<Place> places;
  final String? nextToken;
  final Map<String, dynamic>? raw;
  final LoadStatus status;
  final Failure? failure;

  NearbyState copyWith({
    GeoPoint? center,
    int? radius,
    Set<String>? categories,
    List<Place>? places,
    String? nextToken,
    bool clearNextToken = false,
    Map<String, dynamic>? raw,
    LoadStatus? status,
    Failure? failure,
  }) => NearbyState(
    center: center ?? this.center,
    radius: radius ?? this.radius,
    categories: categories ?? this.categories,
    places: places ?? this.places,
    nextToken: clearNextToken ? null : nextToken ?? this.nextToken,
    raw: raw ?? this.raw,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    center,
    radius,
    categories,
    places,
    nextToken,
    raw,
    status,
    failure,
  ];
}

class NearbyCubit extends Cubit<NearbyState> {
  NearbyCubit(this._searchNearby, GeoPoint center)
    : super(NearbyState(center: center));

  final SearchNearby _searchNearby;

  void setCenter(GeoPoint center) {
    emit(state.copyWith(center: center));
    search();
  }

  void setRadius(int radius) => emit(state.copyWith(radius: radius));

  void toggleCategory(String id) {
    final next = {...state.categories};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(categories: next));
    search();
  }

  void clearCategories() {
    emit(state.copyWith(categories: const {}));
    search();
  }

  SearchNearbyParams _params({String? nextToken}) => SearchNearbyParams(
    position: state.center,
    radiusMeters: state.radius,
    includeCategories: state.categories.toList(),
    nextToken: nextToken,
  );

  Future<void> search() async {
    final params = _params();
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _searchNearby(params);
    if (isClosed || params.position != state.center) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
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
  }

  Future<void> loadMore() async {
    if (state.nextToken == null) return;
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _searchNearby(_params(nextToken: state.nextToken));
    if (isClosed) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
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
}
