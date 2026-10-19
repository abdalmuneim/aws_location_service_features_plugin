import 'dart:typed_data';

import '../../../../core/entities/map_style_options.dart';
import '../../../../core/network/aws_location_http_client.dart';
import '../../domain/entities/static_map.dart';
import '../models/static_map_query.dart';

abstract interface class MapsRemoteDataSource {
  Uri styleDescriptorUri(MapStyleOptions options, {String? politicalView});

  Uri staticMapUri(StaticMapRequest request);

  Future<Uint8List> fetchStaticMap(Uri uri);
}

class MapsRemoteDataSourceImpl implements MapsRemoteDataSource {
  const MapsRemoteDataSourceImpl(this._client);

  final AwsLocationHttpClient _client;

  @override
  Uri styleDescriptorUri(MapStyleOptions options, {String? politicalView}) =>
      _client.buildUri(
        AwsLocationService.maps,
        '/styles/${options.style.apiValue}/descriptor',
        {
          'color-scheme': options.colorScheme.apiValue,
          'political-view': politicalView,
          'terrain': options.terrain.apiValue,
          'contour-density': options.contourDensity.apiValue,
          'traffic': options.traffic ? 'All' : null,
          'travel-modes': options.travelModes.apiValue,
        },
      );

  @override
  Uri staticMapUri(StaticMapRequest request) => _client.buildUri(
    AwsLocationService.maps,
    request.highDpi ? '/static/map@2x' : '/static/map',
    StaticMapQuery.fromRequest(request),
  );

  @override
  Future<Uint8List> fetchStaticMap(Uri uri) => _client.getBytes(uri);
}
