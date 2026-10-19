import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../routes/domain/entities/route.dart';
import '../../../routes/domain/entities/route_options.dart';
import '../../../routes/domain/usecases/calculate_routes.dart';
import '../entities/device_position.dart';

class SimulateTripParams extends Equatable {
  const SimulateTripParams({
    required this.from,
    required this.to,
    this.travelMode = TravelMode.car,
    this.sampleEveryMeters = 25,
  });

  final GeoPoint from;
  final GeoPoint to;
  final TravelMode travelMode;
  final double sampleEveryMeters;

  @override
  List<Object?> get props => [from, to, travelMode, sampleEveryMeters];
}

/// Plans a real route with the Routes API and turns it into a timed series
/// of device positions moving at the route's average speed. Used to try
/// tracking and geofencing without leaving the desk.
class SimulateTrip
    implements UseCase<List<DevicePosition>, SimulateTripParams> {
  const SimulateTrip(this._calculateRoutes);

  final CalculateRoutes _calculateRoutes;

  @override
  Future<Result<List<DevicePosition>>> call(SimulateTripParams params) async {
    final result = await _calculateRoutes(
      RouteRequest(
        origin: params.from,
        destination: params.to,
        travelMode: params.travelMode,
        maxAlternatives: 0,
      ),
    );
    return result.map((routes) {
      final route = routes.routes.firstOrNull;
      if (route == null || route.geometry.length < 2) return <DevicePosition>[];
      final path = GeoUtils.densify(route.geometry, params.sampleEveryMeters);
      final length = GeoUtils.pathLength(path);
      final speed = route.duration > 0 ? length / route.duration : 10.0;
      final start = DateTime.now();
      final positions = <DevicePosition>[];
      var traveled = 0.0;
      for (var i = 0; i < path.length; i++) {
        if (i > 0) traveled += GeoUtils.distance(path[i - 1], path[i]);
        positions.add(
          DevicePosition(
            point: path[i],
            timestamp: start.add(
              Duration(milliseconds: (traveled / speed * 1000).round()),
            ),
            speedMps: speed,
            heading: i + 1 < path.length
                ? GeoUtils.bearing(path[i], path[i + 1])
                : null,
            accuracyMeters: 5,
          ),
        );
      }
      return positions;
    });
  }
}
