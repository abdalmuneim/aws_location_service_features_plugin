import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class OptimizeState extends Equatable {
  const OptimizeState({
    this.start,
    this.end,
    this.stops = const [],
    this.roundTrip = false,
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
    this.tour,
    this.path = const [],
    this.status = LoadStatus.idle,
    this.failure,
  });

  final NamedLocation? start;
  final NamedLocation? end;
  final List<NamedLocation> stops;
  final bool roundTrip;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;
  final OptimizedTour? tour;

  /// Road geometry through the optimized order (from CalculateRoutes).
  final List<GeoPoint> path;
  final LoadStatus status;
  final Failure? failure;

  /// Stop id -> 1-based visiting position after optimization.
  Map<String, int> get visitOrder => {
    if (tour != null)
      for (final (i, s) in tour!.stops.indexed) s.id: i,
  };

  OptimizeState copyWith({
    NamedLocation? start,
    NamedLocation? end,
    bool clearEnd = false,
    List<NamedLocation>? stops,
    bool? roundTrip,
    TravelMode? travelMode,
    RouteOptimization? optimizeFor,
    OptimizedTour? tour,
    List<GeoPoint>? path,
    bool clearResult = false,
    LoadStatus? status,
    Failure? failure,
  }) => OptimizeState(
    start: start ?? this.start,
    end: clearEnd ? null : end ?? this.end,
    stops: stops ?? this.stops,
    roundTrip: roundTrip ?? this.roundTrip,
    travelMode: travelMode ?? this.travelMode,
    optimizeFor: optimizeFor ?? this.optimizeFor,
    tour: clearResult ? null : tour ?? this.tour,
    path: clearResult ? const [] : path ?? this.path,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    start,
    end,
    stops,
    roundTrip,
    travelMode,
    optimizeFor,
    tour,
    path,
    status,
    failure,
  ];
}

class OptimizeCubit extends Cubit<OptimizeState> {
  OptimizeCubit(this._optimize, this._routes) : super(const OptimizeState());

  final OptimizeWaypoints _optimize;
  final CalculateRoutes _routes;

  static String stopId(int index) => 'Stop ${index + 1}';

  /// First tap sets the start, later taps add stops.
  void tapAt(GeoPoint p) {
    final l = NamedLocation(point: p, label: p.format(4));
    state.start == null ? setStart(l) : addStop(l);
  }

  void setStart(NamedLocation l) =>
      emit(state.copyWith(start: l, clearResult: true));

  void setEnd(NamedLocation? l) => emit(
    l == null
        ? state.copyWith(clearEnd: true, clearResult: true)
        : state.copyWith(end: l, roundTrip: false, clearResult: true),
  );

  void setRoundTrip(bool v) =>
      emit(state.copyWith(roundTrip: v, clearEnd: v, clearResult: true));

  void addStop(NamedLocation l) =>
      emit(state.copyWith(stops: [...state.stops, l], clearResult: true));

  void removeStop(int i) => emit(
    state.copyWith(stops: [...state.stops]..removeAt(i), clearResult: true),
  );

  void setTravelMode(TravelMode m) =>
      emit(state.copyWith(travelMode: m, clearResult: true));

  void setOptimization(RouteOptimization o) =>
      emit(state.copyWith(optimizeFor: o, clearResult: true));

  void clear() => emit(OptimizeState(travelMode: state.travelMode));

  Future<void> optimize() async {
    final s = state;
    if (s.start == null) return;
    emit(s.copyWith(status: LoadStatus.loading, clearResult: true));
    final r = await _optimize(
      OptimizeWaypointsRequest(
        origin: s.start!.point,
        destination: s.roundTrip ? s.start!.point : s.end?.point,
        stops: [
          for (final (i, stop) in s.stops.indexed)
            OptimizationStop(id: stopId(i), position: stop.point),
        ],
        travelMode: s.travelMode,
        optimizeFor: s.optimizeFor,
      ),
    );
    if (isClosed) return;
    final tour = r.valueOrNull;
    if (tour == null) {
      emit(
        state.copyWith(status: LoadStatus.failure, failure: r.failureOrNull),
      );
      return;
    }
    emit(state.copyWith(tour: tour, status: LoadStatus.loading));

    // Draw the real road path through the optimized order.
    final ordered = [for (final st in tour.stops) st.position];
    if (ordered.length >= 2 &&
        ordered.length - 2 <= CalculateRoutes.maxWaypoints) {
      final route = await _routes(
        RouteRequest(
          origin: ordered.first,
          destination: ordered.last,
          waypoints: ordered.sublist(1, ordered.length - 1),
          travelMode: s.travelMode,
          maxAlternatives: 0,
        ),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          path: route.valueOrNull?.routes.firstOrNull?.geometry ?? ordered,
          status: LoadStatus.success,
        ),
      );
    } else {
      emit(state.copyWith(path: ordered, status: LoadStatus.success));
    }
  }
}
