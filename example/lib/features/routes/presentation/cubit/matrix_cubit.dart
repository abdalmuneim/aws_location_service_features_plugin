import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class MatrixState extends Equatable {
  const MatrixState({
    this.origins = const [],
    this.destinations = const [],
    this.addingOrigins = true,
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
    this.avoid = const AvoidOptions(),
    this.result,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final List<NamedLocation> origins;
  final List<NamedLocation> destinations;

  /// Whether map taps add origins (true) or destinations (false).
  final bool addingOrigins;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;
  final AvoidOptions avoid;
  final RouteMatrix? result;
  final LoadStatus status;
  final Failure? failure;

  MatrixState copyWith({
    List<NamedLocation>? origins,
    List<NamedLocation>? destinations,
    bool? addingOrigins,
    TravelMode? travelMode,
    RouteOptimization? optimizeFor,
    AvoidOptions? avoid,
    RouteMatrix? result,
    bool clearResult = false,
    LoadStatus? status,
    Failure? failure,
  }) => MatrixState(
    origins: origins ?? this.origins,
    destinations: destinations ?? this.destinations,
    addingOrigins: addingOrigins ?? this.addingOrigins,
    travelMode: travelMode ?? this.travelMode,
    optimizeFor: optimizeFor ?? this.optimizeFor,
    avoid: avoid ?? this.avoid,
    result: clearResult ? null : result ?? this.result,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    origins,
    destinations,
    addingOrigins,
    travelMode,
    optimizeFor,
    avoid,
    result,
    status,
    failure,
  ];
}

class MatrixCubit extends Cubit<MatrixState> {
  MatrixCubit(this._calculate) : super(const MatrixState());

  final CalculateRouteMatrix _calculate;

  void setAddingOrigins(bool v) => emit(state.copyWith(addingOrigins: v));

  void addPoint(GeoPoint p) {
    final isOrigin = state.addingOrigins;
    final list = isOrigin ? state.origins : state.destinations;
    final l = NamedLocation(
      point: p,
      label: '${isOrigin ? 'O' : 'D'}${list.length + 1} · ${p.format(4)}',
    );
    add(l, origin: isOrigin);
  }

  void add(NamedLocation l, {required bool origin}) => emit(
    origin
        ? state.copyWith(origins: [...state.origins, l], clearResult: true)
        : state.copyWith(
            destinations: [...state.destinations, l],
            clearResult: true,
          ),
  );

  void remove(int index, {required bool origin}) => emit(
    origin
        ? state.copyWith(
            origins: [...state.origins]..removeAt(index),
            clearResult: true,
          )
        : state.copyWith(
            destinations: [...state.destinations]..removeAt(index),
            clearResult: true,
          ),
  );

  void clear() => emit(
    MatrixState(travelMode: state.travelMode, optimizeFor: state.optimizeFor),
  );

  void setTravelMode(TravelMode m) =>
      emit(state.copyWith(travelMode: m, clearResult: true));

  void setOptimization(RouteOptimization o) =>
      emit(state.copyWith(optimizeFor: o, clearResult: true));

  void setAvoid(AvoidOptions a) =>
      emit(state.copyWith(avoid: a, clearResult: true));

  Future<void> calculate() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _calculate(
      RouteMatrixRequest(
        origins: [for (final o in state.origins) o.point],
        destinations: [for (final d in state.destinations) d.point],
        travelMode: state.travelMode,
        optimizeFor: state.optimizeFor,
        avoid: state.avoid,
      ),
    );
    if (isClosed) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (m) => emit(state.copyWith(result: m, status: LoadStatus.success)),
    );
  }
}
