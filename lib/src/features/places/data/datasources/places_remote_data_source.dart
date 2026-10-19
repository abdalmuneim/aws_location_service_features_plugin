import '../../../../core/config/aws_location_config.dart';
import '../../../../core/network/aws_location_http_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_queries.dart';
import '../models/place_model.dart';

abstract interface class PlacesRemoteDataSource {
  Future<List<Place>> geocode(GeocodeParams params);

  Future<List<Place>> reverseGeocode(ReverseGeocodeParams params);

  Future<List<AutocompleteSuggestion>> autocomplete(AutocompleteParams params);

  Future<List<Suggestion>> suggest(SuggestParams params);

  Future<PlacePage> searchText(SearchTextParams params);

  Future<PlacePage> searchNearby(SearchNearbyParams params);

  Future<Place> getPlace(GetPlaceParams params);
}

/// Calls the Places v2 REST API. Language and political view come from the
/// user's settings via [AwsLocationConfig].
class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  const PlacesRemoteDataSourceImpl(this._client, this._config);

  final AwsLocationHttpClient _client;
  final AwsLocationConfig _config;

  static const _service = AwsLocationService.places;

  Map<String, Object?> get _locale => {
    'Language': _config.language,
    'PoliticalView': _config.politicalView,
  };

  static List<String> _features(List<PlaceFeature> f) =>
      f.map((e) => e.apiValue).toList();

  static List<String> _types(List<PlaceTypeFilter> t) =>
      t.map((e) => e.apiValue).toList();

  List<Place> _items(Map<String, dynamic> json) => [
    for (final item in JsonUtils.mapList(json['ResultItems']))
      PlaceModel.fromJson(item),
  ];

  @override
  Future<List<Place>> geocode(GeocodeParams p) async {
    final c = p.components;
    final json = await _client.postJson(_service, '/geocode', {
      'QueryText': p.queryText?.trim(),
      if (c != null)
        'QueryComponents': {
          'Country': c.country,
          'Region': c.region,
          'SubRegion': c.subRegion,
          'Locality': c.locality,
          'District': c.district,
          'Street': c.street,
          'AddressNumber': c.addressNumber,
          'PostalCode': c.postalCode,
        },
      'BiasPosition': p.biasPosition == null
          ? null
          : JsonUtils.position(p.biasPosition!),
      'Filter': {
        'IncludeCountries': p.includeCountries,
        'IncludePlaceTypes': _types(p.includePlaceTypes),
      },
      'MaxResults': p.maxResults,
      'AdditionalFeatures': _features(p.features),
      ..._locale,
    });
    return _items(json);
  }

  @override
  Future<List<Place>> reverseGeocode(ReverseGeocodeParams p) async {
    final json = await _client.postJson(_service, '/reverse-geocode', {
      'QueryPosition': JsonUtils.position(p.position),
      'QueryRadius': p.radiusMeters,
      'MaxResults': p.maxResults,
      'Filter': {'IncludePlaceTypes': _types(p.includePlaceTypes)},
      'AdditionalFeatures': _features(p.features),
      ..._locale,
    });
    return _items(json);
  }

  @override
  Future<List<AutocompleteSuggestion>> autocomplete(
    AutocompleteParams p,
  ) async {
    final json = await _client.postJson(_service, '/autocomplete', {
      'QueryText': p.queryText.trim(),
      'BiasPosition': p.biasPosition == null
          ? null
          : JsonUtils.position(p.biasPosition!),
      'Filter': {
        'IncludeCountries': p.includeCountries,
        'IncludePlaceTypes': _types(p.includePlaceTypes),
      },
      'MaxResults': p.maxResults,
      ..._locale,
    });
    return [
      for (final item in JsonUtils.mapList(json['ResultItems']))
        PlaceModel.autocompleteFromJson(item),
    ];
  }

  @override
  Future<List<Suggestion>> suggest(SuggestParams p) async {
    final json = await _client.postJson(_service, '/suggest', {
      'QueryText': p.queryText.trim(),
      'BiasPosition': JsonUtils.position(p.biasPosition),
      'MaxResults': p.maxResults,
      'MaxQueryRefinements': p.maxQueryRefinements,
      'AdditionalFeatures': _features(p.features),
      ..._locale,
    });
    return [
      for (final item in JsonUtils.mapList(json['ResultItems']))
        PlaceModel.suggestionFromJson(item),
    ];
  }

  /// A Suggest query id already carries the query text, position, limits
  /// and options, so the API rejects any other field alongside it.
  @override
  Future<PlacePage> searchText(SearchTextParams p) async {
    final useCircle = p.circleCenter != null && p.circleRadius != null;
    final body = p.queryId != null
        ? <String, Object?>{'QueryId': p.queryId}
        : <String, Object?>{
            'QueryText': p.queryText?.trim(),
            'BiasPosition': !useCircle && p.biasPosition != null
                ? JsonUtils.position(p.biasPosition!)
                : null,
            'Filter': {
              if (useCircle)
                'Circle': {
                  'Center': JsonUtils.position(p.circleCenter!),
                  'Radius': p.circleRadius,
                },
              'IncludeCountries': p.includeCountries,
            },
            'MaxResults': p.maxResults,
            'NextToken': p.nextToken,
            'AdditionalFeatures': _features(p.features),
            ..._locale,
          };
    final json = await _client.postJson(_service, '/search-text', body);
    return PlacePage(
      places: _items(json),
      nextToken: JsonUtils.string(json['NextToken']),
      raw: json,
    );
  }

  @override
  Future<PlacePage> searchNearby(SearchNearbyParams p) async {
    final json = await _client.postJson(_service, '/search-nearby', {
      'QueryPosition': JsonUtils.position(p.position),
      'QueryRadius': p.radiusMeters,
      'Filter': {
        'IncludeCategories': p.includeCategories,
        'ExcludeCategories': p.excludeCategories,
        'IncludeFoodTypes': p.includeFoodTypes,
        'IncludeBusinessChains': p.includeBusinessChains,
      },
      'MaxResults': p.maxResults,
      'NextToken': p.nextToken,
      'AdditionalFeatures': _features(p.features),
      ..._locale,
    });
    return PlacePage(
      places: _items(json),
      nextToken: JsonUtils.string(json['NextToken']),
      raw: json,
    );
  }

  @override
  Future<Place> getPlace(GetPlaceParams p) async {
    final json = await _client.getJson(
      _service,
      '/place/${Uri.encodeComponent(p.placeId)}',
      {
        'additional-features': _features(p.features),
        'language': _config.language,
        'political-view': _config.politicalView,
      },
    );
    return PlaceModel.fromJson(json);
  }
}
