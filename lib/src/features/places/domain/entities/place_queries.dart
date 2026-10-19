import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';

/// Optional extra data the Places APIs can return.
enum PlaceFeature {
  contact('Contact'),
  timeZone('TimeZone'),
  phonemes('Phonemes'),
  access('Access'),
  intersections('Intersections'),
  secondaryAddresses('SecondaryAddresses'),
  core('Core');

  const PlaceFeature(this.apiValue);

  final String apiValue;
}

/// Place types used by Geocode / ReverseGeocode / Autocomplete filters.
enum PlaceTypeFilter {
  locality('Locality'),
  postalCode('PostalCode'),
  intersection('Intersection'),
  street('Street'),
  pointAddress('PointAddress'),
  interpolatedAddress('InterpolatedAddress');

  const PlaceTypeFilter(this.apiValue);

  final String apiValue;
}

/// Structured address input for Geocode.
class AddressComponents extends Equatable {
  const AddressComponents({
    this.country,
    this.region,
    this.subRegion,
    this.locality,
    this.district,
    this.street,
    this.addressNumber,
    this.postalCode,
  });

  final String? country;
  final String? region;
  final String? subRegion;
  final String? locality;
  final String? district;
  final String? street;
  final String? addressNumber;
  final String? postalCode;

  bool get isEmpty => props.every((v) => v == null || (v as String).isEmpty);

  @override
  List<Object?> get props => [
    country,
    region,
    subRegion,
    locality,
    district,
    street,
    addressNumber,
    postalCode,
  ];
}

class GeocodeParams extends Equatable {
  const GeocodeParams({
    this.queryText,
    this.components,
    this.biasPosition,
    this.includeCountries = const [],
    this.includePlaceTypes = const [],
    this.maxResults = 10,
    this.features = const [PlaceFeature.timeZone, PlaceFeature.access],
  });

  final String? queryText;
  final AddressComponents? components;
  final GeoPoint? biasPosition;
  final List<String> includeCountries;
  final List<PlaceTypeFilter> includePlaceTypes;
  final int maxResults;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [
    queryText,
    components,
    biasPosition,
    includeCountries,
    includePlaceTypes,
    maxResults,
    features,
  ];
}

class ReverseGeocodeParams extends Equatable {
  const ReverseGeocodeParams({
    required this.position,
    this.radiusMeters,
    this.maxResults = 1,
    this.includePlaceTypes = const [],
    this.features = const [PlaceFeature.timeZone, PlaceFeature.access],
  });

  final GeoPoint position;
  final int? radiusMeters;
  final int maxResults;
  final List<PlaceTypeFilter> includePlaceTypes;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [
    position,
    radiusMeters,
    maxResults,
    includePlaceTypes,
    features,
  ];
}

class AutocompleteParams extends Equatable {
  const AutocompleteParams({
    required this.queryText,
    this.biasPosition,
    this.includeCountries = const [],
    this.includePlaceTypes = const [],
    this.maxResults = 6,
  });

  final String queryText;
  final GeoPoint? biasPosition;
  final List<String> includeCountries;
  final List<PlaceTypeFilter> includePlaceTypes;
  final int maxResults;

  @override
  List<Object?> get props => [
    queryText,
    biasPosition,
    includeCountries,
    includePlaceTypes,
    maxResults,
  ];
}

class SuggestParams extends Equatable {
  const SuggestParams({
    required this.queryText,
    required this.biasPosition,
    this.maxResults = 8,
    this.maxQueryRefinements = 3,
    this.features = const [PlaceFeature.core],
  });

  final String queryText;
  final GeoPoint biasPosition;
  final int maxResults;
  final int maxQueryRefinements;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [
    queryText,
    biasPosition,
    maxResults,
    maxQueryRefinements,
    features,
  ];
}

/// SearchText takes free text *or* a Suggest [queryId], and exactly one of
/// [biasPosition] or a [circleCenter]/[circleRadius] filter.
class SearchTextParams extends Equatable {
  const SearchTextParams({
    this.queryText,
    this.queryId,
    this.biasPosition,
    this.circleCenter,
    this.circleRadius,
    this.includeCountries = const [],
    this.maxResults = 15,
    this.nextToken,
    this.features = const [PlaceFeature.contact, PlaceFeature.timeZone],
  });

  final String? queryText;
  final String? queryId;
  final GeoPoint? biasPosition;
  final GeoPoint? circleCenter;
  final int? circleRadius;
  final List<String> includeCountries;
  final int maxResults;
  final String? nextToken;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [
    queryText,
    queryId,
    biasPosition,
    circleCenter,
    circleRadius,
    includeCountries,
    maxResults,
    nextToken,
    features,
  ];
}

class SearchNearbyParams extends Equatable {
  const SearchNearbyParams({
    required this.position,
    this.radiusMeters = 1000,
    this.includeCategories = const [],
    this.excludeCategories = const [],
    this.includeFoodTypes = const [],
    this.includeBusinessChains = const [],
    this.maxResults = 20,
    this.nextToken,
    this.features = const [
      PlaceFeature.contact,
      PlaceFeature.timeZone,
      PlaceFeature.access,
    ],
  });

  final GeoPoint position;
  final int radiusMeters;
  final List<String> includeCategories;
  final List<String> excludeCategories;
  final List<String> includeFoodTypes;
  final List<String> includeBusinessChains;
  final int maxResults;
  final String? nextToken;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [
    position,
    radiusMeters,
    includeCategories,
    excludeCategories,
    includeFoodTypes,
    includeBusinessChains,
    maxResults,
    nextToken,
    features,
  ];
}

class GetPlaceParams extends Equatable {
  const GetPlaceParams({
    required this.placeId,
    this.features = const [
      PlaceFeature.contact,
      PlaceFeature.timeZone,
      PlaceFeature.access,
      PlaceFeature.phonemes,
    ],
  });

  final String placeId;
  final List<PlaceFeature> features;

  @override
  List<Object?> get props => [placeId, features];
}
