import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import 'route_options.dart';

// ---------------------------------------------------------------- Isolines

enum ThresholdKind {
  time('Time'),
  distance('Distance');

  const ThresholdKind(this.label);

  final String label;
}

class IsolineRequest extends Equatable {
  const IsolineRequest({
    required this.origin,
    required this.thresholds,
    this.kind = ThresholdKind.time,
    this.travelMode = TravelMode.car,
    this.avoid = const AvoidOptions(),
    this.useTraffic = true,
  });

  final GeoPoint origin;

  /// Seconds for [ThresholdKind.time], meters for [ThresholdKind.distance].
  final List<int> thresholds;
  final ThresholdKind kind;
  final TravelMode travelMode;
  final AvoidOptions avoid;
  final bool useTraffic;

  @override
  List<Object?> get props => [
    origin,
    thresholds,
    kind,
    travelMode,
    avoid,
    useTraffic,
  ];
}

class Isoline extends Equatable {
  const Isoline({
    required this.threshold,
    required this.kind,
    required this.polygons,
  });

  final int threshold;
  final ThresholdKind kind;

  /// Each polygon is a list of rings (outer ring first).
  final List<List<List<GeoPoint>>> polygons;

  @override
  List<Object?> get props => [threshold, kind, polygons];
}

class IsolineResult extends Equatable {
  const IsolineResult({
    required this.isolines,
    this.snappedOrigin,
    this.raw = const {},
  });

  final List<Isoline> isolines;
  final GeoPoint? snappedOrigin;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [isolines, snappedOrigin];
}

// ------------------------------------------------------------ Route matrix

class RouteMatrixRequest extends Equatable {
  const RouteMatrixRequest({
    required this.origins,
    required this.destinations,
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
    this.avoid = const AvoidOptions(),
    this.useTraffic = true,
  });

  final List<GeoPoint> origins;
  final List<GeoPoint> destinations;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;
  final AvoidOptions avoid;
  final bool useTraffic;

  @override
  List<Object?> get props => [
    origins,
    destinations,
    travelMode,
    optimizeFor,
    avoid,
    useTraffic,
  ];
}

class MatrixCell extends Equatable {
  const MatrixCell({this.distance, this.duration, this.error});

  final int? distance;
  final int? duration;
  final String? error;

  @override
  List<Object?> get props => [distance, duration, error];
}

class RouteMatrix extends Equatable {
  const RouteMatrix({
    required this.rows,
    this.errorCount = 0,
    this.raw = const {},
  });

  /// rows[origin][destination].
  final List<List<MatrixCell>> rows;
  final int errorCount;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [rows, errorCount];
}

// ------------------------------------------------------ Optimize waypoints

class OptimizationStop extends Equatable {
  const OptimizationStop({
    required this.id,
    required this.position,
    this.serviceSeconds = 0,
  });

  final String id;
  final GeoPoint position;

  /// Time spent at the stop, e.g. a delivery.
  final int serviceSeconds;

  @override
  List<Object?> get props => [id, position, serviceSeconds];
}

class OptimizeWaypointsRequest extends Equatable {
  const OptimizeWaypointsRequest({
    required this.origin,
    required this.stops,
    this.destination,
    this.travelMode = TravelMode.car,
    this.optimizeFor = RouteOptimization.fastest,
  });

  final GeoPoint origin;
  final GeoPoint? destination;
  final List<OptimizationStop> stops;
  final TravelMode travelMode;
  final RouteOptimization optimizeFor;

  @override
  List<Object?> get props => [
    origin,
    destination,
    stops,
    travelMode,
    optimizeFor,
  ];
}

class OptimizedStop extends Equatable {
  const OptimizedStop({
    required this.id,
    required this.position,
    this.arrival,
    this.departure,
  });

  final String id;
  final GeoPoint position;
  final DateTime? arrival;
  final DateTime? departure;

  @override
  List<Object?> get props => [id, position, arrival, departure];
}

class OptimizedConnection extends Equatable {
  const OptimizedConnection({
    required this.from,
    required this.to,
    required this.distance,
    required this.duration,
  });

  final String from;
  final String to;
  final int distance;
  final int duration;

  @override
  List<Object?> get props => [from, to, distance, duration];
}

class OptimizedTour extends Equatable {
  const OptimizedTour({
    required this.stops,
    required this.connections,
    required this.distance,
    required this.duration,
    this.impedingStops = const [],
    this.raw = const {},
  });

  /// Visiting order, including "Origin" and (optionally) "Destination".
  final List<OptimizedStop> stops;
  final List<OptimizedConnection> connections;
  final int distance;
  final int duration;

  /// Stops that could not be visited under the given constraints.
  final List<String> impedingStops;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [stops, connections, distance, duration];
}

// ----------------------------------------------------------- Snap to roads

class TracePoint extends Equatable {
  const TracePoint({
    required this.position,
    this.timestamp,
    this.speedKmh,
    this.heading,
  });

  final GeoPoint position;
  final DateTime? timestamp;
  final double? speedKmh;
  final double? heading;

  @override
  List<Object?> get props => [position, timestamp, speedKmh, heading];
}

class SnapRequest extends Equatable {
  const SnapRequest({
    required this.points,
    this.travelMode = TravelMode.car,
    this.snapRadiusMeters = 100,
  });

  final List<TracePoint> points;
  final TravelMode travelMode;
  final int snapRadiusMeters;

  @override
  List<Object?> get props => [points, travelMode, snapRadiusMeters];
}

class SnappedPoint extends Equatable {
  const SnappedPoint({
    required this.original,
    required this.snapped,
    required this.confidence,
  });

  final GeoPoint original;
  final GeoPoint snapped;

  /// 0–1.
  final double confidence;

  @override
  List<Object?> get props => [original, snapped, confidence];
}

class SnapResult extends Equatable {
  const SnapResult({
    required this.geometry,
    required this.points,
    this.notices = const [],
    this.raw = const {},
  });

  final List<GeoPoint> geometry;
  final List<SnappedPoint> points;
  final List<String> notices;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [geometry, points, notices];
}
