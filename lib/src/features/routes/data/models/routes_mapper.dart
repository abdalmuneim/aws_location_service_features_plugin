import '../../../../core/entities/geo_point.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_analysis.dart';
import '../../domain/entities/route_options.dart';

/// Builds Routes v2 request bodies and parses their responses.
///
/// Geometry is always requested in the `Simple` (GeoJSON) format so no
/// flexible-polyline decoding is needed.
abstract final class RoutesMapper {
  static List<double> _p(GeoPoint p) => JsonUtils.position(p);

  static Map<String, Object?> avoid(AvoidOptions a) => {
    if (a.tollRoads) 'TollRoads': true,
    if (a.ferries) 'Ferries': true,
    if (a.controlledAccessHighways) 'ControlledAccessHighways': true,
    if (a.tunnels) 'Tunnels': true,
    if (a.uTurns) 'UTurns': true,
    if (a.dirtRoads) 'DirtRoads': true,
    if (a.carShuttleTrains) 'CarShuttleTrains': true,
  };

  static Map<String, Object?> traffic(bool use) => {
    'Usage': use ? 'UseTrafficData' : 'IgnoreTrafficData',
  };

  static Map<String, Object?>? truckOptions(TravelMode mode, TruckProfile t) =>
      mode != TravelMode.truck
      ? null
      : {
          'Truck': {
            'TruckType': t.type.apiValue,
            'GrossWeight': t.grossWeightKg,
            'Height': t.heightCm,
            'Width': t.widthCm,
            'Length': t.lengthCm,
            'AxleCount': t.axleCount,
          },
        };

  // ------------------------------------------------------------ Routes

  static Map<String, Object?> routeBody(RouteRequest r, String language) => {
    'Origin': _p(r.origin),
    'Destination': _p(r.destination),
    'Waypoints': [
      for (final w in r.waypoints) {'Position': _p(w)},
    ],
    'TravelMode': r.travelMode.apiValue,
    'OptimizeRoutingFor': r.travelMode == TravelMode.pedestrian
        ? null
        : r.optimizeFor.apiValue,
    'Avoid': r.travelMode == TravelMode.pedestrian ? null : avoid(r.avoid),
    'MaxAlternatives': r.waypoints.isEmpty ? r.maxAlternatives : null,
    'DepartureTime': r.departureTime?.toUtc().toIso8601String(),
    'DepartNow': r.departureTime == null ? true : null,
    'Traffic': traffic(r.useTraffic),
    'TravelModeOptions': truckOptions(r.travelMode, r.truck),
    'LegGeometryFormat': 'Simple',
    'LegAdditionalFeatures': [
      'TravelStepInstructions',
      'Summary',
      if (r.travelMode != TravelMode.pedestrian) 'Tolls',
    ],
    'InstructionsMeasurementSystem': r.units.apiValue,
    'Languages': [language],
  };

  static RouteResult parseRoutes(Map<String, dynamic> json) => RouteResult(
    routes: [
      for (final route in JsonUtils.mapList(json['Routes'])) _route(route),
    ],
    notices: [
      for (final n in JsonUtils.mapList(json['Notices']))
        '${n['Code'] ?? 'Notice'}${n['Impact'] != null ? ' (${n['Impact']})' : ''}',
    ],
    raw: json,
  );

  static RouteOption _route(Map<String, dynamic> json) {
    final summary = JsonUtils.map(json['Summary']);
    final legs = [for (final l in JsonUtils.mapList(json['Legs'])) _leg(l)];
    return RouteOption(
      distance:
          JsonUtils.toInt(summary['Distance']) ??
          legs.fold<int>(0, (s, l) => s + l.distance),
      duration:
          JsonUtils.toInt(summary['Duration']) ??
          legs.fold<int>(0, (s, l) => s + l.duration),
      legs: legs,
      majorRoads: [
        for (final label in JsonUtils.mapList(json['MajorRoadLabels']))
          ?JsonUtils.string(
            JsonUtils.map(label['RoadName'])['Value'] ??
                JsonUtils.map(label['RouteNumber'])['Value'],
          ),
      ],
      tollSummary: _tolls(JsonUtils.map(summary['Tolls'])),
    );
  }

  static TollCost? _tolls(Map<String, dynamic> tolls) {
    final total = JsonUtils.map(tolls['Total']);
    if (total.isEmpty) return null;
    final range = JsonUtils.map(total['Range']);
    final min = JsonUtils.toDouble(range['Min']);
    if (min == null) return null;
    return TollCost(
      currency: JsonUtils.string(total['Currency']) ?? '',
      min: min,
      max: JsonUtils.toDouble(range['Max']),
    );
  }

  static RouteLeg _leg(Map<String, dynamic> json) {
    final details = JsonUtils.map(
      json['VehicleLegDetails'] ??
          json['PedestrianLegDetails'] ??
          json['FerryLegDetails'],
    );
    final overview = JsonUtils.map(
      JsonUtils.map(details['Summary'])['Overview'],
    );
    final steps = [
      for (final s in JsonUtils.mapList(details['TravelSteps']))
        RouteStep(
          instruction:
              JsonUtils.string(s['Instruction']) ??
              JsonUtils.string(s['Type']) ??
              '',
          type: JsonUtils.string(s['Type']) ?? '',
          distance: JsonUtils.toInt(s['Distance']) ?? 0,
          duration: JsonUtils.toInt(s['Duration']) ?? 0,
          geometryOffset: JsonUtils.toInt(s['GeometryOffset']),
        ),
    ];
    return RouteLeg(
      travelMode: JsonUtils.string(json['TravelMode']) ?? '',
      type: JsonUtils.string(json['Type']) ?? '',
      geometry: JsonUtils.parseLineString(
        JsonUtils.map(json['Geometry'])['LineString'],
      ),
      steps: steps,
      distance:
          JsonUtils.toInt(overview['Distance']) ??
          steps.fold<int>(0, (s, e) => s + e.distance),
      duration:
          JsonUtils.toInt(overview['Duration']) ??
          steps.fold<int>(0, (s, e) => s + e.duration),
    );
  }

  // ---------------------------------------------------------- Isolines

  static Map<String, Object?> isolineBody(IsolineRequest r) => {
    'Origin': _p(r.origin),
    'Thresholds': {r.kind.label: r.thresholds},
    'TravelMode': r.travelMode.apiValue,
    'IsolineGeometryFormat': 'Simple',
    'Avoid': r.travelMode == TravelMode.pedestrian ? null : avoid(r.avoid),
    'Traffic': traffic(r.useTraffic),
    'DepartNow': true,
  };

  static IsolineResult parseIsolines(
    Map<String, dynamic> json,
    ThresholdKind kind,
  ) => IsolineResult(
    isolines: [
      for (final iso in JsonUtils.mapList(json['Isolines']))
        Isoline(
          threshold:
              JsonUtils.toInt(
                iso['TimeThreshold'] ?? iso['DistanceThreshold'],
              ) ??
              0,
          kind: kind,
          polygons: [
            for (final g in JsonUtils.mapList(iso['Geometries']))
              if (g['Polygon'] is List)
                [
                  for (final ring in g['Polygon'] as List)
                    JsonUtils.parseLineString(ring),
                ],
          ],
        ),
    ],
    snappedOrigin: JsonUtils.parsePosition(json['SnappedOrigin']),
    raw: json,
  );

  // ------------------------------------------------------ Route matrix

  static Map<String, Object?> matrixBody(RouteMatrixRequest r) => {
    'Origins': [
      for (final o in r.origins) {'Position': _p(o)},
    ],
    'Destinations': [
      for (final d in r.destinations) {'Position': _p(d)},
    ],
    'RoutingBoundary': {'Unbounded': true},
    'TravelMode': r.travelMode.apiValue,
    'OptimizeRoutingFor': r.travelMode == TravelMode.pedestrian
        ? null
        : r.optimizeFor.apiValue,
    'Avoid': r.travelMode == TravelMode.pedestrian ? null : avoid(r.avoid),
    'Traffic': traffic(r.useTraffic),
    'DepartNow': true,
  };

  static RouteMatrix parseMatrix(Map<String, dynamic> json) {
    final rows = json['RouteMatrix'] is List
        ? json['RouteMatrix'] as List
        : const [];
    return RouteMatrix(
      rows: [
        for (final row in rows)
          [
            for (final cell in JsonUtils.mapList(row))
              MatrixCell(
                distance: JsonUtils.toInt(cell['Distance']),
                duration: JsonUtils.toInt(cell['Duration']),
                error: JsonUtils.string(cell['Error']),
              ),
          ],
      ],
      errorCount: JsonUtils.toInt(json['ErrorCount']) ?? 0,
      raw: json,
    );
  }

  // -------------------------------------------------- Optimize waypoints

  static Map<String, Object?> optimizeBody(OptimizeWaypointsRequest r) => {
    'Origin': _p(r.origin),
    'Destination': r.destination == null ? null : _p(r.destination!),
    'Waypoints': [
      for (final s in r.stops)
        {
          'Id': s.id,
          'Position': _p(s.position),
          'ServiceDuration': s.serviceSeconds > 0 ? s.serviceSeconds : null,
        },
    ],
    'TravelMode': r.travelMode.apiValue,
    'OptimizeSequencingFor': r.optimizeFor.apiValue,
  };

  static OptimizedTour parseOptimized(Map<String, dynamic> json) =>
      OptimizedTour(
        stops: [
          for (final w in JsonUtils.mapList(json['OptimizedWaypoints']))
            OptimizedStop(
              id: JsonUtils.string(w['Id']) ?? '',
              position:
                  JsonUtils.parsePosition(w['Position']) ??
                  const GeoPoint(0, 0),
              arrival: DateTime.tryParse('${w['ArrivalTime'] ?? ''}'),
              departure: DateTime.tryParse('${w['DepartureTime'] ?? ''}'),
            ),
        ],
        connections: [
          for (final c in JsonUtils.mapList(json['Connections']))
            OptimizedConnection(
              from: JsonUtils.string(c['From']) ?? '',
              to: JsonUtils.string(c['To']) ?? '',
              distance: JsonUtils.toInt(c['Distance']) ?? 0,
              duration: JsonUtils.toInt(c['TravelDuration']) ?? 0,
            ),
        ],
        distance: JsonUtils.toInt(json['Distance']) ?? 0,
        duration: JsonUtils.toInt(json['Duration']) ?? 0,
        impedingStops: [
          for (final w in JsonUtils.mapList(json['ImpedingWaypoints']))
            JsonUtils.string(w['Id']) ?? '?',
        ],
        raw: json,
      );

  // ------------------------------------------------------- Snap to roads

  static Map<String, Object?> snapBody(SnapRequest r) => {
    'TracePoints': [
      for (final t in r.points)
        {
          'Position': _p(t.position),
          'Timestamp': t.timestamp?.toUtc().toIso8601String(),
          'Speed': t.speedKmh,
          'Heading': t.heading,
        },
    ],
    'TravelMode': r.travelMode.apiValue,
    'SnapRadius': r.snapRadiusMeters,
    'SnappedGeometryFormat': 'Simple',
  };

  static SnapResult parseSnap(Map<String, dynamic> json) => SnapResult(
    geometry: JsonUtils.parseLineString(
      JsonUtils.map(json['SnappedGeometry'])['LineString'],
    ),
    points: [
      for (final p in JsonUtils.mapList(json['SnappedTracePoints']))
        SnappedPoint(
          original:
              JsonUtils.parsePosition(p['OriginalPosition']) ??
              const GeoPoint(0, 0),
          snapped:
              JsonUtils.parsePosition(p['SnappedPosition']) ??
              const GeoPoint(0, 0),
          confidence: JsonUtils.toDouble(p['Confidence']) ?? 0,
        ),
    ],
    notices: [
      for (final n in JsonUtils.mapList(json['Notices']))
        '${n['Code'] ?? 'Notice'}: points ${JsonUtils.stringList(n['TracePointIndexes']).join(', ')}',
    ],
    raw: json,
  );
}
