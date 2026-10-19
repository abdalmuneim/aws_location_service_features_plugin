import '../../../../core/entities/map_style_options.dart';
import '../../../../core/result/result.dart';
import '../entities/static_map.dart';

abstract interface class MapsRepository {
  /// URL of the MapLibre style descriptor for the given options.
  String styleDescriptorUrl(MapStyleOptions options, {String? politicalView});

  Future<Result<StaticMapImage>> getStaticMap(StaticMapRequest request);
}
