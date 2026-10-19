import 'package:equatable/equatable.dart';

import '../../../../core/entities/geo_point.dart';

/// The parts of a postal address; the presentation layer names them.
enum AddressField {
  building,
  number,
  street,
  subDistrict,
  district,
  locality,
  subRegion,
  region,
  postalCode,
  country,
}

class PlaceAddress extends Equatable {
  const PlaceAddress({
    this.label,
    this.country,
    this.countryCode,
    this.region,
    this.subRegion,
    this.locality,
    this.district,
    this.subDistrict,
    this.postalCode,
    this.street,
    this.addressNumber,
    this.building,
  });

  final String? label;
  final String? country;
  final String? countryCode;
  final String? region;
  final String? subRegion;
  final String? locality;
  final String? district;
  final String? subDistrict;
  final String? postalCode;
  final String? street;
  final String? addressNumber;
  final String? building;

  /// Non-empty components as (field, value) pairs, for detail views.
  List<(AddressField, String)> get components => [
    if (building != null) (AddressField.building, building!),
    if (addressNumber != null) (AddressField.number, addressNumber!),
    if (street != null) (AddressField.street, street!),
    if (subDistrict != null) (AddressField.subDistrict, subDistrict!),
    if (district != null) (AddressField.district, district!),
    if (locality != null) (AddressField.locality, locality!),
    if (subRegion != null) (AddressField.subRegion, subRegion!),
    if (region != null) (AddressField.region, region!),
    if (postalCode != null) (AddressField.postalCode, postalCode!),
    if (country != null)
      (
        AddressField.country,
        countryCode == null ? country! : '$country ($countryCode)',
      ),
  ];

  @override
  List<Object?> get props => [
    label,
    country,
    countryCode,
    region,
    subRegion,
    locality,
    district,
    subDistrict,
    postalCode,
    street,
    addressNumber,
    building,
  ];
}

class PlaceCategory extends Equatable {
  const PlaceCategory({
    required this.id,
    required this.name,
    this.localizedName,
    this.primary = false,
  });

  final String id;
  final String name;
  final String? localizedName;
  final bool primary;

  String get displayName => localizedName ?? name;

  @override
  List<Object?> get props => [id, name, localizedName, primary];
}

class PlaceContacts extends Equatable {
  const PlaceContacts({
    this.phones = const [],
    this.websites = const [],
    this.emails = const [],
    this.faxes = const [],
  });

  final List<String> phones;
  final List<String> websites;
  final List<String> emails;
  final List<String> faxes;

  bool get isEmpty =>
      phones.isEmpty && websites.isEmpty && emails.isEmpty && faxes.isEmpty;

  @override
  List<Object?> get props => [phones, websites, emails, faxes];
}

class OpeningHours extends Equatable {
  const OpeningHours({this.display = const [], this.openNow});

  final List<String> display;
  final bool? openNow;

  @override
  List<Object?> get props => [display, openNow];
}

class PlaceTimeZone extends Equatable {
  const PlaceTimeZone({required this.name, this.offset});

  final String name;
  final String? offset;

  @override
  List<Object?> get props => [name, offset];
}

/// A place returned by any Places API (geocode, search, details…).
class Place extends Equatable {
  const Place({
    required this.placeId,
    required this.placeType,
    required this.title,
    this.address,
    this.position,
    this.distance,
    this.categories = const [],
    this.foodTypes = const [],
    this.businessChains = const [],
    this.contacts = const PlaceContacts(),
    this.openingHours = const [],
    this.timeZone,
    this.accessPoints = const [],
    this.mapView,
    this.politicalView,
    this.raw = const {},
  });

  final String placeId;
  final String placeType;
  final String title;
  final PlaceAddress? address;
  final GeoPoint? position;

  /// Meters from the query/bias position, when the API reports it.
  final int? distance;
  final List<PlaceCategory> categories;
  final List<String> foodTypes;
  final List<String> businessChains;
  final PlaceContacts contacts;
  final List<OpeningHours> openingHours;
  final PlaceTimeZone? timeZone;
  final List<GeoPoint> accessPoints;

  /// Suggested viewport for the place.
  final GeoBounds? mapView;
  final String? politicalView;

  /// The untouched API item, shown in "Raw response" panels.
  final Map<String, dynamic> raw;

  String get subtitle => address?.label ?? placeType;

  PlaceCategory? get primaryCategory =>
      categories.where((c) => c.primary).firstOrNull ?? categories.firstOrNull;

  Place withDistance(int? value) => Place(
    placeId: placeId,
    placeType: placeType,
    title: title,
    address: address,
    position: position,
    distance: value,
    categories: categories,
    foodTypes: foodTypes,
    businessChains: businessChains,
    contacts: contacts,
    openingHours: openingHours,
    timeZone: timeZone,
    accessPoints: accessPoints,
    mapView: mapView,
    politicalView: politicalView,
    raw: raw,
  );

  @override
  List<Object?> get props => [placeId, title, position, distance, raw];
}

/// A page of places from SearchText / SearchNearby.
class PlacePage extends Equatable {
  const PlacePage({required this.places, this.nextToken, this.raw = const {}});

  final List<Place> places;
  final String? nextToken;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [places, nextToken];
}

/// An Autocomplete result. Autocomplete returns no coordinates; resolve
/// [placeId] with GetPlace to locate it.
class AutocompleteSuggestion extends Equatable {
  const AutocompleteSuggestion({
    required this.placeId,
    required this.placeType,
    required this.title,
    this.addressLabel,
    this.distance,
    this.raw = const {},
  });

  final String placeId;
  final String placeType;
  final String title;
  final String? addressLabel;
  final int? distance;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [placeId, title, addressLabel, distance];
}

enum SuggestionKind { place, query }

/// A Suggest result: either a concrete [place] or a query refinement that
/// can be expanded with SearchText using [queryId].
class Suggestion extends Equatable {
  const Suggestion({
    required this.title,
    required this.kind,
    this.place,
    this.queryId,
    this.queryType,
    this.raw = const {},
  });

  final String title;
  final SuggestionKind kind;
  final Place? place;
  final String? queryId;
  final String? queryType;
  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [title, kind, place, queryId];
}
