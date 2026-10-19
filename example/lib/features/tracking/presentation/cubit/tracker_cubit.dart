import 'dart:async';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure_code.dart';
import '../../../../core/presentation/load_status.dart';

enum TrackingSource {
  gps('Device GPS'),
  simulation('Simulated trip');

  const TrackingSource(this.label);

  final String label;
}

class TrackerState extends Equatable {
  const TrackerState({
    this.source = TrackingSource.simulation,
    this.tracking = false,
    this.positions = const [],
    this.geofences = const [],
    this.inside = const {},
    this.events = const [],
    this.address,
    this.simFrom,
    this.simTo,
    this.simMode = TravelMode.car,
    this.speedUp = 10,
    this.snapped = const [],
    this.status = LoadStatus.idle,
    this.failure,
  });

  final TrackingSource source;
  final bool tracking;
  final List<DevicePosition> positions;
  final List<Geofence> geofences;
  final Set<String> inside;

  /// Newest first.
  final List<GeofenceEvent> events;

  /// Reverse-geocoded address of the latest position.
  final String? address;
  final GeoPoint? simFrom;
  final GeoPoint? simTo;
  final TravelMode simMode;

  /// Playback speed multiplier for simulated trips.
  final int speedUp;

  /// Trail matched to roads by SnapToRoads.
  final List<GeoPoint> snapped;
  final LoadStatus status;
  final Failure? failure;

  DevicePosition? get current => positions.lastOrNull;

  List<GeoPoint> get trail => [for (final p in positions) p.point];

  double get distance => GeoUtils.pathLength(trail);

  Duration get elapsed => positions.length < 2
      ? Duration.zero
      : positions.last.timestamp.difference(positions.first.timestamp);

  TrackerState copyWith({
    TrackingSource? source,
    bool? tracking,
    List<DevicePosition>? positions,
    List<Geofence>? geofences,
    Set<String>? inside,
    List<GeofenceEvent>? events,
    String? address,
    GeoPoint? simFrom,
    GeoPoint? simTo,
    bool clearSim = false,
    TravelMode? simMode,
    int? speedUp,
    List<GeoPoint>? snapped,
    LoadStatus? status,
    Failure? failure,
  }) => TrackerState(
    source: source ?? this.source,
    tracking: tracking ?? this.tracking,
    positions: positions ?? this.positions,
    geofences: geofences ?? this.geofences,
    inside: inside ?? this.inside,
    events: events ?? this.events,
    address: address ?? this.address,
    simFrom: clearSim ? null : simFrom ?? this.simFrom,
    simTo: clearSim ? null : simTo ?? this.simTo,
    simMode: simMode ?? this.simMode,
    speedUp: speedUp ?? this.speedUp,
    snapped: snapped ?? this.snapped,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    source,
    tracking,
    positions,
    geofences,
    inside,
    events,
    address,
    simFrom,
    simTo,
    simMode,
    speedUp,
    snapped,
    status,
    failure,
  ];
}

/// Device tracking with on-device geofence evaluation, periodic reverse
/// geocoding of the latest position and snap-to-roads of the trail.
class TrackerCubit extends Cubit<TrackerState> {
  TrackerCubit(
    this._watch,
    this._simulate,
    this._getGeofences,
    this._evaluate,
    this._reverse,
    this._snap,
  ) : super(const TrackerState());

  final WatchLocation _watch;
  final SimulateTrip _simulate;
  final GetGeofences _getGeofences;
  final EvaluateGeofences _evaluate;
  final ReverseGeocode _reverse;
  final SnapToRoads _snap;

  StreamSubscription<Result<DevicePosition>>? _gps;
  Timer? _player;
  GeoPoint? _lastGeocoded;
  DateTime? _lastGeocodeAt;

  Future<void> init() async {
    final r = await _getGeofences(const NoParams());
    if (!isClosed) emit(state.copyWith(geofences: r.valueOrNull ?? const []));
  }

  void setSource(TrackingSource s) {
    stop();
    emit(state.copyWith(source: s));
  }

  void setSimMode(TravelMode m) => emit(state.copyWith(simMode: m));

  void setSpeedUp(int v) => emit(state.copyWith(speedUp: v));

  /// In simulation mode, taps choose the trip start and end.
  void tapAt(GeoPoint p) {
    if (state.source != TrackingSource.simulation || state.tracking) return;
    if (state.simFrom == null || state.simTo != null) {
      emit(state.copyWith(clearSim: true).copyWith(simFrom: p));
    } else {
      emit(state.copyWith(simTo: p));
    }
  }

  Future<void> start() async {
    stop();
    emit(
      state.copyWith(
        positions: const [],
        events: const [],
        inside: const {},
        snapped: const [],
        tracking: true,
        status: LoadStatus.loading,
      ),
    );
    _lastGeocoded = null;
    if (state.source == TrackingSource.gps) {
      _gps = _watch(5).listen((r) {
        r.fold((f) {
          emit(
            state.copyWith(
              tracking: false,
              status: LoadStatus.failure,
              failure: f,
            ),
          );
          stop();
        }, _onPosition);
      });
      emit(state.copyWith(status: LoadStatus.success));
    } else {
      await _startSimulation();
    }
  }

  Future<void> _startSimulation() async {
    final from = state.simFrom, to = state.simTo;
    if (from == null || to == null) {
      emit(
        state.copyWith(
          tracking: false,
          status: LoadStatus.failure,
          failure: const ValidationFailure(
            'Tap the map twice to choose where the simulated trip starts and ends.',
            code: AppFailureCode.trackerPickTripEnds,
          ),
        ),
      );
      return;
    }
    final r = await _simulate(
      SimulateTripParams(from: from, to: to, travelMode: state.simMode),
    );
    if (isClosed || !state.tracking) return;
    final trip = r.valueOrNull;
    if (trip == null || trip.isEmpty) {
      emit(
        state.copyWith(
          tracking: false,
          status: LoadStatus.failure,
          failure:
              r.failureOrNull ??
              const ValidationFailure(
                'No route found for the simulated trip.',
                code: AppFailureCode.trackerNoRoute,
              ),
        ),
      );
      return;
    }
    emit(state.copyWith(status: LoadStatus.success));

    // Replay the trip, compressing time by [speedUp].
    final t0 = trip.first.timestamp;
    final wallStart = DateTime.now();
    var next = 0;
    _player = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      final simulated = t0.add(
        DateTime.now().difference(wallStart) * state.speedUp,
      );
      while (next < trip.length && !trip[next].timestamp.isAfter(simulated)) {
        _onPosition(trip[next]);
        next++;
      }
      if (next >= trip.length) {
        timer.cancel();
        emit(state.copyWith(tracking: false));
      }
    });
  }

  void stop() {
    _gps?.cancel();
    _gps = null;
    _player?.cancel();
    _player = null;
    if (state.tracking) emit(state.copyWith(tracking: false));
  }

  void _onPosition(DevicePosition p) {
    if (isClosed) return;
    final eval = _evaluate(
      GeofenceEvaluationParams(
        geofences: state.geofences,
        position: p.point,
        previouslyInside: state.inside,
        time: p.timestamp,
      ),
    );
    emit(
      state.copyWith(
        positions: [...state.positions, p],
        inside: eval.inside,
        events: [...eval.events.reversed, ...state.events],
      ),
    );
    _maybeGeocode(p.point);
  }

  /// Reverse geocodes at most every 10 s or 150 m to limit API calls.
  Future<void> _maybeGeocode(GeoPoint p) async {
    final now = DateTime.now();
    final moved = _lastGeocoded == null
        ? double.infinity
        : GeoUtils.distance(_lastGeocoded!, p);
    final waited = _lastGeocodeAt == null
        ? const Duration(days: 1)
        : now.difference(_lastGeocodeAt!);
    if (moved < 150 && waited < const Duration(seconds: 10)) return;
    _lastGeocoded = p;
    _lastGeocodeAt = now;
    final r = await _reverse(ReverseGeocodeParams(position: p));
    final place = r.valueOrNull?.firstOrNull;
    if (!isClosed && place != null) {
      emit(state.copyWith(address: place.address?.label ?? place.title));
    }
  }

  Future<void> snapTrail() async {
    final positions = state.positions;
    if (positions.length < 2) return;
    // Downsample long trails to stay within API limits.
    final step = (positions.length / 1000).ceil();
    final sample = [
      for (var i = 0; i < positions.length; i += step) positions[i],
      if ((positions.length - 1) % step != 0) positions.last,
    ];
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _snap(
      SnapRequest(
        points: [
          for (final p in sample)
            TracePoint(
              position: p.point,
              timestamp: p.timestamp,
              speedKmh: p.speedMps == null ? null : p.speedMps! * 3.6,
              heading: p.heading,
            ),
        ],
        travelMode: state.source == TrackingSource.simulation
            ? state.simMode
            : TravelMode.car,
      ),
    );
    if (isClosed) return;
    r.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (res) => emit(
        state.copyWith(snapped: res.geometry, status: LoadStatus.success),
      ),
    );
  }

  @override
  Future<void> close() {
    _gps?.cancel();
    _player?.cancel();
    return super.close();
  }
}
