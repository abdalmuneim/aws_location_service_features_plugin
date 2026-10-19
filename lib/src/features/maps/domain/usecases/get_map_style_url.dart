import 'package:equatable/equatable.dart';

import '../../../../core/entities/map_style_options.dart';
import '../repositories/maps_repository.dart';

class MapStyleParams extends Equatable {
  const MapStyleParams({required this.options, this.politicalView});

  final MapStyleOptions options;
  final String? politicalView;

  @override
  List<Object?> get props => [options, politicalView];
}

/// Builds the GetStyleDescriptor URL consumed by MapLibre. Synchronous:
/// MapLibre fetches the descriptor, tiles, glyphs and sprites itself.
class GetMapStyleUrl {
  const GetMapStyleUrl(this._repository);

  final MapsRepository _repository;

  String call(MapStyleParams params) => _repository.styleDescriptorUrl(
    params.options.sanitized(),
    politicalView: params.options.supportsPoliticalView
        ? params.politicalView
        : null,
  );
}
