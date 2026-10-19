import 'package:flutter/material.dart';

IconData placeTypeIcon(String placeType) => switch (placeType) {
  'PointOfInterest' => Icons.place,
  'PointAddress' || 'InterpolatedAddress' || 'SecondaryAddress' => Icons.home,
  'Street' => Icons.add_road,
  'Intersection' => Icons.fork_right,
  'Locality' || 'SubRegion' || 'Region' => Icons.location_city,
  'District' || 'SubDistrict' => Icons.holiday_village,
  'PostalCode' => Icons.markunread_mailbox,
  'Country' => Icons.flag,
  _ => Icons.location_on,
};

/// Common Places v2 category ids for nearby search filters (names come
/// from `nearbyCategoryLabel`).
const Map<String, IconData> nearbyCategories = {
  'restaurant': Icons.restaurant,
  'coffee_shop': Icons.local_cafe,
  'fast_food': Icons.fastfood,
  'hotel': Icons.hotel,
  'grocery': Icons.local_grocery_store,
  'shopping_mall': Icons.local_mall,
  'drugstore_or_pharmacy': Icons.local_pharmacy,
  'hospital': Icons.local_hospital,
  'atm': Icons.atm,
  'bank': Icons.account_balance,
  'petrol-gasoline_station': Icons.local_gas_station,
  'parking_lot': Icons.local_parking,
  'tourist_attraction': Icons.attractions,
  'museum': Icons.museum,
  'park-recreation_area': Icons.park,
  'fitness-health_club': Icons.fitness_center,
  'mosque': Icons.mosque,
  'school': Icons.school,
  'higher_education': Icons.account_balance_outlined,
  'cinema': Icons.movie,
  'police_station': Icons.local_police,
  'train_station': Icons.train,
  'bus_station': Icons.directions_bus,
  'airport': Icons.flight,
};
