import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';

enum GeofenceTool {
  test('Test point'),
  circle('Circle'),
  polygon('Polygon');

  const GeofenceTool(this.label);

  final String label;
}

class GeofencesState extends Equatable {
  const GeofencesState({
    this.geofences = const [],
    this.tool = GeofenceTool.test,
    this.circleCenter,
    this.radius = 500,
    this.vertices = const [],
    this.testPoint,
    this.inside = const {},
    this.status = LoadStatus.idle,
    this.failure,
  });

  final List<Geofence> geofences;
  final GeofenceTool tool;
  final GeoPoint? circleCenter;
  final double radius;
  final List<GeoPoint> vertices;
  final GeoPoint? testPoint;

  /// Geofences containing [testPoint].
  final Set<String> inside;
  final LoadStatus status;
  final Failure? failure;

  bool get hasDraft => switch (tool) {
    GeofenceTool.circle => circleCenter != null,
    GeofenceTool.polygon => vertices.length >= 3,
    GeofenceTool.test => false,
  };

  GeofencesState copyWith({
    List<Geofence>? geofences,
    GeofenceTool? tool,
    GeoPoint? circleCenter,
    bool clearDraft = false,
    double? radius,
    List<GeoPoint>? vertices,
    GeoPoint? testPoint,
    Set<String>? inside,
    LoadStatus? status,
    Failure? failure,
  }) => GeofencesState(
    geofences: geofences ?? this.geofences,
    tool: tool ?? this.tool,
    circleCenter: clearDraft ? null : circleCenter ?? this.circleCenter,
    radius: radius ?? this.radius,
    vertices: clearDraft ? const [] : vertices ?? this.vertices,
    testPoint: testPoint ?? this.testPoint,
    inside: inside ?? this.inside,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    geofences,
    tool,
    circleCenter,
    radius,
    vertices,
    testPoint,
    inside,
    status,
    failure,
  ];
}

/// Creates, stores and tests geofences on the device.
class GeofencesCubit extends Cubit<GeofencesState> {
  GeofencesCubit(
    this._get,
    this._save,
    this._delete,
    this._clear,
    this._evaluate,
  ) : super(const GeofencesState());

  final GetGeofences _get;
  final SaveGeofence _save;
  final DeleteGeofence _delete;
  final ClearGeofences _clear;
  final EvaluateGeofences _evaluate;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final r = await _get(const NoParams());
    if (isClosed) return;
    _apply(r.valueOrNull, r.failureOrNull);
  }

  void setTool(GeofenceTool tool) =>
      emit(state.copyWith(tool: tool, clearDraft: true));

  void setRadius(double r) => emit(state.copyWith(radius: r));

  void tap(GeoPoint p) {
    switch (state.tool) {
      case GeofenceTool.test:
        emit(state.copyWith(testPoint: p, inside: _insideAt(p)));
      case GeofenceTool.circle:
        emit(state.copyWith(circleCenter: p));
      case GeofenceTool.polygon:
        emit(state.copyWith(vertices: [...state.vertices, p]));
    }
  }

  void undoVertex() {
    if (state.vertices.isEmpty) return;
    emit(
      state.copyWith(
        vertices: state.vertices.sublist(0, state.vertices.length - 1),
      ),
    );
  }

  Future<bool> saveDraft(String name, int color) async {
    final shape = switch (state.tool) {
      GeofenceTool.circle when state.circleCenter != null => CircleShape(
        centerPoint: state.circleCenter!,
        radiusMeters: state.radius,
      ),
      GeofenceTool.polygon => PolygonShape(state.vertices),
      _ => null,
    };
    if (shape == null) return false;
    final r = await _save(
      Geofence(
        id: 'gf-${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        shape: shape,
        colorValue: color,
        createdAt: DateTime.now(),
        source: shape is CircleShape
            ? GeofenceSource.circle
            : GeofenceSource.polygon,
      ),
    );
    if (isClosed) return false;
    if (r.isOk) emit(state.copyWith(clearDraft: true));
    _apply(r.valueOrNull, r.failureOrNull);
    return r.isOk;
  }

  Future<void> delete(String id) async {
    final r = await _delete(id);
    if (!isClosed) _apply(r.valueOrNull, r.failureOrNull);
  }

  Future<void> clearAll() async {
    final r = await _clear(const NoParams());
    if (!isClosed) _apply(r.valueOrNull, r.failureOrNull);
  }

  Set<String> _insideAt(GeoPoint p, [List<Geofence>? list]) => _evaluate(
    GeofenceEvaluationParams(
      geofences: list ?? state.geofences,
      position: p,
      previouslyInside: const {},
      time: DateTime.now(),
    ),
  ).inside;

  void _apply(List<Geofence>? list, Failure? failure) {
    if (list == null) {
      emit(state.copyWith(status: LoadStatus.failure, failure: failure));
      return;
    }
    emit(
      state.copyWith(
        geofences: list,
        inside: state.testPoint == null
            ? {}
            : _insideAt(state.testPoint!, list),
        status: LoadStatus.success,
      ),
    );
  }
}
