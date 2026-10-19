import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class DirectionsState extends Equatable {
  const DirectionsState({
    this.origin,
    this.destination,
    this.waypoints = const [],
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
    this.avoid = const AvoidOptions(),
    this.maxAlternatives = 2,
    this.departureTime,
    this.useTraffic = true,
    this.truck = const TruckProfile(),
    this.result,
    this.selected = 0,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final NamedLocation? origin;
  final NamedLocation? destination;
  final List<NamedLocation> waypoints;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;
  final AvoidOptions avoid;
  final int maxAlternatives;
  final DateTime? departureTime;
  final bool useTraffic;
  final TruckProfile truck;
  final RouteResult? result;
  final int selected;
  final LoadStatus status;
  final Failure? failure;

  bool get ready => origin != null && destination != null;

  RouteOption? get selectedRoute {
    final routes = result?.routes ?? const [];
    return selected < routes.length ? routes[selected] : null;
  }

  DirectionsState copyWith({
    NamedLocation? origin,
    bool clearOrigin = false,
    NamedLocation? destination,
    bool clearDestination = false,
    List<NamedLocation>? waypoints,
    TravelMode? travelMode,
    RouteOptimization? optimizeFor,
    AvoidOptions? avoid,
    int? maxAlternatives,
    DateTime? departureTime,
    bool departNow = false,
    bool? useTraffic,
    TruckProfile? truck,
    RouteResult? result,
    bool clearResult = false,
    int? selected,
    LoadStatus? status,
    Failure? failure,
  }) => DirectionsState(
    origin: clearOrigin ? null : origin ?? this.origin,
    destination: clearDestination ? null : destination ?? this.destination,
    waypoints: waypoints ?? this.waypoints,
    travelMode: travelMode ?? this.travelMode,
    optimizeFor: optimizeFor ?? this.optimizeFor,
    avoid: avoid ?? this.avoid,
    maxAlternatives: maxAlternatives ?? this.maxAlternatives,
    departureTime: departNow ? null : departureTime ?? this.departureTime,
    useTraffic: useTraffic ?? this.useTraffic,
    truck: truck ?? this.truck,
    result: clearResult ? null : result ?? this.result,
    selected: selected ?? (clearResult ? 0 : this.selected),
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    origin,
    destination,
    waypoints,
    travelMode,
    optimizeFor,
    avoid,
    maxAlternatives,
    departureTime,
    useTraffic,
    truck,
    result,
    selected,
    status,
    failure,
  ];
}

/// CalculateRoutes with every option. Recalculates automatically whenever
/// the endpoints or options change.
class DirectionsCubit extends Cubit<DirectionsState> {
  DirectionsCubit(
    this._calculateRoutes,
    this._reverseGeocode, {
    required this.units,
    NamedLocation? origin,
    NamedLocation? destination,
  }) : super(DirectionsState(origin: origin, destination: destination)) {
    if (state.ready) calculate();
  }

  final CalculateRoutes _calculateRoutes;
  final ReverseGeocode _reverseGeocode;
  final MeasurementUnits units;
  int _request = 0;

  void _update(DirectionsState next) {
    emit(next.copyWith(clearResult: true));
    if (next.ready) calculate();
  }

  void setOrigin(NamedLocation? l) => _update(
    l == null ? state.copyWith(clearOrigin: true) : state.copyWith(origin: l),
  );

  void setDestination(NamedLocation? l) => _update(
    l == null
        ? state.copyWith(clearDestination: true)
        : state.copyWith(destination: l),
  );

  void addWaypoint(NamedLocation l) =>
      _update(state.copyWith(waypoints: [...state.waypoints, l]));

  void removeWaypoint(int index) =>
      _update(state.copyWith(waypoints: [...state.waypoints]..removeAt(index)));

  void swap() {
    if (!state.ready) return;
    _update(
      state.copyWith(
        origin: state.destination,
        destination: state.origin,
        waypoints: state.waypoints.reversed.toList(),
      ),
    );
  }

  void setTravelMode(TravelMode m) => _update(state.copyWith(travelMode: m));

  void setOptimization(RouteOptimization o) =>
      _update(state.copyWith(optimizeFor: o));

  void setAvoid(AvoidOptions a) => _update(state.copyWith(avoid: a));

  void setAlternatives(int n) => _update(state.copyWith(maxAlternatives: n));

  void setDeparture(DateTime? t) => _update(
    t == null
        ? state.copyWith(departNow: true)
        : state.copyWith(departureTime: t),
  );

  void setTraffic(bool v) => _update(state.copyWith(useTraffic: v));

  void setTruck(TruckProfile t) => _update(state.copyWith(truck: t));

  void selectRoute(int i) => emit(state.copyWith(selected: i));

  /// Map taps fill the origin first, then the destination.
  Future<void> tapAt(GeoPoint point) async {
    final label = await _label(point);
    if (isClosed) return;
    final l = NamedLocation(point: point, label: label);
    state.origin == null ? setOrigin(l) : setDestination(l);
  }

  Future<String> _label(GeoPoint p) async {
    final r = await _reverseGeocode(ReverseGeocodeParams(position: p));
    final place = r.valueOrNull?.firstOrNull;
    return place?.address?.label ?? place?.title ?? p.format();
  }

  Future<void> calculate() async {
    final s = state;
    if (!s.ready) return;
    final id = ++_request;
    emit(s.copyWith(status: LoadStatus.loading));
    final result = await _calculateRoutes(
      RouteRequest(
        origin: s.origin!.point,
        destination: s.destination!.point,
        waypoints: [for (final w in s.waypoints) w.point],
        travelMode: s.travelMode,
        optimizeFor: s.optimizeFor,
        avoid: s.avoid,
        maxAlternatives: s.maxAlternatives,
        departureTime: s.departureTime,
        useTraffic: s.useTraffic,
        truck: s.truck,
        units: units,
      ),
    );
    if (isClosed || id != _request) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (r) => emit(
        state.copyWith(result: r, selected: 0, status: LoadStatus.success),
      ),
    );
  }
}
