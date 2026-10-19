import 'package:aws_location_service_features/aws_location_service_features.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/formatters.dart';

/// UI name for a Places API place type such as "PointOfInterest". Types the
/// app doesn't know fall back to the humanized API value.
String placeTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'PointOfInterest' => l10n.placeTypePointOfInterest,
  'PointAddress' => l10n.placeTypePointAddress,
  'InterpolatedAddress' => l10n.placeTypeInterpolatedAddress,
  'SecondaryAddress' => l10n.placeTypeSecondaryAddress,
  'Street' => l10n.placeTypeStreet,
  'Intersection' => l10n.placeTypeIntersection,
  'Block' => l10n.placeTypeBlock,
  'SubBlock' => l10n.placeTypeSubBlock,
  'District' => l10n.placeTypeDistrict,
  'SubDistrict' => l10n.placeTypeSubDistrict,
  'Locality' => l10n.placeTypeLocality,
  'SubRegion' => l10n.placeTypeSubRegion,
  'Region' => l10n.placeTypeRegion,
  'PostalCode' => l10n.placeTypePostalCode,
  'Country' => l10n.placeTypeCountry,
  'Point' => l10n.placeTypePoint,
  _ => Formatters.humanize(type),
};

/// UI name for a `nearbyCategories` id.
String nearbyCategoryLabel(AppLocalizations l10n, String id) => switch (id) {
  'restaurant' => l10n.nearbyCategoryRestaurants,
  'coffee_shop' => l10n.nearbyCategoryCoffee,
  'fast_food' => l10n.nearbyCategoryFastFood,
  'hotel' => l10n.nearbyCategoryHotels,
  'grocery' => l10n.nearbyCategoryGroceries,
  'shopping_mall' => l10n.nearbyCategoryMalls,
  'drugstore_or_pharmacy' => l10n.nearbyCategoryPharmacies,
  'hospital' => l10n.nearbyCategoryHospitals,
  'atm' => l10n.nearbyCategoryAtms,
  'bank' => l10n.nearbyCategoryBanks,
  'petrol-gasoline_station' => l10n.nearbyCategoryFuel,
  'parking_lot' => l10n.nearbyCategoryParking,
  'tourist_attraction' => l10n.nearbyCategoryAttractions,
  'museum' => l10n.nearbyCategoryMuseums,
  'park-recreation_area' => l10n.nearbyCategoryParks,
  'fitness-health_club' => l10n.nearbyCategoryGyms,
  'mosque' => l10n.nearbyCategoryMosques,
  'school' => l10n.nearbyCategorySchools,
  'higher_education' => l10n.nearbyCategoryUniversities,
  'cinema' => l10n.nearbyCategoryCinemas,
  'police_station' => l10n.nearbyCategoryPolice,
  'train_station' => l10n.nearbyCategoryTrains,
  'bus_station' => l10n.nearbyCategoryBuses,
  'airport' => l10n.nearbyCategoryAirports,
  _ => Formatters.humanize(id),
};

/// Subtitle for a Suggest query refinement, by its API `QueryType`.
String suggestQueryLabel(AppLocalizations l10n, String? queryType) =>
    switch (queryType) {
      null => l10n.placeSearchQueryGeneric,
      'Category' => l10n.placeSearchQueryCategory,
      'BusinessChain' => l10n.placeSearchQueryBusinessChain,
      _ => l10n.placeSearchQueryOther(
        Formatters.humanize(queryType).toLowerCase(),
      ),
    };

extension AddressFieldL10n on AddressField {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    AddressField.building => l10n.addressBuilding,
    AddressField.number => l10n.addressNumber,
    AddressField.street => l10n.addressStreet,
    AddressField.subDistrict => l10n.addressSubDistrict,
    AddressField.district => l10n.addressDistrict,
    AddressField.locality => l10n.addressLocality,
    AddressField.subRegion => l10n.addressSubRegion,
    AddressField.region => l10n.addressRegion,
    AddressField.postalCode => l10n.addressPostalCode,
    AddressField.country => l10n.addressCountry,
  };
}
