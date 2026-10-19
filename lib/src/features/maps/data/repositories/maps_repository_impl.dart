import '../../../../core/entities/map_style_options.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/static_map.dart';
import '../../domain/repositories/maps_repository.dart';
import '../datasources/maps_remote_data_source.dart';

class MapsRepositoryImpl implements MapsRepository {
  const MapsRepositoryImpl(this._remote);

  final MapsRemoteDataSource _remote;

  @override
  String styleDescriptorUrl(MapStyleOptions options, {String? politicalView}) =>
      _remote
          .styleDescriptorUri(options, politicalView: politicalView)
          .toString();

  @override
  Future<Result<StaticMapImage>> getStaticMap(StaticMapRequest request) =>
      guard(() async {
        final uri = _remote.staticMapUri(request);
        final bytes = await _remote.fetchStaticMap(uri);
        final redacted = uri.replace(
          queryParameters: {...uri.queryParametersAll, 'key': '•••'},
        );
        return StaticMapImage(
          bytes: bytes,
          url: Uri.decodeFull(redacted.toString()),
        );
      });
}
