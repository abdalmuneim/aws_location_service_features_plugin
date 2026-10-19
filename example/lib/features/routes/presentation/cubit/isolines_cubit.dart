import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

class IsolinesState extends Equatable {
  const IsolinesState({
    this.origin,
    this.kind = ThresholdKind.time,
    this.thresholds = const [300, 600, 900],
    this.travelMode = TravelMode.car,
    this.avoid = const AvoidOptions(),
    this.useTraffic = true,
    this.result,
    this.status = LoadStatus.idle,
    this.failure,
    this.savedGeofence,
  });

  final NamedLocation? origin;
  final ThresholdKind kind;

  /// Seconds or meters, depending on [kind].
  final List<int> thresholds;
  final TravelMode travelMode;
  final AvoidOptions avoid;
  final bool useTraffic;
  final IsolineResult? result;
  final LoadStatus status;
  final Failure? failure;

  /// Name of a geofence just saved from an isoline (one-off confirmation).
  final String? savedGeofence;

  IsolinesState copyWith({
    NamedLocation? origin,
    ThresholdKind? kind,
    List<int>? thresholds,
    TravelMode? travelMode,
    AvoidOptions? avoid,
    bool? useTraffic,
    IsolineResult? result,
    bool clearResult = false,
    LoadStatus? status,
    Failure? failure,
    String? savedGeofence,
  }) => IsolinesState(
    origin: origin ?? this.origin,
    kind: kind ?? this.kind,
    thresholds: thresholds ?? this.thresholds,
    travelMode: travelMode ?? this.travelMode,
    avoid: avoid ?? this.avoid,
    useTraffic: useTraffic ?? this.useTraffic,
    result: clearResult ? null : result ?? this.result,
    status: status ?? this.status,
    failure: failure,
    savedGeofence: savedGeofence,
  );

  @override
  List<Object?> get props => [
    origin,
    kind,
    thresholds,
    travelMode,
    avoid,
    useTraffic,
    result,
    status,
    failure,
    savedGeofence,
  ];
}

class IsolinesCubit extends Cubit<IsolinesState> {
  IsolinesCubit(this._calculate, this._saveGeofence, {NamedLocation? origin})
    : super(IsolinesState(origin: origin)) {
    if (origin != null) calculate();
  }

  final CalculateIsolines _calculate;
  final SaveGeofence _saveGeofence;
  int _request = 0;

  static const timePresets = [300, 600, 900, 1200, 1800, 2700, 3600];
  static const distancePresets = [500, 1000, 2000, 5000, 10000, 20000, 50000];

  void _update(IsolinesState next) {
    emit(next.copyWith(clearResult: true));
    calculate();
  }

  void setOrigin(GeoPoint p) => _update(
    state.copyWith(
      origin: NamedLocation(point: p, label: p.format()),
    ),
  );

  void setNamedOrigin(NamedLocation l) => _update(state.copyWith(origin: l));

  void setKind(ThresholdKind kind) => _update(
    state.copyWith(
      kind: kind,
      thresholds: kind == ThresholdKind.time
          ? const [300, 600, 900]
          : const [1000, 2000, 5000],
    ),
  );

  void toggleThreshold(int value) {
    final next = [...state.thresholds];
    if (!next.remove(value)) {
      if (next.length >= CalculateIsolines.maxThresholds) return;
      next.add(value);
    }
    next.sort();
    _update(state.copyWith(thresholds: next));
  }

  void setTravelMode(TravelMode m) => _update(state.copyWith(travelMode: m));

  void setAvoid(AvoidOptions a) => _update(state.copyWith(avoid: a));

  void setTraffic(bool v) => _update(state.copyWith(useTraffic: v));

  Future<void> calculate() async {
    final s = state;
    if (s.origin == null || s.thresholds.isEmpty) return;
    final id = ++_request;
    emit(s.copyWith(status: LoadStatus.loading));
    final r = await _calculate(
      IsolineRequest(
        origin: s.origin!.point,
        thresholds: s.thresholds,
        kind: s.kind,
        travelMode: s.travelMode,
        avoid: s.avoid,
        useTraffic: s.useTraffic,
      ),
    );
    if (isClosed || id != _request) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (res) => emit(state.copyWith(result: res, status: LoadStatus.success)),
    );
  }

  /// Stores the outer ring of [isoline] as a polygon geofence.
  Future<void> saveAsGeofence(
    Isoline isoline,
    String name,
    int color,
    String description,
  ) async {
    final polygon = isoline.polygons.firstOrNull?.firstOrNull;
    if (polygon == null) return;
    final r = await _saveGeofence(
      Geofence(
        id: 'iso-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        shape: PolygonShape(_simplify(polygon)),
        colorValue: color,
        createdAt: DateTime.now(),
        source: GeofenceSource.isoline,
        description: description,
      ),
    );
    if (isClosed) return;
    r.fold(
      (f) => emit(state.copyWith(failure: f)),
      (_) => emit(state.copyWith(savedGeofence: name)),
    );
  }

  /// Keeps at most ~300 vertices so stored geofences stay small.
  static List<GeoPoint> _simplify(List<GeoPoint> ring) {
    if (ring.length <= 300) return ring;
    final step = (ring.length / 300).ceil();
    return [for (var i = 0; i < ring.length; i += step) ring[i]];
  }
}
