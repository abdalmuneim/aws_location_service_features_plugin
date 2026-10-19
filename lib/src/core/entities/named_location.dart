import 'package:equatable/equatable.dart';

import 'geo_point.dart';

/// A coordinate with a human-readable label, e.g. a picked route stop.
class NamedLocation extends Equatable {
  const NamedLocation({required this.point, required this.label});

  final GeoPoint point;
  final String label;

  @override
  List<Object?> get props => [point, label];
}
