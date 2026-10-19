import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/entities/measurement_units.dart';
import 'route_options.dart';

class RouteRequest extends Equatable {
  const RouteRequest({
    required this.origin,
    required this.destination,
    this.waypoints = const [],
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
    this.avoid = const AvoidOptions(),
    this.maxAlternatives = 2,
    this.departureTime,
    this.useTraffic = true,
    this.truck = const TruckProfile(),
    this.units = MeasurementUnits.metric,
  });

  final GeoPoint origin;
  final GeoPoint destination;
  final List<GeoPoint> waypoints;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;
  final AvoidOptions avoid;

  /// 0–5 alternative routes. Ignored by the API when waypoints are set.
  final int maxAlternatives;

  /// Null means "depart now".
  final DateTime? departureTime;
  final bool useTraffic;
  final TruckProfile truck;
  final MeasurementUnits units;

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
    units,
  ];
}

class RouteStep extends Equatable {
  const RouteStep({
    required this.instruction,
    required this.type,
    required this.distance,
    required this.duration,
    this.geometryOffset,
  });

  final String instruction;
  final String type;

  /// Meters / seconds.
  final int distance;
  final int duration;

  /// Index into the leg geometry where this step starts.
  final int? geometryOffset;

  @override
  List<Object?> get props => [instruction, type, distance, duration];
}

class RouteLeg extends Equatable {
  const RouteLeg({
    required this.travelMode,
    required this.type,
    required this.geometry,
    required this.steps,
    required this.distance,
    required this.duration,
  });

  final String travelMode;

  /// Vehicle, Pedestrian or Ferry.
  final String type;
  final List<GeoPoint> geometry;
  final List<RouteStep> steps;
  final int distance;
  final int duration;

  @override
  List<Object?> get props => [travelMode, type, geometry, steps];
}

/// Estimated toll cost of a route in [currency] (ISO 4217).
class TollCost extends Equatable {
  const TollCost({required this.currency, required this.min, this.max});

  final String currency;
  final double min;

  /// Upper bound when the cost varies; null (or [min]) for a fixed cost.
  final double? max;

  bool get isRange => max != null && max != min;

  @override
  List<Object?> get props => [currency, min, max];
}

class RouteOption extends Equatable {
  const RouteOption({
    required this.distance,
    required this.duration,
    required this.legs,
    this.majorRoads = const [],
    this.tollSummary,
  });

  final int distance;
  final int duration;
  final List<RouteLeg> legs;
  final List<String> majorRoads;

  /// Estimated tolls, when toll data is available.
  final TollCost? tollSummary;

  List<GeoPoint> get geometry => [for (final l in legs) ...l.geometry];

  List<RouteStep> get steps => [for (final l in legs) ...l.steps];

  @override
  List<Object?> get props => [
    distance,
    duration,
    legs,
    majorRoads,
    tollSummary,
  ];
}

class RouteResult extends Equatable {
  const RouteResult({
    required this.routes,
    this.notices = const [],
    this.raw = const {},
  });

  final List<RouteOption> routes;
  final List<String> notices;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [routes, notices];
}
