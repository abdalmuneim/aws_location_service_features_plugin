import '../../../../core/entities/geo_point.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/place.dart';

/// Parses Places v2 JSON into domain entities.
abstract final class PlaceModel {
  static Place fromJson(Map<String, dynamic> json, {String? fallbackTitle}) {
    final address = _address(JsonUtils.map(json['Address']));
    return Place(
      placeId: JsonUtils.string(json['PlaceId']) ?? '',
      placeType: JsonUtils.string(json['PlaceType']) ?? 'Unknown',
      title:
          JsonUtils.string(json['Title']) ??
          fallbackTitle ??
          address?.label ??
          'Unnamed place',
      address: address,
      position: JsonUtils.parsePosition(json['Position']),
      distance: JsonUtils.toInt(json['Distance']),
      categories: [
        for (final c in JsonUtils.mapList(json['Categories']))
          PlaceCategory(
            id: JsonUtils.string(c['Id']) ?? '',
            name: JsonUtils.string(c['Name']) ?? '',
            localizedName: JsonUtils.string(c['LocalizedName']),
            primary: c['Primary'] == true,
          ),
      ],
      foodTypes: [
        for (final f in JsonUtils.mapList(json['FoodTypes']))
          JsonUtils.string(f['LocalizedName']) ??
              JsonUtils.string(f['Id']) ??
              '',
      ],
      businessChains: [
        for (final b in JsonUtils.mapList(json['BusinessChains']))
          JsonUtils.string(b['Name']) ?? JsonUtils.string(b['Id']) ?? '',
      ],
      contacts: _contacts(JsonUtils.map(json['Contacts'])),
      openingHours: [
        for (final h in JsonUtils.mapList(json['OpeningHours']))
          OpeningHours(
            display: JsonUtils.stringList(h['Display']),
            openNow: h['OpenNow'] as bool?,
          ),
      ],
      timeZone: _timeZone(JsonUtils.map(json['TimeZone'])),
      accessPoints: [
        for (final a in JsonUtils.mapList(json['AccessPoints']))
          ?JsonUtils.parsePosition(a['Position']),
      ],
      mapView: _bounds(json['MapView']),
      politicalView: JsonUtils.string(json['PoliticalView']),
      raw: json,
    );
  }

  static AutocompleteSuggestion autocompleteFromJson(
    Map<String, dynamic> json,
  ) {
    final address = JsonUtils.map(json['Address']);
    return AutocompleteSuggestion(
      placeId: JsonUtils.string(json['PlaceId']) ?? '',
      placeType: JsonUtils.string(json['PlaceType']) ?? 'Unknown',
      title: JsonUtils.string(json['Title']) ?? '',
      addressLabel: JsonUtils.string(address['Label']),
      distance: JsonUtils.toInt(json['Distance']),
      raw: json,
    );
  }

  static Suggestion suggestionFromJson(Map<String, dynamic> json) {
    final title = JsonUtils.string(json['Title']) ?? '';
    final isQuery = json['SuggestResultItemType'] == 'Query';
    final place = JsonUtils.map(json['Place']);
    final query = JsonUtils.map(json['Query']);
    return Suggestion(
      title: title,
      kind: isQuery ? SuggestionKind.query : SuggestionKind.place,
      place: place.isEmpty ? null : fromJson(place, fallbackTitle: title),
      queryId: JsonUtils.string(query['QueryId']),
      queryType: JsonUtils.string(query['QueryType']),
      raw: json,
    );
  }

  static PlaceAddress? _address(Map<String, dynamic> a) {
    if (a.isEmpty) return null;
    final country = JsonUtils.map(a['Country']);
    final region = JsonUtils.map(a['Region']);
    final subRegion = JsonUtils.map(a['SubRegion']);
    return PlaceAddress(
      label: JsonUtils.string(a['Label']),
      country: JsonUtils.string(country['Name']),
      countryCode: JsonUtils.string(country['Code3'] ?? country['Code2']),
      region: JsonUtils.string(region['Name']),
      subRegion: JsonUtils.string(subRegion['Name']),
      locality: JsonUtils.string(a['Locality']),
      district: JsonUtils.string(a['District']),
      subDistrict: JsonUtils.string(a['SubDistrict']),
      postalCode: JsonUtils.string(a['PostalCode']),
      street: JsonUtils.string(a['Street']),
      addressNumber: JsonUtils.string(a['AddressNumber']),
      building: JsonUtils.string(a['Building']),
    );
  }

  static PlaceContacts _contacts(Map<String, dynamic> c) {
    List<String> values(Object? list) => [
      for (final d in JsonUtils.mapList(list)) ?JsonUtils.string(d['Value']),
    ];
    return PlaceContacts(
      phones: values(c['Phones']),
      websites: values(c['Websites']),
      emails: values(c['Emails']),
      faxes: values(c['Faxes']),
    );
  }

  static PlaceTimeZone? _timeZone(Map<String, dynamic> tz) {
    final name = JsonUtils.string(tz['Name']);
    if (name == null) return null;
    return PlaceTimeZone(name: name, offset: JsonUtils.string(tz['Offset']));
  }

  /// MapView is `[west, south, east, north]`.
  static GeoBounds? _bounds(Object? value) {
    if (value is! List || value.length != 4) return null;
    final v = value.map((e) => (e as num).toDouble()).toList();
    return GeoBounds(west: v[0], south: v[1], east: v[2], north: v[3]);
  }
}
