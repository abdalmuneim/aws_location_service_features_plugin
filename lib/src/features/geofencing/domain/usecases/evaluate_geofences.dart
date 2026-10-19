import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import '../entities/geofence.dart';

class GeofenceEvaluationParams extends Equatable {
  const GeofenceEvaluationParams({
    required this.geofences,
    required this.position,
    required this.previouslyInside,
    required this.time,
  });

  final List<Geofence> geofences;
  final GeoPoint position;

  /// Ids of geofences the device was inside at the previous update.
  final Set<String> previouslyInside;
  final DateTime time;

  @override
  List<Object?> get props => [geofences, position, previouslyInside, time];
}

class GeofenceEvaluation extends Equatable {
  const GeofenceEvaluation({required this.inside, required this.events});

  final Set<String> inside;
  final List<GeofenceEvent> events;

  @override
  List<Object?> get props => [inside, events];
}

/// Compares a new device position with the previous state and emits
/// ENTER/EXIT events, the same way Amazon Location evaluates positions sent
/// to a tracker linked to a geofence collection.
class EvaluateGeofences {
  const EvaluateGeofences();

  GeofenceEvaluation call(GeofenceEvaluationParams params) {
    final inside = <String>{};
    final events = <GeofenceEvent>[];
    for (final g in params.geofences) {
      final isInside = g.shape.contains(params.position);
      final wasInside = params.previouslyInside.contains(g.id);
      if (isInside) inside.add(g.id);
      if (isInside != wasInside) {
        events.add(
          GeofenceEvent(
            geofenceId: g.id,
            geofenceName: g.name,
            transition: isInside
                ? GeofenceTransition.enter
                : GeofenceTransition.exit,
            position: params.position,
            time: params.time,
          ),
        );
      }
    }
    return GeofenceEvaluation(inside: inside, events: events);
  }
}
