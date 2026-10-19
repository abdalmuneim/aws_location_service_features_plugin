import 'dart:math' as math;

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure_code.dart';
import '../../../../core/presentation/load_status.dart';

class SnapState extends Equatable {
  const SnapState({
    this.trace = const [],
    this.travelMode = TravelMode.car,
    this.radius = 100,
    this.result,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final List<TracePoint> trace;
  final TravelMode travelMode;
  final int radius;
  final SnapResult? result;
  final LoadStatus status;
  final Failure? failure;

  double get averageConfidence {
    final pts = result?.points ?? const [];
    if (pts.isEmpty) return 0;
    return pts.fold<double>(0, (s, p) => s + p.confidence) / pts.length;
  }

  SnapState copyWith({
    List<TracePoint>? trace,
    TravelMode? travelMode,
    int? radius,
    SnapResult? result,
    bool clearResult = false,
    LoadStatus? status,
    Failure? failure,
  }) => SnapState(
    trace: trace ?? this.trace,
    travelMode: travelMode ?? this.travelMode,
    radius: radius ?? this.radius,
    result: clearResult ? null : result ?? this.result,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    trace,
    travelMode,
    radius,
    result,
    status,
    failure,
  ];
}

class SnapCubit extends Cubit<SnapState> {
  SnapCubit(this._snap, this._routes) : super(const SnapState());

  final SnapToRoads _snap;
  final CalculateRoutes _routes;

  /// Assumed walking/driving pace between tapped points.
  static const _secondsPerPoint = 15;

  void addPoint(GeoPoint p) {
    final start = state.trace.firstOrNull?.timestamp ?? DateTime.now();
    emit(
      state.copyWith(
        trace: [
          ...state.trace,
          TracePoint(
            position: p,
            timestamp: start.add(
              Duration(seconds: state.trace.length * _secondsPerPoint),
            ),
          ),
        ],
        clearResult: true,
      ),
    );
  }

  void undo() {
    if (state.trace.isEmpty) return;
    emit(
      state.copyWith(
        trace: state.trace.sublist(0, state.trace.length - 1),
        clearResult: true,
      ),
    );
  }

  void clear() =>
      emit(SnapState(travelMode: state.travelMode, radius: state.radius));

  void setTravelMode(TravelMode m) =>
      emit(state.copyWith(travelMode: m, clearResult: true));

  void setRadius(int r) => emit(state.copyWith(radius: r, clearResult: true));

  /// Builds a realistic noisy GPS trace: a real route between the first and
  /// last tapped points, sampled every ~40 m with up to 12 m of jitter.
  Future<void> generateNoisyTrace() async {
    if (state.trace.length < 2) return;
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _routes(
      RouteRequest(
        origin: state.trace.first.position,
        destination: state.trace.last.position,
        travelMode: state.travelMode,
        maxAlternatives: 0,
      ),
    );
    if (isClosed) return;
    final route = r.valueOrNull?.routes.firstOrNull;
    if (route == null) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          failure:
              r.failureOrNull ??
              const ValidationFailure(
                'No route between those points.',
                code: AppFailureCode.snapNoRoute,
              ),
        ),
      );
      return;
    }
    final random = math.Random(42);
    final path = GeoUtils.densify(route.geometry, 40);
    final step = route.duration / math.max(1, path.length - 1);
    final start = DateTime.now();
    final points = [
      for (final (i, p) in path.take(SnapToRoads.maxPoints).indexed)
        TracePoint(
          position: GeoUtils.jitter(p, 12, random),
          timestamp: start.add(
            Duration(milliseconds: (i * step * 1000).round()),
          ),
        ),
    ];
    emit(
      state.copyWith(trace: points, clearResult: true, status: LoadStatus.idle),
    );
  }

  Future<void> snap() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _snap(
      SnapRequest(
        points: state.trace,
        travelMode: state.travelMode,
        snapRadiusMeters: state.radius,
      ),
    );
    if (isClosed) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (res) => emit(state.copyWith(result: res, status: LoadStatus.success)),
    );
  }
}
