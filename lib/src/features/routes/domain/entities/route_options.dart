import 'package:equatable/equatable.dart';

enum TravelMode {
  car('Car', 'Car'),
  pedestrian('Walk', 'Pedestrian'),
  scooter('Scooter', 'Scooter'),
  truck('Truck', 'Truck');

  const TravelMode(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

enum RouteOptimization {
  fastest('Fastest', 'FastestRoute'),
  shortest('Shortest', 'ShortestRoute');

  const RouteOptimization(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

/// Road features a route should avoid.
class AvoidOptions extends Equatable {
  const AvoidOptions({
    this.tollRoads = false,
    this.ferries = false,
    this.controlledAccessHighways = false,
    this.tunnels = false,
    this.uTurns = false,
    this.dirtRoads = false,
    this.carShuttleTrains = false,
  });

  final bool tollRoads;
  final bool ferries;
  final bool controlledAccessHighways;
  final bool tunnels;
  final bool uTurns;
  final bool dirtRoads;
  final bool carShuttleTrains;

  bool get any => props.any((v) => v == true);

  int get count => props.where((v) => v == true).length;

  AvoidOptions copyWith({
    bool? tollRoads,
    bool? ferries,
    bool? controlledAccessHighways,
    bool? tunnels,
    bool? uTurns,
    bool? dirtRoads,
    bool? carShuttleTrains,
  }) => AvoidOptions(
    tollRoads: tollRoads ?? this.tollRoads,
    ferries: ferries ?? this.ferries,
    controlledAccessHighways:
        controlledAccessHighways ?? this.controlledAccessHighways,
    tunnels: tunnels ?? this.tunnels,
    uTurns: uTurns ?? this.uTurns,
    dirtRoads: dirtRoads ?? this.dirtRoads,
    carShuttleTrains: carShuttleTrains ?? this.carShuttleTrains,
  );

  @override
  List<Object?> get props => [
    tollRoads,
    ferries,
    controlledAccessHighways,
    tunnels,
    uTurns,
    dirtRoads,
    carShuttleTrains,
  ];
}

enum TruckType {
  straightTruck('Straight truck', 'StraightTruck'),
  tractor('Tractor', 'Tractor'),
  lightTruck('Light truck', 'LightTruck');

  const TruckType(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

/// Vehicle dimensions used for truck routing restrictions.
class TruckProfile extends Equatable {
  const TruckProfile({
    this.type = TruckType.straightTruck,
    this.grossWeightKg = 12000,
    this.heightCm = 380,
    this.widthCm = 250,
    this.lengthCm = 1000,
    this.axleCount = 3,
  });

  final TruckType type;
  final int grossWeightKg;
  final int heightCm;
  final int widthCm;
  final int lengthCm;
  final int axleCount;

  TruckProfile copyWith({
    TruckType? type,
    int? grossWeightKg,
    int? heightCm,
    int? widthCm,
    int? lengthCm,
    int? axleCount,
  }) => TruckProfile(
    type: type ?? this.type,
    grossWeightKg: grossWeightKg ?? this.grossWeightKg,
    heightCm: heightCm ?? this.heightCm,
    widthCm: widthCm ?? this.widthCm,
    lengthCm: lengthCm ?? this.lengthCm,
    axleCount: axleCount ?? this.axleCount,
  );

  @override
  List<Object?> get props => [
    type,
    grossWeightKg,
    heightCm,
    widthCm,
    lengthCm,
    axleCount,
  ];
}
