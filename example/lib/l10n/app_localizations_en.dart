// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Location Studio';

  @override
  String get commonLanguage => 'Language';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsAppLanguageDevice => 'Device language';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonRawResponse => 'Raw response';

  @override
  String commonApiResponse(String api) {
    return '$api response';
  }

  @override
  String get errorRequestTimedOut => 'The request timed out.';

  @override
  String errorNetwork(String detail) {
    return 'Network error: $detail';
  }

  @override
  String errorHttpStatus(int status) {
    return 'Request failed with HTTP $status.';
  }

  @override
  String errorApiKeyRejected(int status, String detail) {
    return 'The API key was rejected ($status): $detail Check the key, its region and its allowed actions in Settings.';
  }

  @override
  String errorNotFound(String detail) {
    return 'Not found: $detail';
  }

  @override
  String get errorTooManyRequests =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorLocationServicesOff =>
      'Location services are turned off on this device.';

  @override
  String get errorLocationPermissionDenied => 'Location permission denied.';

  @override
  String get errorLocationPermissionDeniedForever =>
      'Location permission is permanently denied. Enable it in system settings.';

  @override
  String get errorSettingsNotSaved => 'Could not save settings.';

  @override
  String get errorAppLanguageNotSaved => 'Could not save the app language.';

  @override
  String get errorGeofencesNotRead => 'Saved geofences could not be read.';

  @override
  String get errorGeofencesNotSaved => 'Could not save geofences.';

  @override
  String get errorGeocodeAddressRequired => 'Enter an address to geocode.';

  @override
  String get errorSearchQueryRequired => 'Enter something to search for.';

  @override
  String get errorGeofenceNameRequired => 'Give the geofence a name.';

  @override
  String get errorGeofencePolygonTooFewPoints =>
      'A polygon needs at least 3 points.';

  @override
  String get errorGeofenceRadiusNotPositive => 'The radius must be positive.';

  @override
  String get errorIsolineThresholdRequired => 'Choose at least one threshold.';

  @override
  String errorIsolineTooManyThresholds(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'At most $max thresholds are allowed.',
      one: 'At most 1 threshold is allowed.',
    );
    return '$_temp0';
  }

  @override
  String get errorRouteSameOriginAndDestination =>
      'Origin and destination are the same place.';

  @override
  String errorRouteTooManyStops(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'A route can have at most $max stops.',
      one: 'A route can have at most 1 stop.',
    );
    return '$_temp0';
  }

  @override
  String get errorMatrixPointsRequired =>
      'Add at least one origin and one destination.';

  @override
  String errorMatrixTooManyPoints(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Use at most $max origins and $max destinations.',
      one: 'Use at most 1 origin and 1 destination.',
    );
    return '$_temp0';
  }

  @override
  String get errorOptimizeStopsRequired =>
      'Add at least one stop besides the start.';

  @override
  String errorOptimizeTooManyStops(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'At most $max stops can be optimized.',
      one: 'At most 1 stop can be optimized.',
    );
    return '$_temp0';
  }

  @override
  String get errorSnapTooFewPoints => 'A trace needs at least 2 points.';

  @override
  String errorSnapTooManyPoints(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'A trace can have at most $max points.',
      one: 'A trace can have at most 1 point.',
    );
    return '$_temp0';
  }

  @override
  String get errorSnapNoRoute => 'No route between those points.';

  @override
  String get errorTrackerPickTripEnds =>
      'Tap the map twice to choose where the simulated trip starts and ends.';

  @override
  String get errorTrackerNoRoute => 'No route found for the simulated trip.';

  @override
  String get commonApiKey => 'API key';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get mapExplorerTitle => 'Map explorer';

  @override
  String get staticMapTitle => 'Static maps';

  @override
  String get searchTitle => 'Search places';

  @override
  String get nearbyTitle => 'Nearby search';

  @override
  String get geocodeTitle => 'Geocoding';

  @override
  String get directionsTitle => 'Directions';

  @override
  String get isolinesTitle => 'Isolines';

  @override
  String get routeMatrixTitle => 'Route matrix';

  @override
  String get optimizeTitle => 'Optimize stops';

  @override
  String get snapTitle => 'Snap to roads';

  @override
  String get geofencesTitle => 'Geofences';

  @override
  String get trackerTitle => 'Tracker';

  @override
  String get homeHeroSubtitle =>
      'Maps, Places and Routes through a single API key.';

  @override
  String get homeSectionMaps => 'Maps';

  @override
  String get homeSectionPlaces => 'Places';

  @override
  String get homeSectionRoutes => 'Routes';

  @override
  String get homeSectionGeofencing => 'Geofencing & tracking';

  @override
  String get homeMapExplorerDescription =>
      'Standard, Monochrome, Hybrid & Satellite styles, dark mode, political views, terrain, contours, traffic and travel-mode layers.';

  @override
  String get homeStaticMapDescription =>
      'Render map images with markers, lines, labels and scale bars.';

  @override
  String get homeSearchTitle => 'Search';

  @override
  String get homeSearchDescription =>
      'Find businesses, POIs and addresses with type-ahead and details.';

  @override
  String get homeNearbyTitle => 'Nearby';

  @override
  String get homeNearbyDescription =>
      'Points of interest around a location, filtered by category.';

  @override
  String get homeGeocodeTitle => 'Geocode';

  @override
  String get homeGeocodeDescription =>
      'Turn free-text or structured addresses into coordinates.';

  @override
  String get homeReverseGeocodeTitle => 'Reverse geocode';

  @override
  String get homeReverseGeocodeDescription =>
      'Turn coordinates into addresses, streets and localities.';

  @override
  String get homeDirectionsDescription =>
      'Car, walking, scooter & truck routes with stops, alternatives, avoidances, traffic and departure times.';

  @override
  String get homeIsolinesDescription =>
      'Areas reachable within a travel time or distance.';

  @override
  String get homeRouteMatrixDescription =>
      'Travel time & distance between many origins and destinations.';

  @override
  String get homeOptimizeDescription =>
      'The best order to visit a set of stops.';

  @override
  String get homeSnapDescription =>
      'Match noisy GPS traces to the road network.';

  @override
  String get homeGeofencesApis => 'On-device evaluation';

  @override
  String get homeGeofencesDescription =>
      'Draw circle & polygon geofences or build them from isolines.';

  @override
  String get homeTrackerDescription =>
      'Live or simulated tracking with ENTER/EXIT geofence events.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDefault => 'Default';

  @override
  String get commonOff => 'Off';

  @override
  String get commonLight => 'Light';

  @override
  String get commonDark => 'Dark';

  @override
  String get commonPoliticalView => 'Political view';

  @override
  String get unitsMetric => 'Metric';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get mapStyleTitle => 'Map style';

  @override
  String get mapStyleStandard => 'Standard';

  @override
  String get mapStyleMonochrome => 'Monochrome';

  @override
  String get mapStyleHybrid => 'Hybrid';

  @override
  String get mapStyleSatellite => 'Satellite';

  @override
  String get mapTerrainHillshade => 'Hillshade';

  @override
  String get mapTerrain3d => '3D terrain';

  @override
  String get mapContoursLow => 'Low';

  @override
  String get mapContoursMedium => 'Medium';

  @override
  String get mapContoursHigh => 'High';

  @override
  String get mapTravelModesTransit => 'Transit';

  @override
  String get mapTravelModesTruck => 'Truck';

  @override
  String get countryArgentina => 'Argentina';

  @override
  String get countryCyprus => 'Cyprus';

  @override
  String get countryEgypt => 'Egypt';

  @override
  String get countryGeorgia => 'Georgia';

  @override
  String get countryGreece => 'Greece';

  @override
  String get countryIndia => 'India';

  @override
  String get countryKenya => 'Kenya';

  @override
  String get countryMorocco => 'Morocco';

  @override
  String get countryPalestine => 'Palestine';

  @override
  String get countryRussia => 'Russia';

  @override
  String get countrySudan => 'Sudan';

  @override
  String get countrySerbia => 'Serbia';

  @override
  String get countrySuriname => 'Suriname';

  @override
  String get countrySyria => 'Syria';

  @override
  String get countryTurkey => 'Turkey';

  @override
  String get countryTanzania => 'Tanzania';

  @override
  String get countryUruguay => 'Uruguay';

  @override
  String get countryVietnam => 'Vietnam';

  @override
  String get settingsSectionConnection => 'Connection';

  @override
  String get settingsSaveKey => 'Save key';

  @override
  String get settingsRegion => 'Region';

  @override
  String get settingsRegionHelper =>
      'Must be the region the API key was created in';

  @override
  String get settingsTestConnection => 'Test connection';

  @override
  String settingsTestSuccess(String answer) {
    return 'Connected. Places API answered: $answer';
  }

  @override
  String get settingsSectionResults => 'Results';

  @override
  String get settingsResultsLanguage => 'Language for places & directions';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsResetDefaults => 'Reset to defaults';

  @override
  String get settingsAboutApiKeysTitle => 'About API keys';

  @override
  String get settingsAboutApiKeysBody =>
      'Amazon Location API keys authorize the Maps, Places and Routes APIs. Restrict the key to the actions you use and to your app\'s referrers/bundle IDs in the AWS console. Geofence collections and trackers require IAM or Cognito credentials.';

  @override
  String get commonMyLocation => 'My location';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonResults => 'Results';

  @override
  String get commonPick => 'Pick';

  @override
  String get commonAdd => 'Add';

  @override
  String mapExplorerCamera(String zoom, String center) {
    return 'z $zoom · $center';
  }

  @override
  String get mapExplorerSearchHint => 'Search places, businesses, addresses';

  @override
  String get mapExplorerLookingUpAddress => 'Looking up address…';

  @override
  String get mapExplorerNoAddress => 'No address found';

  @override
  String get mapExplorerTapHint =>
      'Tap anywhere to see the address (reverse geocoding)';

  @override
  String get mapStyleColorScheme => 'Color scheme';

  @override
  String get mapStylePoliticalViewHelper =>
      'Borders and labels for disputed areas';

  @override
  String get mapStyleNotForSatellite => 'Not available for the Satellite style';

  @override
  String get mapStyleTerrain => 'Terrain';

  @override
  String get mapStyleTerrain3dHint =>
      '3D terrain renders on the web; tilt the map with right-drag or two fingers.';

  @override
  String get mapStyleContours => 'Contour lines';

  @override
  String get mapStyleNotAvailable => 'n/a';

  @override
  String get mapStyleTraffic => 'Real-time traffic';

  @override
  String get mapStyleTravelModes => 'Travel-mode overlay';

  @override
  String get staticMapRender => 'Render';

  @override
  String staticMapImageSize(String size) {
    return '$size KB';
  }

  @override
  String get staticMapRequestUrl => 'Request URL';

  @override
  String get staticMapEmpty => 'Press Render to generate an image.';

  @override
  String get staticMapFraming => 'Framing';

  @override
  String get staticMapFramingCenterZoom => 'Center & zoom';

  @override
  String get staticMapFramingCenterRadius => 'Center & radius';

  @override
  String get staticMapFramingFitMarkers => 'Fit markers';

  @override
  String get staticMapCenter => 'Center';

  @override
  String get staticMapPickCenter => 'Map center';

  @override
  String staticMapZoom(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String staticMapRadius(String meters) {
    return 'Radius $meters m';
  }

  @override
  String staticMapPadding(String pixels) {
    return 'Padding $pixels px';
  }

  @override
  String get staticMapImage => 'Image';

  @override
  String get staticMapSize => 'Size';

  @override
  String get staticMapHighDpi => 'High DPI (@2x)';

  @override
  String get staticMapStyle => 'Style';

  @override
  String get staticMapLabelsSmall => 'Small labels';

  @override
  String get staticMapLabelsLarge => 'Large labels';

  @override
  String get staticMapLabelLanguage => 'Label language';

  @override
  String get staticMapLabelLanguageLocal => 'Local';

  @override
  String get staticMapPointsOfInterest => 'Points of interest';

  @override
  String get staticMapCropLabels => 'Crop labels at the edges';

  @override
  String get staticMapScaleBar => 'Scale bar';

  @override
  String get staticMapScaleKilometers => 'Kilometers';

  @override
  String get staticMapScaleMiles => 'Miles';

  @override
  String get staticMapScaleKilometersMiles => 'Km + Miles';

  @override
  String get staticMapScaleMilesKilometers => 'Miles + Km';

  @override
  String get staticMapMarkers => 'GeoJSON overlay markers';

  @override
  String get staticMapAddMarker => 'Add marker';

  @override
  String get staticMapMarkersHint =>
      'Markers are drawn with the geojson-overlay parameter.';

  @override
  String staticMapMarkerFallback(int number) {
    return 'Marker $number';
  }

  @override
  String get staticMapConnectMarkers => 'Connect markers with a line';

  @override
  String get commonDistance => 'Distance';

  @override
  String get commonLoadMore => 'Load more';

  @override
  String get commonClear => 'Clear';

  @override
  String commonRadius(String distance) {
    return 'Radius $distance';
  }

  @override
  String commonResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get placeActionNearby => 'Nearby';

  @override
  String get placeActionReachableArea => 'Reachable area';

  @override
  String get placeCopyCoordinates => 'Copy coordinates';

  @override
  String get placeCoordinatesCopied => 'Coordinates copied';

  @override
  String get placeAddress => 'Address';

  @override
  String get placeLocation => 'Location';

  @override
  String get placeCoordinates => 'Coordinates';

  @override
  String get placeTimeZone => 'Time zone';

  @override
  String get placeAccessPoints => 'Access points';

  @override
  String get placeContact => 'Contact';

  @override
  String get placePhone => 'Phone';

  @override
  String get placeWebsite => 'Website';

  @override
  String get placeEmail => 'Email';

  @override
  String get placeFax => 'Fax';

  @override
  String get placeOpeningHours => 'Opening hours';

  @override
  String get placeOpenNow => 'Open now';

  @override
  String get placeClosed => 'Closed';

  @override
  String get placeBusinessChain => 'Business chain';

  @override
  String get placeNoCoordinates => 'This place has no coordinates.';

  @override
  String get placeSearchHint => 'Search places or addresses';

  @override
  String get placeSearchMoveMap => 'Move the map to search nearby.';

  @override
  String get placeSearchNoMatches => 'No matches';

  @override
  String get placeSearchQueryGeneric => 'Search query';

  @override
  String get placeSearchQueryCategory => 'Search category';

  @override
  String get placeSearchQueryBusinessChain => 'Search business chain';

  @override
  String placeSearchQueryOther(String type) {
    return 'Search $type';
  }

  @override
  String get placeTypePointOfInterest => 'Point of interest';

  @override
  String get placeTypePointAddress => 'Point address';

  @override
  String get placeTypeInterpolatedAddress => 'Interpolated address';

  @override
  String get placeTypeSecondaryAddress => 'Secondary address';

  @override
  String get placeTypeStreet => 'Street';

  @override
  String get placeTypeIntersection => 'Intersection';

  @override
  String get placeTypeBlock => 'Block';

  @override
  String get placeTypeSubBlock => 'Sub block';

  @override
  String get placeTypeDistrict => 'District';

  @override
  String get placeTypeSubDistrict => 'Sub district';

  @override
  String get placeTypeLocality => 'Locality';

  @override
  String get placeTypeSubRegion => 'Sub region';

  @override
  String get placeTypeRegion => 'Region';

  @override
  String get placeTypePostalCode => 'Postal code';

  @override
  String get placeTypeCountry => 'Country';

  @override
  String get placeTypePoint => 'Point';

  @override
  String get addressBuilding => 'Building';

  @override
  String get addressNumber => 'Number';

  @override
  String get addressStreet => 'Street';

  @override
  String get addressSubDistrict => 'Sub-district';

  @override
  String get addressDistrict => 'District';

  @override
  String get addressLocality => 'Locality';

  @override
  String get addressSubRegion => 'Sub-region';

  @override
  String get addressRegion => 'Region';

  @override
  String get addressPostalCode => 'Postal code';

  @override
  String get addressCountry => 'Country';

  @override
  String get nearbyTapHint => 'Tap the map to search around that point';

  @override
  String get nearbyCategories => 'Categories';

  @override
  String nearbyPlacesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get nearbyEmpty => 'Nothing found. Try a larger radius.';

  @override
  String get nearbyCategoryRestaurants => 'Restaurants';

  @override
  String get nearbyCategoryCoffee => 'Coffee';

  @override
  String get nearbyCategoryFastFood => 'Fast food';

  @override
  String get nearbyCategoryHotels => 'Hotels';

  @override
  String get nearbyCategoryGroceries => 'Groceries';

  @override
  String get nearbyCategoryMalls => 'Malls';

  @override
  String get nearbyCategoryPharmacies => 'Pharmacies';

  @override
  String get nearbyCategoryHospitals => 'Hospitals';

  @override
  String get nearbyCategoryAtms => 'ATMs';

  @override
  String get nearbyCategoryBanks => 'Banks';

  @override
  String get nearbyCategoryFuel => 'Fuel';

  @override
  String get nearbyCategoryParking => 'Parking';

  @override
  String get nearbyCategoryAttractions => 'Attractions';

  @override
  String get nearbyCategoryMuseums => 'Museums';

  @override
  String get nearbyCategoryParks => 'Parks';

  @override
  String get nearbyCategoryGyms => 'Gyms';

  @override
  String get nearbyCategoryMosques => 'Mosques';

  @override
  String get nearbyCategorySchools => 'Schools';

  @override
  String get nearbyCategoryUniversities => 'Universities';

  @override
  String get nearbyCategoryCinemas => 'Cinemas';

  @override
  String get nearbyCategoryPolice => 'Police';

  @override
  String get nearbyCategoryTrains => 'Trains';

  @override
  String get nearbyCategoryBuses => 'Buses';

  @override
  String get nearbyCategoryAirports => 'Airports';

  @override
  String get searchBiasHint => 'Results are biased to the map center';

  @override
  String get searchModeSearchText => 'Search text';

  @override
  String get searchModeSuggest => 'Suggest';

  @override
  String get searchModeAutocomplete => 'Autocomplete';

  @override
  String get searchModeSearchTextDescription =>
      'Businesses, POIs and addresses, paged';

  @override
  String get searchModeSuggestDescription =>
      'Places plus query refinements as you type';

  @override
  String get searchModeAutocompleteDescription =>
      'Fast address completion as you type';

  @override
  String get searchHint => 'e.g. pizza, Tahrir Square, 26th of July St';

  @override
  String get searchCountryHint => 'Country filter (ISO-3, e.g. EGY)';

  @override
  String get searchOnlyInCircle => 'Only inside a circle around the map center';

  @override
  String searchCompletionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completions',
      one: '1 completion',
    );
    return '$_temp0';
  }

  @override
  String searchSuggestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions',
      one: '1 suggestion',
    );
    return '$_temp0';
  }

  @override
  String get searchQueryRefinement => 'Query refinement · tap to search';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\".';
  }

  @override
  String searchTypeQuery(String mode) {
    return 'Type a query to search with $mode.';
  }

  @override
  String get pickerTitle => 'Choose a location';

  @override
  String get pickerEmptyHint => 'Tap the map or search for a place';

  @override
  String get pickerUse => 'Use';

  @override
  String get geocodeReverseTapHint => 'Tap the map to reverse geocode';

  @override
  String get geocodeModeText => 'Free text';

  @override
  String get geocodeModeStructured => 'Structured';

  @override
  String get geocodeModeReverse => 'Reverse';

  @override
  String get geocodeTextHint => 'e.g. 15 Talaat Harb, Cairo';

  @override
  String get geocodeCountryField => 'Country (ISO-3)';

  @override
  String geocodeSearchRadius(String distance) {
    return 'Search radius $distance';
  }

  @override
  String geocodeQueryPosition(String position) {
    return 'Query position: $position';
  }

  @override
  String geocodeMaxResults(int count) {
    return 'Max results: $count';
  }

  @override
  String get geocodePlaceTypes => 'Place types';

  @override
  String get geocodeAction => 'Geocode';

  @override
  String get commonChange => 'Change';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonUndo => 'Undo';

  @override
  String commonPointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get travelModeCar => 'Car';

  @override
  String get travelModeWalk => 'Walk';

  @override
  String get travelModeScooter => 'Scooter';

  @override
  String get travelModeTruck => 'Truck';

  @override
  String get routeFastest => 'Fastest';

  @override
  String get routeShortest => 'Shortest';

  @override
  String get truckTypeStraight => 'Straight truck';

  @override
  String get truckTypeTractor => 'Tractor';

  @override
  String get truckTypeLight => 'Light truck';

  @override
  String get avoidTolls => 'Tolls';

  @override
  String get avoidFerries => 'Ferries';

  @override
  String get avoidHighways => 'Highways';

  @override
  String get avoidTunnels => 'Tunnels';

  @override
  String get avoidUTurns => 'U-turns';

  @override
  String get avoidDirtRoads => 'Dirt roads';

  @override
  String get avoidCarTrains => 'Car trains';

  @override
  String get routeTapStart => 'Tap the map to set the start';

  @override
  String get routeStart => 'Start';

  @override
  String get routeStop => 'Stop';

  @override
  String get routeDestination => 'Destination';

  @override
  String get routeAddStop => 'Add stop';

  @override
  String get routeAvoid => 'Avoid';

  @override
  String get directionsTapDestination => 'Tap the map to set the destination';

  @override
  String get directionsChooseStart => 'Choose start';

  @override
  String get directionsChooseDestination => 'Choose destination';

  @override
  String get directionsSwap => 'Swap';

  @override
  String directionsRoutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routes',
      one: '1 route',
    );
    return '$_temp0';
  }

  @override
  String directionsTurnByTurn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Turn-by-turn · $count steps',
      one: 'Turn-by-turn · 1 step',
    );
    return '$_temp0';
  }

  @override
  String get directionsRouteOptions => 'Route options';

  @override
  String directionsSummaryAvoid(int count) {
    return 'avoid $count';
  }

  @override
  String get directionsSummaryDepartNow => 'depart now';

  @override
  String directionsSummaryDepartAt(String time) {
    return 'depart $time';
  }

  @override
  String directionsAlternatives(int count) {
    return 'Alternatives: $count';
  }

  @override
  String get directionsAlternativesUnavailable =>
      'Alternatives (not available with stops)';

  @override
  String get directionsUseTraffic => 'Use live & historic traffic';

  @override
  String get directionsDepartNow => 'Depart now';

  @override
  String directionsDepartAt(String time) {
    return 'Depart $time';
  }

  @override
  String get directionsNow => 'Now';

  @override
  String get directionsBest => 'Best';

  @override
  String directionsVia(String roads) {
    return 'via $roads';
  }

  @override
  String directionsLegsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count legs',
      one: '1 leg',
    );
    return '$_temp0';
  }

  @override
  String directionsTolls(String amount) {
    return 'Tolls $amount';
  }

  @override
  String get truckType => 'Type';

  @override
  String truckGrossWeight(String value) {
    return 'Gross weight $value t';
  }

  @override
  String truckHeight(String value) {
    return 'Height $value m';
  }

  @override
  String truckWidth(String value) {
    return 'Width $value m';
  }

  @override
  String truckLength(String value) {
    return 'Length $value m';
  }

  @override
  String truckAxles(int count) {
    return 'Axles $count';
  }

  @override
  String isolinesSaved(String name) {
    return 'Saved \"$name\" to geofences';
  }

  @override
  String get isolinesTapHint => 'Tap the map to set the starting point';

  @override
  String get isolinesChooseStart => 'Choose a starting point';

  @override
  String get isolinesStartingPoint => 'Starting point';

  @override
  String get isolinesThreshold => 'Threshold';

  @override
  String get isolinesTime => 'Time';

  @override
  String isolinesMaxThresholds(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Up to $max thresholds',
      one: 'Up to 1 threshold',
    );
    return '$_temp0';
  }

  @override
  String get isolinesUseTraffic => 'Use traffic';

  @override
  String get isolinesReachableAreas => 'Reachable areas';

  @override
  String isolinesWithin(String threshold) {
    return 'Within $threshold';
  }

  @override
  String isolinesPolygonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count polygons',
      one: '1 polygon',
    );
    return '$_temp0';
  }

  @override
  String get isolinesSaveAsGeofence => 'Save as geofence';

  @override
  String isolinesGeofenceName(String mode, String threshold) {
    return '$mode $threshold';
  }

  @override
  String get matrixTapOrigins => 'Tap the map to add origins';

  @override
  String get matrixTapDestinations => 'Tap the map to add destinations';

  @override
  String get matrixAddOrigins => 'Add origins';

  @override
  String get matrixAddDestinations => 'Add destinations';

  @override
  String matrixCalculate(int origins, int destinations) {
    return 'Calculate $origins × $destinations';
  }

  @override
  String matrixErrorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return '$_temp0';
  }

  @override
  String matrixOrigins(int count) {
    return 'Origins ($count)';
  }

  @override
  String matrixDestinations(int count) {
    return 'Destinations ($count)';
  }

  @override
  String get matrixAddOrigin => 'Add origin';

  @override
  String get matrixAddDestination => 'Add destination';

  @override
  String get optimizeTapStops =>
      'Tap the map to add stops (numbers show visit order)';

  @override
  String get optimizeReturnToStart => 'Return to start';

  @override
  String get optimizeEndAnywhere => 'End anywhere (optional)';

  @override
  String get optimizeEnd => 'End';

  @override
  String get optimizeRoundTrip => 'Round trip';

  @override
  String optimizeStops(int count) {
    return 'Stops ($count)';
  }

  @override
  String optimizeStopName(int number) {
    return 'Stop $number';
  }

  @override
  String get optimizeRun => 'Optimize order';

  @override
  String get optimizeResult => 'Optimized order';

  @override
  String optimizeArrive(String time) {
    return 'arrive $time';
  }

  @override
  String optimizeDepart(String time) {
    return 'depart $time';
  }

  @override
  String optimizeCouldNotVisit(String stops) {
    return 'Could not visit: $stops';
  }

  @override
  String get snapTapHint => 'Tap along a road to draw a rough GPS trace';

  @override
  String snapTracePointsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trace points',
      one: '1 trace point',
    );
    return '$_temp0';
  }

  @override
  String get snapGenerateNoisyTrace =>
      'Generate noisy trace between first & last';

  @override
  String snapRadius(String meters) {
    return 'Snap radius $meters m';
  }

  @override
  String get snapRun => 'Snap to roads';

  @override
  String snapConfidence(String percent) {
    return 'Confidence $percent%';
  }

  @override
  String get snapSnappedPoints => 'Snapped points';

  @override
  String snapMoved(String distance) {
    return 'moved $distance';
  }

  @override
  String geofencesDefaultName(String shape, int number) {
    return '$shape $number';
  }

  @override
  String get geofencesOpenTracker => 'Open tracker';

  @override
  String get geofencesTapTest => 'Tap to test whether a point is inside';

  @override
  String get geofencesTapCircle => 'Tap to place the circle center';

  @override
  String get geofencesTapPolygon => 'Tap to add polygon vertices';

  @override
  String get geofencesInfo =>
      'Amazon Location geofence collections and trackers need IAM or Cognito credentials (API keys only cover Maps, Places and Routes). This screen stores geofences on the device and evaluates ENTER/EXIT events the same way.';

  @override
  String get geofencesToolTest => 'Test';

  @override
  String get geofencesShapeCircle => 'Circle';

  @override
  String get geofencesShapePolygon => 'Polygon';

  @override
  String get geofencesOutsideAll => 'Point is outside every geofence.';

  @override
  String geofencesInside(String names) {
    return 'Inside: $names';
  }

  @override
  String geofencesVerticesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vertices',
      one: '1 vertex',
    );
    return '$_temp0';
  }

  @override
  String get geofencesName => 'Name';

  @override
  String get geofencesNameHint => 'e.g. Office, Warehouse';

  @override
  String get geofencesSave => 'Save geofence';

  @override
  String get geofencesFromIsoline => 'Create from a drive-time isoline';

  @override
  String geofencesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geofences',
      one: '1 geofence',
    );
    return '$_temp0';
  }

  @override
  String get geofencesDeleteAll => 'Delete all';

  @override
  String get geofencesEmpty => 'No geofences yet. Draw one on the map.';

  @override
  String get trackerEventEnter => 'ENTER';

  @override
  String get trackerEventExit => 'EXIT';

  @override
  String get trackerTapStart => 'Tap the map to choose the trip start';

  @override
  String get trackerTapEnd => 'Tap the map to choose the trip end';

  @override
  String get trackerReady => 'Press Start tracking, or tap to pick a new start';

  @override
  String get trackerFollow => 'Follow device';

  @override
  String get trackerSimulate => 'Simulate';

  @override
  String get trackerDeviceGps => 'Device GPS';

  @override
  String trackerPlaybackSpeed(int speed) {
    return 'Playback speed ×$speed';
  }

  @override
  String get trackerStop => 'Stop';

  @override
  String get trackerStart => 'Start tracking';

  @override
  String get trackerSnapTrail => 'Snap trail';

  @override
  String trackerFixesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fixes',
      one: '1 fix',
    );
    return '$_temp0';
  }

  @override
  String get trackerLocatingAddress => 'Locating address…';

  @override
  String trackerGeofences(int count) {
    return 'Geofences ($count)';
  }

  @override
  String trackerInsideCount(int count) {
    return 'inside $count';
  }

  @override
  String get trackerNoGeofences =>
      'No geofences saved. Create some on the Geofences screen to get ENTER/EXIT events here.';

  @override
  String trackerEvents(int count) {
    return 'Events ($count)';
  }

  @override
  String unitMeters(String value) {
    return '$value m';
  }

  @override
  String unitKilometers(String value) {
    return '$value km';
  }

  @override
  String unitFeet(String value) {
    return '$value ft';
  }

  @override
  String unitMiles(String value) {
    return '$value mi';
  }

  @override
  String unitKmh(String value) {
    return '$value km/h';
  }

  @override
  String unitMph(String value) {
    return '$value mph';
  }

  @override
  String unitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count s',
    );
    return '$_temp0';
  }

  @override
  String unitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
    );
    return '$_temp0';
  }

  @override
  String unitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h',
    );
    return '$_temp0';
  }

  @override
  String unitHoursMinutes(String hours, String minutes) {
    return '$hours $minutes';
  }

  @override
  String dateTimeShort(String date, String time) {
    return '$date, $time';
  }

  @override
  String commonRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String errorCredentialsRejected(int status, String detail) {
    return 'The AWS credentials were rejected ($status): $detail Check the identity pool role\'s permissions.';
  }

  @override
  String get errorTrackerConfigIncomplete =>
      'Enter an identity pool ID and a tracker name.';

  @override
  String get errorIdentityPoolIdInvalid =>
      'The identity pool ID should look like region:uuid.';

  @override
  String get errorTrackerNotConfigured => 'Connect to the tracker first.';

  @override
  String get errorBackgroundTrackingUnsupported =>
      'Background tracking isn\'t available on this platform.';

  @override
  String errorCognitoSignInFailed(String detail) {
    return 'Cognito sign-in failed: $detail';
  }

  @override
  String errorTrackingPlatform(String detail) {
    return 'Tracking error: $detail';
  }

  @override
  String get errorCloudTrackerSettingsNotSaved =>
      'Could not save the tracker settings.';

  @override
  String get cloudTrackingTitle => 'Cloud tracking';

  @override
  String get homeCloudTrackingDescription =>
      'Send device positions to an Amazon Location tracker with the Amazon Location Mobile SDKs, in the foreground or background.';

  @override
  String get cloudTrackingSetupTitle => 'Tracker';

  @override
  String get cloudTrackingIdentityPool => 'Cognito identity pool ID';

  @override
  String get cloudTrackingTrackerName => 'Tracker name';

  @override
  String get cloudTrackingSetupHelp =>
      'Trackers don\'t accept API keys. Positions are signed with credentials from a Cognito identity pool whose unauthenticated role allows geo:BatchUpdateDevicePosition, geo:GetDevicePosition and geo:GetDevicePositionHistory on the tracker.';

  @override
  String get cloudTrackingTimeFilter => 'Time filter';

  @override
  String cloudTrackingTimeFilterValue(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'At least $seconds seconds apart',
      one: 'At least 1 second apart',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingDistanceFilter => 'Distance filter';

  @override
  String cloudTrackingDistanceFilterValue(String distance) {
    return 'At least $distance apart';
  }

  @override
  String get cloudTrackingAccuracyFilter => 'Accuracy filter';

  @override
  String get cloudTrackingAccuracyFilterHint =>
      'Skip moves smaller than the position\'s accuracy';

  @override
  String get cloudTrackingConnect => 'Connect';

  @override
  String get cloudTrackingNotConnected => 'Not connected';

  @override
  String cloudTrackingConnected(String deviceId) {
    return 'Connected · device $deviceId';
  }

  @override
  String get cloudTrackingStatusTracking => 'Sending positions';

  @override
  String get cloudTrackingStatusBackground =>
      'Sending positions in the background';

  @override
  String get cloudTrackingBackground => 'Background tracking';

  @override
  String get cloudTrackingBackgroundActive => 'Active';

  @override
  String get cloudTrackingBackgroundBatterySaver => 'Battery saver';

  @override
  String get cloudTrackingBackgroundStart => 'Start in background';

  @override
  String get cloudTrackingBackgroundStop => 'Stop background';

  @override
  String get cloudTrackingBackgroundHelp =>
      'Android shows a notification while it runs; battery saver uploads about every 15 minutes. iOS needs the Always location permission.';

  @override
  String get cloudTrackingBackgroundWeb =>
      'Background tracking isn\'t available in the browser.';

  @override
  String get cloudTrackingReadBack => 'Read back from the tracker';

  @override
  String get cloudTrackingLatest => 'Latest position';

  @override
  String get cloudTrackingHistory => 'Last 24 hours';

  @override
  String cloudTrackingLatestValue(String time) {
    return 'Stored $time';
  }

  @override
  String get cloudTrackingNoPosition =>
      'The tracker has no position for this device yet.';

  @override
  String cloudTrackingHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions in the last 24 hours',
      one: '1 position in the last 24 hours',
      zero: 'No positions in the last 24 hours',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count received',
      one: '1 received',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploaded',
      one: '1 uploaded',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtered',
      one: '1 filtered',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors',
      one: '1 error',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingEventPosition => 'Position received';

  @override
  String cloudTrackingEventUploadStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uploading $count positions',
      one: 'Uploading 1 position',
    );
    return '$_temp0';
  }

  @override
  String cloudTrackingEventUploaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uploaded $count positions',
      one: 'Uploaded 1 position',
    );
    return '$_temp0';
  }

  @override
  String get cloudTrackingEventSkipped => 'Filtered out';

  @override
  String get cloudTrackingEventAvailable => 'Location available';

  @override
  String get cloudTrackingEventUnavailable => 'Location unavailable';

  @override
  String get cloudTrackingEventBackgroundStopped =>
      'Background tracking stopped';

  @override
  String cloudTrackingEventError(String message) {
    return 'Error: $message';
  }

  @override
  String get cloudTrackingLegendReceived => 'Received';

  @override
  String get cloudTrackingLegendUploaded => 'Uploaded';

  @override
  String get cloudTrackingLegendHistory => 'Stored history';
}
