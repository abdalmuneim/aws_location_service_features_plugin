import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name, shown in the app bar, task switcher and browser tab.
  ///
  /// In en, this message translates to:
  /// **'Location Studio'**
  String get appTitle;

  /// Tooltip of the app bar button that switches the app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguage;

  /// Language option that follows the device language (English when the device language is not supported).
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsAppLanguageDevice;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// Title of the collapsible panel showing the raw JSON returned by the API.
  ///
  /// In en, this message translates to:
  /// **'Raw response'**
  String get commonRawResponse;

  /// Title of the raw JSON panel for one API operation, e.g. 'CalculateRoutes response'. {api} is an AWS operation name and is never translated.
  ///
  /// In en, this message translates to:
  /// **'{api} response'**
  String commonApiResponse(String api);

  /// No description provided for @errorRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The request timed out.'**
  String get errorRequestTimedOut;

  /// {detail} is a technical error text from the system, in English.
  ///
  /// In en, this message translates to:
  /// **'Network error: {detail}'**
  String errorNetwork(String detail);

  /// No description provided for @errorHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'Request failed with HTTP {status}.'**
  String errorHttpStatus(int status);

  /// {status} is the HTTP status (401/403); {detail} is the English message returned by AWS.
  ///
  /// In en, this message translates to:
  /// **'The API key was rejected ({status}): {detail} Check the key, its region and its allowed actions in Settings.'**
  String errorApiKeyRejected(int status, String detail);

  /// {detail} is the English message returned by AWS.
  ///
  /// In en, this message translates to:
  /// **'Not found: {detail}'**
  String errorNotFound(String detail);

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device.'**
  String get errorLocationServicesOff;

  /// No description provided for @errorLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get errorLocationPermissionDenied;

  /// No description provided for @errorLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Enable it in system settings.'**
  String get errorLocationPermissionDeniedForever;

  /// No description provided for @errorSettingsNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings.'**
  String get errorSettingsNotSaved;

  /// No description provided for @errorAppLanguageNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Could not save the app language.'**
  String get errorAppLanguageNotSaved;

  /// No description provided for @errorGeofencesNotRead.
  ///
  /// In en, this message translates to:
  /// **'Saved geofences could not be read.'**
  String get errorGeofencesNotRead;

  /// No description provided for @errorGeofencesNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Could not save geofences.'**
  String get errorGeofencesNotSaved;

  /// No description provided for @errorGeocodeAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an address to geocode.'**
  String get errorGeocodeAddressRequired;

  /// No description provided for @errorSearchQueryRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter something to search for.'**
  String get errorSearchQueryRequired;

  /// No description provided for @errorGeofenceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the geofence a name.'**
  String get errorGeofenceNameRequired;

  /// No description provided for @errorGeofencePolygonTooFewPoints.
  ///
  /// In en, this message translates to:
  /// **'A polygon needs at least 3 points.'**
  String get errorGeofencePolygonTooFewPoints;

  /// No description provided for @errorGeofenceRadiusNotPositive.
  ///
  /// In en, this message translates to:
  /// **'The radius must be positive.'**
  String get errorGeofenceRadiusNotPositive;

  /// A threshold is a travel-time or distance limit that defines one reachable area (isoline).
  ///
  /// In en, this message translates to:
  /// **'Choose at least one threshold.'**
  String get errorIsolineThresholdRequired;

  /// No description provided for @errorIsolineTooManyThresholds.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{At most 1 threshold is allowed.} other{At most {max} thresholds are allowed.}}'**
  String errorIsolineTooManyThresholds(int max);

  /// No description provided for @errorRouteSameOriginAndDestination.
  ///
  /// In en, this message translates to:
  /// **'Origin and destination are the same place.'**
  String get errorRouteSameOriginAndDestination;

  /// No description provided for @errorRouteTooManyStops.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{A route can have at most 1 stop.} other{A route can have at most {max} stops.}}'**
  String errorRouteTooManyStops(int max);

  /// No description provided for @errorMatrixPointsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one origin and one destination.'**
  String get errorMatrixPointsRequired;

  /// No description provided for @errorMatrixTooManyPoints.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{Use at most 1 origin and 1 destination.} other{Use at most {max} origins and {max} destinations.}}'**
  String errorMatrixTooManyPoints(int max);

  /// No description provided for @errorOptimizeStopsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one stop besides the start.'**
  String get errorOptimizeStopsRequired;

  /// No description provided for @errorOptimizeTooManyStops.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{At most 1 stop can be optimized.} other{At most {max} stops can be optimized.}}'**
  String errorOptimizeTooManyStops(int max);

  /// A trace is a recorded GPS track to be matched to roads.
  ///
  /// In en, this message translates to:
  /// **'A trace needs at least 2 points.'**
  String get errorSnapTooFewPoints;

  /// No description provided for @errorSnapTooManyPoints.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{A trace can have at most 1 point.} other{A trace can have at most {max} points.}}'**
  String errorSnapTooManyPoints(int max);

  /// No description provided for @errorSnapNoRoute.
  ///
  /// In en, this message translates to:
  /// **'No route between those points.'**
  String get errorSnapNoRoute;

  /// No description provided for @errorTrackerPickTripEnds.
  ///
  /// In en, this message translates to:
  /// **'Tap the map twice to choose where the simulated trip starts and ends.'**
  String get errorTrackerPickTripEnds;

  /// No description provided for @errorTrackerNoRoute.
  ///
  /// In en, this message translates to:
  /// **'No route found for the simulated trip.'**
  String get errorTrackerNoRoute;

  /// No description provided for @commonApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get commonApiKey;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @mapExplorerTitle.
  ///
  /// In en, this message translates to:
  /// **'Map explorer'**
  String get mapExplorerTitle;

  /// No description provided for @staticMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Static maps'**
  String get staticMapTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get searchTitle;

  /// No description provided for @nearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby search'**
  String get nearbyTitle;

  /// No description provided for @geocodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Geocoding'**
  String get geocodeTitle;

  /// No description provided for @directionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsTitle;

  /// Areas reachable within a given travel time or distance from a point.
  ///
  /// In en, this message translates to:
  /// **'Isolines'**
  String get isolinesTitle;

  /// A table of travel times and distances between several origins and destinations.
  ///
  /// In en, this message translates to:
  /// **'Route matrix'**
  String get routeMatrixTitle;

  /// Finds the best order in which to visit a set of stops.
  ///
  /// In en, this message translates to:
  /// **'Optimize stops'**
  String get optimizeTitle;

  /// Matches a recorded GPS trace to the road network.
  ///
  /// In en, this message translates to:
  /// **'Snap to roads'**
  String get snapTitle;

  /// Virtual boundaries on the map; the app reports when a device enters or exits them.
  ///
  /// In en, this message translates to:
  /// **'Geofences'**
  String get geofencesTitle;

  /// Screen that follows the device's live or simulated position.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get trackerTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maps, Places and Routes through a single API key.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeSectionMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get homeSectionMaps;

  /// No description provided for @homeSectionPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get homeSectionPlaces;

  /// No description provided for @homeSectionRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get homeSectionRoutes;

  /// No description provided for @homeSectionGeofencing.
  ///
  /// In en, this message translates to:
  /// **'Geofencing & tracking'**
  String get homeSectionGeofencing;

  /// No description provided for @homeMapExplorerDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard, Monochrome, Hybrid & Satellite styles, dark mode, political views, terrain, contours, traffic and travel-mode layers.'**
  String get homeMapExplorerDescription;

  /// No description provided for @homeStaticMapDescription.
  ///
  /// In en, this message translates to:
  /// **'Render map images with markers, lines, labels and scale bars.'**
  String get homeStaticMapDescription;

  /// No description provided for @homeSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearchTitle;

  /// No description provided for @homeSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Find businesses, POIs and addresses with type-ahead and details.'**
  String get homeSearchDescription;

  /// No description provided for @homeNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get homeNearbyTitle;

  /// No description provided for @homeNearbyDescription.
  ///
  /// In en, this message translates to:
  /// **'Points of interest around a location, filtered by category.'**
  String get homeNearbyDescription;

  /// Converting an address into map coordinates.
  ///
  /// In en, this message translates to:
  /// **'Geocode'**
  String get homeGeocodeTitle;

  /// No description provided for @homeGeocodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn free-text or structured addresses into coordinates.'**
  String get homeGeocodeDescription;

  /// Converting map coordinates into an address.
  ///
  /// In en, this message translates to:
  /// **'Reverse geocode'**
  String get homeReverseGeocodeTitle;

  /// No description provided for @homeReverseGeocodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn coordinates into addresses, streets and localities.'**
  String get homeReverseGeocodeDescription;

  /// No description provided for @homeDirectionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Car, walking, scooter & truck routes with stops, alternatives, avoidances, traffic and departure times.'**
  String get homeDirectionsDescription;

  /// No description provided for @homeIsolinesDescription.
  ///
  /// In en, this message translates to:
  /// **'Areas reachable within a travel time or distance.'**
  String get homeIsolinesDescription;

  /// No description provided for @homeRouteMatrixDescription.
  ///
  /// In en, this message translates to:
  /// **'Travel time & distance between many origins and destinations.'**
  String get homeRouteMatrixDescription;

  /// No description provided for @homeOptimizeDescription.
  ///
  /// In en, this message translates to:
  /// **'The best order to visit a set of stops.'**
  String get homeOptimizeDescription;

  /// No description provided for @homeSnapDescription.
  ///
  /// In en, this message translates to:
  /// **'Match noisy GPS traces to the road network.'**
  String get homeSnapDescription;

  /// Shown where other cards list AWS API names: geofences are checked on the phone, not by an AWS API.
  ///
  /// In en, this message translates to:
  /// **'On-device evaluation'**
  String get homeGeofencesApis;

  /// No description provided for @homeGeofencesDescription.
  ///
  /// In en, this message translates to:
  /// **'Draw circle & polygon geofences or build them from isolines.'**
  String get homeGeofencesDescription;

  /// No description provided for @homeTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Live or simulated tracking with ENTER/EXIT geofence events.'**
  String get homeTrackerDescription;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get commonDefault;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// Light color scheme (app theme or map colors).
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get commonLight;

  /// Dark color scheme (app theme or map colors).
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get commonDark;

  /// Which country's official position is used to draw disputed borders and names on maps.
  ///
  /// In en, this message translates to:
  /// **'Political view'**
  String get commonPoliticalView;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperial;

  /// No description provided for @mapStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Map style'**
  String get mapStyleTitle;

  /// No description provided for @mapStyleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get mapStyleStandard;

  /// No description provided for @mapStyleMonochrome.
  ///
  /// In en, this message translates to:
  /// **'Monochrome'**
  String get mapStyleMonochrome;

  /// Map style: satellite imagery with roads and labels on top.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get mapStyleHybrid;

  /// No description provided for @mapStyleSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get mapStyleSatellite;

  /// Map layer that shades the terrain to show relief.
  ///
  /// In en, this message translates to:
  /// **'Hillshade'**
  String get mapTerrainHillshade;

  /// No description provided for @mapTerrain3d.
  ///
  /// In en, this message translates to:
  /// **'3D terrain'**
  String get mapTerrain3d;

  /// Density of elevation contour lines on the map.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get mapContoursLow;

  /// Density of elevation contour lines on the map.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mapContoursMedium;

  /// Density of elevation contour lines on the map.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get mapContoursHigh;

  /// Map overlay showing public transport lines.
  ///
  /// In en, this message translates to:
  /// **'Transit'**
  String get mapTravelModesTransit;

  /// Map overlay showing truck restrictions.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get mapTravelModesTruck;

  /// No description provided for @countryArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryArgentina;

  /// No description provided for @countryCyprus.
  ///
  /// In en, this message translates to:
  /// **'Cyprus'**
  String get countryCyprus;

  /// No description provided for @countryEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEgypt;

  /// The country in the Caucasus.
  ///
  /// In en, this message translates to:
  /// **'Georgia'**
  String get countryGeorgia;

  /// No description provided for @countryGreece.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get countryGreece;

  /// No description provided for @countryIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIndia;

  /// No description provided for @countryKenya.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get countryKenya;

  /// No description provided for @countryMorocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get countryMorocco;

  /// No description provided for @countryPalestine.
  ///
  /// In en, this message translates to:
  /// **'Palestine'**
  String get countryPalestine;

  /// No description provided for @countryRussia.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get countryRussia;

  /// No description provided for @countrySudan.
  ///
  /// In en, this message translates to:
  /// **'Sudan'**
  String get countrySudan;

  /// No description provided for @countrySerbia.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get countrySerbia;

  /// No description provided for @countrySuriname.
  ///
  /// In en, this message translates to:
  /// **'Suriname'**
  String get countrySuriname;

  /// No description provided for @countrySyria.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get countrySyria;

  /// No description provided for @countryTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get countryTurkey;

  /// No description provided for @countryTanzania.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get countryTanzania;

  /// No description provided for @countryUruguay.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get countryUruguay;

  /// No description provided for @countryVietnam.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get countryVietnam;

  /// No description provided for @settingsSectionConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsSectionConnection;

  /// No description provided for @settingsSaveKey.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get settingsSaveKey;

  /// AWS region, e.g. eu-north-1.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get settingsRegion;

  /// No description provided for @settingsRegionHelper.
  ///
  /// In en, this message translates to:
  /// **'Must be the region the API key was created in'**
  String get settingsRegionHelper;

  /// No description provided for @settingsTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsTestConnection;

  /// {answer} is an address returned by the API (or 'OK').
  ///
  /// In en, this message translates to:
  /// **'Connected. Places API answered: {answer}'**
  String settingsTestSuccess(String answer);

  /// No description provided for @settingsSectionResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get settingsSectionResults;

  /// Language requested from AWS for place names and route instructions; separate from the app language.
  ///
  /// In en, this message translates to:
  /// **'Language for places & directions'**
  String get settingsResultsLanguage;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Theme option: follow the device's light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsResetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settingsResetDefaults;

  /// No description provided for @settingsAboutApiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'About API keys'**
  String get settingsAboutApiKeysTitle;

  /// No description provided for @settingsAboutApiKeysBody.
  ///
  /// In en, this message translates to:
  /// **'Amazon Location API keys authorize the Maps, Places and Routes APIs. Restrict the key to the actions you use and to your app\'s referrers/bundle IDs in the AWS console. Geofence collections and trackers require IAM or Cognito credentials.'**
  String get settingsAboutApiKeysBody;

  /// No description provided for @commonMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get commonMyLocation;

  /// No description provided for @commonDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get commonDetails;

  /// No description provided for @commonResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get commonResults;

  /// Button that opens a map to choose a location.
  ///
  /// In en, this message translates to:
  /// **'Pick'**
  String get commonPick;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// Map camera readout: z = zoom level, then the center coordinates.
  ///
  /// In en, this message translates to:
  /// **'z {zoom} · {center}'**
  String mapExplorerCamera(String zoom, String center);

  /// No description provided for @mapExplorerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, businesses, addresses'**
  String get mapExplorerSearchHint;

  /// No description provided for @mapExplorerLookingUpAddress.
  ///
  /// In en, this message translates to:
  /// **'Looking up address…'**
  String get mapExplorerLookingUpAddress;

  /// No description provided for @mapExplorerNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address found'**
  String get mapExplorerNoAddress;

  /// No description provided for @mapExplorerTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to see the address (reverse geocoding)'**
  String get mapExplorerTapHint;

  /// No description provided for @mapStyleColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get mapStyleColorScheme;

  /// No description provided for @mapStylePoliticalViewHelper.
  ///
  /// In en, this message translates to:
  /// **'Borders and labels for disputed areas'**
  String get mapStylePoliticalViewHelper;

  /// No description provided for @mapStyleNotForSatellite.
  ///
  /// In en, this message translates to:
  /// **'Not available for the Satellite style'**
  String get mapStyleNotForSatellite;

  /// No description provided for @mapStyleTerrain.
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get mapStyleTerrain;

  /// No description provided for @mapStyleTerrain3dHint.
  ///
  /// In en, this message translates to:
  /// **'3D terrain renders on the web; tilt the map with right-drag or two fingers.'**
  String get mapStyleTerrain3dHint;

  /// No description provided for @mapStyleContours.
  ///
  /// In en, this message translates to:
  /// **'Contour lines'**
  String get mapStyleContours;

  /// Short 'not available' marker next to a section title.
  ///
  /// In en, this message translates to:
  /// **'n/a'**
  String get mapStyleNotAvailable;

  /// No description provided for @mapStyleTraffic.
  ///
  /// In en, this message translates to:
  /// **'Real-time traffic'**
  String get mapStyleTraffic;

  /// No description provided for @mapStyleTravelModes.
  ///
  /// In en, this message translates to:
  /// **'Travel-mode overlay'**
  String get mapStyleTravelModes;

  /// Button that requests the static map image.
  ///
  /// In en, this message translates to:
  /// **'Render'**
  String get staticMapRender;

  /// No description provided for @staticMapImageSize.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String staticMapImageSize(String size);

  /// No description provided for @staticMapRequestUrl.
  ///
  /// In en, this message translates to:
  /// **'Request URL'**
  String get staticMapRequestUrl;

  /// No description provided for @staticMapEmpty.
  ///
  /// In en, this message translates to:
  /// **'Press Render to generate an image.'**
  String get staticMapEmpty;

  /// How the area shown in the image is chosen.
  ///
  /// In en, this message translates to:
  /// **'Framing'**
  String get staticMapFraming;

  /// No description provided for @staticMapFramingCenterZoom.
  ///
  /// In en, this message translates to:
  /// **'Center & zoom'**
  String get staticMapFramingCenterZoom;

  /// No description provided for @staticMapFramingCenterRadius.
  ///
  /// In en, this message translates to:
  /// **'Center & radius'**
  String get staticMapFramingCenterRadius;

  /// Frame the image so that all markers are visible.
  ///
  /// In en, this message translates to:
  /// **'Fit markers'**
  String get staticMapFramingFitMarkers;

  /// No description provided for @staticMapCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get staticMapCenter;

  /// No description provided for @staticMapPickCenter.
  ///
  /// In en, this message translates to:
  /// **'Map center'**
  String get staticMapPickCenter;

  /// No description provided for @staticMapZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom {zoom}'**
  String staticMapZoom(String zoom);

  /// No description provided for @staticMapRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius {meters} m'**
  String staticMapRadius(String meters);

  /// Empty space around the markers, in pixels.
  ///
  /// In en, this message translates to:
  /// **'Padding {pixels} px'**
  String staticMapPadding(String pixels);

  /// No description provided for @staticMapImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get staticMapImage;

  /// No description provided for @staticMapSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get staticMapSize;

  /// No description provided for @staticMapHighDpi.
  ///
  /// In en, this message translates to:
  /// **'High DPI (@2x)'**
  String get staticMapHighDpi;

  /// No description provided for @staticMapStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get staticMapStyle;

  /// No description provided for @staticMapLabelsSmall.
  ///
  /// In en, this message translates to:
  /// **'Small labels'**
  String get staticMapLabelsSmall;

  /// No description provided for @staticMapLabelsLarge.
  ///
  /// In en, this message translates to:
  /// **'Large labels'**
  String get staticMapLabelsLarge;

  /// No description provided for @staticMapLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Label language'**
  String get staticMapLabelLanguage;

  /// Show each place's name in its local language.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get staticMapLabelLanguageLocal;

  /// No description provided for @staticMapPointsOfInterest.
  ///
  /// In en, this message translates to:
  /// **'Points of interest'**
  String get staticMapPointsOfInterest;

  /// No description provided for @staticMapCropLabels.
  ///
  /// In en, this message translates to:
  /// **'Crop labels at the edges'**
  String get staticMapCropLabels;

  /// No description provided for @staticMapScaleBar.
  ///
  /// In en, this message translates to:
  /// **'Scale bar'**
  String get staticMapScaleBar;

  /// No description provided for @staticMapScaleKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get staticMapScaleKilometers;

  /// No description provided for @staticMapScaleMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get staticMapScaleMiles;

  /// No description provided for @staticMapScaleKilometersMiles.
  ///
  /// In en, this message translates to:
  /// **'Km + Miles'**
  String get staticMapScaleKilometersMiles;

  /// No description provided for @staticMapScaleMilesKilometers.
  ///
  /// In en, this message translates to:
  /// **'Miles + Km'**
  String get staticMapScaleMilesKilometers;

  /// No description provided for @staticMapMarkers.
  ///
  /// In en, this message translates to:
  /// **'GeoJSON overlay markers'**
  String get staticMapMarkers;

  /// No description provided for @staticMapAddMarker.
  ///
  /// In en, this message translates to:
  /// **'Add marker'**
  String get staticMapAddMarker;

  /// geojson-overlay is an API parameter name and is not translated.
  ///
  /// In en, this message translates to:
  /// **'Markers are drawn with the geojson-overlay parameter.'**
  String get staticMapMarkersHint;

  /// No description provided for @staticMapMarkerFallback.
  ///
  /// In en, this message translates to:
  /// **'Marker {number}'**
  String staticMapMarkerFallback(int number);

  /// No description provided for @staticMapConnectMarkers.
  ///
  /// In en, this message translates to:
  /// **'Connect markers with a line'**
  String get staticMapConnectMarkers;

  /// No description provided for @commonDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get commonDistance;

  /// No description provided for @commonLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get commonLoadMore;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius {distance}'**
  String commonRadius(String distance);

  /// No description provided for @commonResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String commonResultsCount(int count);

  /// Button: search for places around this place.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get placeActionNearby;

  /// Button: show the area reachable from this place within a travel time.
  ///
  /// In en, this message translates to:
  /// **'Reachable area'**
  String get placeActionReachableArea;

  /// No description provided for @placeCopyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Copy coordinates'**
  String get placeCopyCoordinates;

  /// No description provided for @placeCoordinatesCopied.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied'**
  String get placeCoordinatesCopied;

  /// No description provided for @placeAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get placeAddress;

  /// No description provided for @placeLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get placeLocation;

  /// No description provided for @placeCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get placeCoordinates;

  /// No description provided for @placeTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get placeTimeZone;

  /// Entrances or points where a place can be reached from the road.
  ///
  /// In en, this message translates to:
  /// **'Access points'**
  String get placeAccessPoints;

  /// No description provided for @placeContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get placeContact;

  /// No description provided for @placePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get placePhone;

  /// No description provided for @placeWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get placeWebsite;

  /// No description provided for @placeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get placeEmail;

  /// No description provided for @placeFax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get placeFax;

  /// No description provided for @placeOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get placeOpeningHours;

  /// No description provided for @placeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get placeOpenNow;

  /// No description provided for @placeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get placeClosed;

  /// No description provided for @placeBusinessChain.
  ///
  /// In en, this message translates to:
  /// **'Business chain'**
  String get placeBusinessChain;

  /// No description provided for @placeNoCoordinates.
  ///
  /// In en, this message translates to:
  /// **'This place has no coordinates.'**
  String get placeNoCoordinates;

  /// No description provided for @placeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places or addresses'**
  String get placeSearchHint;

  /// No description provided for @placeSearchMoveMap.
  ///
  /// In en, this message translates to:
  /// **'Move the map to search nearby.'**
  String get placeSearchMoveMap;

  /// No description provided for @placeSearchNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get placeSearchNoMatches;

  /// Subtitle of a suggested search phrase: tapping it runs that search.
  ///
  /// In en, this message translates to:
  /// **'Search query'**
  String get placeSearchQueryGeneric;

  /// Subtitle of a suggestion that searches a whole category (e.g. 'coffee shops').
  ///
  /// In en, this message translates to:
  /// **'Search category'**
  String get placeSearchQueryCategory;

  /// No description provided for @placeSearchQueryBusinessChain.
  ///
  /// In en, this message translates to:
  /// **'Search business chain'**
  String get placeSearchQueryBusinessChain;

  /// {type} is an English API value (fallback for unknown suggestion types).
  ///
  /// In en, this message translates to:
  /// **'Search {type}'**
  String placeSearchQueryOther(String type);

  /// No description provided for @placeTypePointOfInterest.
  ///
  /// In en, this message translates to:
  /// **'Point of interest'**
  String get placeTypePointOfInterest;

  /// An exact street address (a specific building).
  ///
  /// In en, this message translates to:
  /// **'Point address'**
  String get placeTypePointAddress;

  /// An estimated address position along a street.
  ///
  /// In en, this message translates to:
  /// **'Interpolated address'**
  String get placeTypeInterpolatedAddress;

  /// A unit within a building, e.g. an apartment or suite.
  ///
  /// In en, this message translates to:
  /// **'Secondary address'**
  String get placeTypeSecondaryAddress;

  /// No description provided for @placeTypeStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get placeTypeStreet;

  /// No description provided for @placeTypeIntersection.
  ///
  /// In en, this message translates to:
  /// **'Intersection'**
  String get placeTypeIntersection;

  /// No description provided for @placeTypeBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get placeTypeBlock;

  /// No description provided for @placeTypeSubBlock.
  ///
  /// In en, this message translates to:
  /// **'Sub block'**
  String get placeTypeSubBlock;

  /// No description provided for @placeTypeDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get placeTypeDistrict;

  /// No description provided for @placeTypeSubDistrict.
  ///
  /// In en, this message translates to:
  /// **'Sub district'**
  String get placeTypeSubDistrict;

  /// A city or town.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get placeTypeLocality;

  /// No description provided for @placeTypeSubRegion.
  ///
  /// In en, this message translates to:
  /// **'Sub region'**
  String get placeTypeSubRegion;

  /// A state, province or governorate.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get placeTypeRegion;

  /// No description provided for @placeTypePostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get placeTypePostalCode;

  /// No description provided for @placeTypeCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get placeTypeCountry;

  /// No description provided for @placeTypePoint.
  ///
  /// In en, this message translates to:
  /// **'Point'**
  String get placeTypePoint;

  /// No description provided for @addressBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get addressBuilding;

  /// House or building number in a street address.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get addressNumber;

  /// No description provided for @addressStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get addressStreet;

  /// No description provided for @addressSubDistrict.
  ///
  /// In en, this message translates to:
  /// **'Sub-district'**
  String get addressSubDistrict;

  /// No description provided for @addressDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get addressDistrict;

  /// City or town in a postal address.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get addressLocality;

  /// No description provided for @addressSubRegion.
  ///
  /// In en, this message translates to:
  /// **'Sub-region'**
  String get addressSubRegion;

  /// State, province or governorate in a postal address (not an AWS region).
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get addressRegion;

  /// No description provided for @addressPostalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get addressPostalCode;

  /// No description provided for @addressCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get addressCountry;

  /// No description provided for @nearbyTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to search around that point'**
  String get nearbyTapHint;

  /// No description provided for @nearbyCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get nearbyCategories;

  /// No description provided for @nearbyPlacesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String nearbyPlacesCount(int count);

  /// No description provided for @nearbyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Try a larger radius.'**
  String get nearbyEmpty;

  /// No description provided for @nearbyCategoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get nearbyCategoryRestaurants;

  /// Filter chip for coffee shops.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get nearbyCategoryCoffee;

  /// No description provided for @nearbyCategoryFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get nearbyCategoryFastFood;

  /// No description provided for @nearbyCategoryHotels.
  ///
  /// In en, this message translates to:
  /// **'Hotels'**
  String get nearbyCategoryHotels;

  /// No description provided for @nearbyCategoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get nearbyCategoryGroceries;

  /// No description provided for @nearbyCategoryMalls.
  ///
  /// In en, this message translates to:
  /// **'Malls'**
  String get nearbyCategoryMalls;

  /// No description provided for @nearbyCategoryPharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get nearbyCategoryPharmacies;

  /// No description provided for @nearbyCategoryHospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get nearbyCategoryHospitals;

  /// No description provided for @nearbyCategoryAtms.
  ///
  /// In en, this message translates to:
  /// **'ATMs'**
  String get nearbyCategoryAtms;

  /// No description provided for @nearbyCategoryBanks.
  ///
  /// In en, this message translates to:
  /// **'Banks'**
  String get nearbyCategoryBanks;

  /// Filter chip for petrol/gas stations.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get nearbyCategoryFuel;

  /// No description provided for @nearbyCategoryParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get nearbyCategoryParking;

  /// No description provided for @nearbyCategoryAttractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get nearbyCategoryAttractions;

  /// No description provided for @nearbyCategoryMuseums.
  ///
  /// In en, this message translates to:
  /// **'Museums'**
  String get nearbyCategoryMuseums;

  /// No description provided for @nearbyCategoryParks.
  ///
  /// In en, this message translates to:
  /// **'Parks'**
  String get nearbyCategoryParks;

  /// No description provided for @nearbyCategoryGyms.
  ///
  /// In en, this message translates to:
  /// **'Gyms'**
  String get nearbyCategoryGyms;

  /// No description provided for @nearbyCategoryMosques.
  ///
  /// In en, this message translates to:
  /// **'Mosques'**
  String get nearbyCategoryMosques;

  /// No description provided for @nearbyCategorySchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get nearbyCategorySchools;

  /// No description provided for @nearbyCategoryUniversities.
  ///
  /// In en, this message translates to:
  /// **'Universities'**
  String get nearbyCategoryUniversities;

  /// No description provided for @nearbyCategoryCinemas.
  ///
  /// In en, this message translates to:
  /// **'Cinemas'**
  String get nearbyCategoryCinemas;

  /// No description provided for @nearbyCategoryPolice.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get nearbyCategoryPolice;

  /// Filter chip for train stations.
  ///
  /// In en, this message translates to:
  /// **'Trains'**
  String get nearbyCategoryTrains;

  /// Filter chip for bus stations.
  ///
  /// In en, this message translates to:
  /// **'Buses'**
  String get nearbyCategoryBuses;

  /// No description provided for @nearbyCategoryAirports.
  ///
  /// In en, this message translates to:
  /// **'Airports'**
  String get nearbyCategoryAirports;

  /// No description provided for @searchBiasHint.
  ///
  /// In en, this message translates to:
  /// **'Results are biased to the map center'**
  String get searchBiasHint;

  /// Search mode: full text search with paged results.
  ///
  /// In en, this message translates to:
  /// **'Search text'**
  String get searchModeSearchText;

  /// No description provided for @searchModeSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get searchModeSuggest;

  /// No description provided for @searchModeAutocomplete.
  ///
  /// In en, this message translates to:
  /// **'Autocomplete'**
  String get searchModeAutocomplete;

  /// No description provided for @searchModeSearchTextDescription.
  ///
  /// In en, this message translates to:
  /// **'Businesses, POIs and addresses, paged'**
  String get searchModeSearchTextDescription;

  /// No description provided for @searchModeSuggestDescription.
  ///
  /// In en, this message translates to:
  /// **'Places plus query refinements as you type'**
  String get searchModeSuggestDescription;

  /// No description provided for @searchModeAutocompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast address completion as you type'**
  String get searchModeAutocompleteDescription;

  /// Example search terms; use well-known local examples.
  ///
  /// In en, this message translates to:
  /// **'e.g. pizza, Tahrir Square, 26th of July St'**
  String get searchHint;

  /// No description provided for @searchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Country filter (ISO-3, e.g. EGY)'**
  String get searchCountryHint;

  /// No description provided for @searchOnlyInCircle.
  ///
  /// In en, this message translates to:
  /// **'Only inside a circle around the map center'**
  String get searchOnlyInCircle;

  /// No description provided for @searchCompletionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completion} other{{count} completions}}'**
  String searchCompletionsCount(int count);

  /// No description provided for @searchSuggestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 suggestion} other{{count} suggestions}}'**
  String searchSuggestionsCount(int count);

  /// No description provided for @searchQueryRefinement.
  ///
  /// In en, this message translates to:
  /// **'Query refinement · tap to search'**
  String get searchQueryRefinement;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\".'**
  String searchNoResults(String query);

  /// {mode} is the selected search mode name, e.g. 'Autocomplete'.
  ///
  /// In en, this message translates to:
  /// **'Type a query to search with {mode}.'**
  String searchTypeQuery(String mode);

  /// No description provided for @pickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a location'**
  String get pickerTitle;

  /// No description provided for @pickerEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or search for a place'**
  String get pickerEmptyHint;

  /// Confirms the picked location.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get pickerUse;

  /// No description provided for @geocodeReverseTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to reverse geocode'**
  String get geocodeReverseTapHint;

  /// No description provided for @geocodeModeText.
  ///
  /// In en, this message translates to:
  /// **'Free text'**
  String get geocodeModeText;

  /// Geocoding mode: enter the address field by field.
  ///
  /// In en, this message translates to:
  /// **'Structured'**
  String get geocodeModeStructured;

  /// Geocoding mode: coordinates to address.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get geocodeModeReverse;

  /// No description provided for @geocodeTextHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15 Talaat Harb, Cairo'**
  String get geocodeTextHint;

  /// No description provided for @geocodeCountryField.
  ///
  /// In en, this message translates to:
  /// **'Country (ISO-3)'**
  String get geocodeCountryField;

  /// No description provided for @geocodeSearchRadius.
  ///
  /// In en, this message translates to:
  /// **'Search radius {distance}'**
  String geocodeSearchRadius(String distance);

  /// No description provided for @geocodeQueryPosition.
  ///
  /// In en, this message translates to:
  /// **'Query position: {position}'**
  String geocodeQueryPosition(String position);

  /// No description provided for @geocodeMaxResults.
  ///
  /// In en, this message translates to:
  /// **'Max results: {count}'**
  String geocodeMaxResults(int count);

  /// No description provided for @geocodePlaceTypes.
  ///
  /// In en, this message translates to:
  /// **'Place types'**
  String get geocodePlaceTypes;

  /// Button: convert the entered address into coordinates.
  ///
  /// In en, this message translates to:
  /// **'Geocode'**
  String get geocodeAction;

  /// No description provided for @commonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonPointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 point} other{{count} points}}'**
  String commonPointsCount(int count);

  /// No description provided for @travelModeCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get travelModeCar;

  /// No description provided for @travelModeWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get travelModeWalk;

  /// No description provided for @travelModeScooter.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get travelModeScooter;

  /// No description provided for @travelModeTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get travelModeTruck;

  /// No description provided for @routeFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get routeFastest;

  /// No description provided for @routeShortest.
  ///
  /// In en, this message translates to:
  /// **'Shortest'**
  String get routeShortest;

  /// A rigid truck (cab and cargo on one chassis).
  ///
  /// In en, this message translates to:
  /// **'Straight truck'**
  String get truckTypeStraight;

  /// A tractor unit that pulls a semi-trailer.
  ///
  /// In en, this message translates to:
  /// **'Tractor'**
  String get truckTypeTractor;

  /// No description provided for @truckTypeLight.
  ///
  /// In en, this message translates to:
  /// **'Light truck'**
  String get truckTypeLight;

  /// No description provided for @avoidTolls.
  ///
  /// In en, this message translates to:
  /// **'Tolls'**
  String get avoidTolls;

  /// No description provided for @avoidFerries.
  ///
  /// In en, this message translates to:
  /// **'Ferries'**
  String get avoidFerries;

  /// No description provided for @avoidHighways.
  ///
  /// In en, this message translates to:
  /// **'Highways'**
  String get avoidHighways;

  /// No description provided for @avoidTunnels.
  ///
  /// In en, this message translates to:
  /// **'Tunnels'**
  String get avoidTunnels;

  /// No description provided for @avoidUTurns.
  ///
  /// In en, this message translates to:
  /// **'U-turns'**
  String get avoidUTurns;

  /// No description provided for @avoidDirtRoads.
  ///
  /// In en, this message translates to:
  /// **'Dirt roads'**
  String get avoidDirtRoads;

  /// Trains that carry cars (car shuttle trains).
  ///
  /// In en, this message translates to:
  /// **'Car trains'**
  String get avoidCarTrains;

  /// No description provided for @routeTapStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the start'**
  String get routeTapStart;

  /// Starting point of a route.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get routeStart;

  /// An intermediate stop on a route (noun).
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get routeStop;

  /// No description provided for @routeDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get routeDestination;

  /// No description provided for @routeAddStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get routeAddStop;

  /// No description provided for @routeAvoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid'**
  String get routeAvoid;

  /// No description provided for @directionsTapDestination.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the destination'**
  String get directionsTapDestination;

  /// No description provided for @directionsChooseStart.
  ///
  /// In en, this message translates to:
  /// **'Choose start'**
  String get directionsChooseStart;

  /// No description provided for @directionsChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get directionsChooseDestination;

  /// Tooltip: swap the start and the destination.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get directionsSwap;

  /// No description provided for @directionsRoutesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 route} other{{count} routes}}'**
  String directionsRoutesCount(int count);

  /// No description provided for @directionsTurnByTurn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Turn-by-turn · 1 step} other{Turn-by-turn · {count} steps}}'**
  String directionsTurnByTurn(int count);

  /// No description provided for @directionsRouteOptions.
  ///
  /// In en, this message translates to:
  /// **'Route options'**
  String get directionsRouteOptions;

  /// Part of a compact options summary: number of road features avoided.
  ///
  /// In en, this message translates to:
  /// **'avoid {count}'**
  String directionsSummaryAvoid(int count);

  /// Part of a compact options summary (lowercase in English).
  ///
  /// In en, this message translates to:
  /// **'depart now'**
  String get directionsSummaryDepartNow;

  /// No description provided for @directionsSummaryDepartAt.
  ///
  /// In en, this message translates to:
  /// **'depart {time}'**
  String directionsSummaryDepartAt(String time);

  /// Maximum number of alternative routes to request.
  ///
  /// In en, this message translates to:
  /// **'Alternatives: {count}'**
  String directionsAlternatives(int count);

  /// No description provided for @directionsAlternativesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Alternatives (not available with stops)'**
  String get directionsAlternativesUnavailable;

  /// No description provided for @directionsUseTraffic.
  ///
  /// In en, this message translates to:
  /// **'Use live & historic traffic'**
  String get directionsUseTraffic;

  /// No description provided for @directionsDepartNow.
  ///
  /// In en, this message translates to:
  /// **'Depart now'**
  String get directionsDepartNow;

  /// No description provided for @directionsDepartAt.
  ///
  /// In en, this message translates to:
  /// **'Depart {time}'**
  String directionsDepartAt(String time);

  /// No description provided for @directionsNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get directionsNow;

  /// Badge on the recommended route.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get directionsBest;

  /// No description provided for @directionsVia.
  ///
  /// In en, this message translates to:
  /// **'via {roads}'**
  String directionsVia(String roads);

  /// A leg is the part of a route between two consecutive stops.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 leg} other{{count} legs}}'**
  String directionsLegsCount(int count);

  /// No description provided for @directionsTolls.
  ///
  /// In en, this message translates to:
  /// **'Tolls {amount}'**
  String directionsTolls(String amount);

  /// No description provided for @truckType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get truckType;

  /// No description provided for @truckGrossWeight.
  ///
  /// In en, this message translates to:
  /// **'Gross weight {value} t'**
  String truckGrossWeight(String value);

  /// No description provided for @truckHeight.
  ///
  /// In en, this message translates to:
  /// **'Height {value} m'**
  String truckHeight(String value);

  /// No description provided for @truckWidth.
  ///
  /// In en, this message translates to:
  /// **'Width {value} m'**
  String truckWidth(String value);

  /// No description provided for @truckLength.
  ///
  /// In en, this message translates to:
  /// **'Length {value} m'**
  String truckLength(String value);

  /// No description provided for @truckAxles.
  ///
  /// In en, this message translates to:
  /// **'Axles {count}'**
  String truckAxles(int count);

  /// No description provided for @isolinesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\" to geofences'**
  String isolinesSaved(String name);

  /// No description provided for @isolinesTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set the starting point'**
  String get isolinesTapHint;

  /// No description provided for @isolinesChooseStart.
  ///
  /// In en, this message translates to:
  /// **'Choose a starting point'**
  String get isolinesChooseStart;

  /// No description provided for @isolinesStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'Starting point'**
  String get isolinesStartingPoint;

  /// Section title: limit by travel time or by distance.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get isolinesThreshold;

  /// No description provided for @isolinesTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get isolinesTime;

  /// No description provided for @isolinesMaxThresholds.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{Up to 1 threshold} other{Up to {max} thresholds}}'**
  String isolinesMaxThresholds(int max);

  /// No description provided for @isolinesUseTraffic.
  ///
  /// In en, this message translates to:
  /// **'Use traffic'**
  String get isolinesUseTraffic;

  /// No description provided for @isolinesReachableAreas.
  ///
  /// In en, this message translates to:
  /// **'Reachable areas'**
  String get isolinesReachableAreas;

  /// No description provided for @isolinesWithin.
  ///
  /// In en, this message translates to:
  /// **'Within {threshold}'**
  String isolinesWithin(String threshold);

  /// No description provided for @isolinesPolygonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 polygon} other{{count} polygons}}'**
  String isolinesPolygonsCount(int count);

  /// No description provided for @isolinesSaveAsGeofence.
  ///
  /// In en, this message translates to:
  /// **'Save as geofence'**
  String get isolinesSaveAsGeofence;

  /// Default name of a geofence saved from a reachable area, e.g. 'Car 10 min'.
  ///
  /// In en, this message translates to:
  /// **'{mode} {threshold}'**
  String isolinesGeofenceName(String mode, String threshold);

  /// No description provided for @matrixTapOrigins.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to add origins'**
  String get matrixTapOrigins;

  /// No description provided for @matrixTapDestinations.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to add destinations'**
  String get matrixTapDestinations;

  /// No description provided for @matrixAddOrigins.
  ///
  /// In en, this message translates to:
  /// **'Add origins'**
  String get matrixAddOrigins;

  /// No description provided for @matrixAddDestinations.
  ///
  /// In en, this message translates to:
  /// **'Add destinations'**
  String get matrixAddDestinations;

  /// Button: compute the matrix for N origins × M destinations.
  ///
  /// In en, this message translates to:
  /// **'Calculate {origins} × {destinations}'**
  String matrixCalculate(int origins, int destinations);

  /// No description provided for @matrixErrorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 error} other{{count} errors}}'**
  String matrixErrorsCount(int count);

  /// No description provided for @matrixOrigins.
  ///
  /// In en, this message translates to:
  /// **'Origins ({count})'**
  String matrixOrigins(int count);

  /// No description provided for @matrixDestinations.
  ///
  /// In en, this message translates to:
  /// **'Destinations ({count})'**
  String matrixDestinations(int count);

  /// No description provided for @matrixAddOrigin.
  ///
  /// In en, this message translates to:
  /// **'Add origin'**
  String get matrixAddOrigin;

  /// No description provided for @matrixAddDestination.
  ///
  /// In en, this message translates to:
  /// **'Add destination'**
  String get matrixAddDestination;

  /// No description provided for @optimizeTapStops.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to add stops (numbers show visit order)'**
  String get optimizeTapStops;

  /// No description provided for @optimizeReturnToStart.
  ///
  /// In en, this message translates to:
  /// **'Return to start'**
  String get optimizeReturnToStart;

  /// No description provided for @optimizeEndAnywhere.
  ///
  /// In en, this message translates to:
  /// **'End anywhere (optional)'**
  String get optimizeEndAnywhere;

  /// End point of the tour.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get optimizeEnd;

  /// No description provided for @optimizeRoundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round trip'**
  String get optimizeRoundTrip;

  /// No description provided for @optimizeStops.
  ///
  /// In en, this message translates to:
  /// **'Stops ({count})'**
  String optimizeStops(int count);

  /// No description provided for @optimizeStopName.
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String optimizeStopName(int number);

  /// No description provided for @optimizeRun.
  ///
  /// In en, this message translates to:
  /// **'Optimize order'**
  String get optimizeRun;

  /// No description provided for @optimizeResult.
  ///
  /// In en, this message translates to:
  /// **'Optimized order'**
  String get optimizeResult;

  /// No description provided for @optimizeArrive.
  ///
  /// In en, this message translates to:
  /// **'arrive {time}'**
  String optimizeArrive(String time);

  /// No description provided for @optimizeDepart.
  ///
  /// In en, this message translates to:
  /// **'depart {time}'**
  String optimizeDepart(String time);

  /// No description provided for @optimizeCouldNotVisit.
  ///
  /// In en, this message translates to:
  /// **'Could not visit: {stops}'**
  String optimizeCouldNotVisit(String stops);

  /// No description provided for @snapTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap along a road to draw a rough GPS trace'**
  String get snapTapHint;

  /// No description provided for @snapTracePointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 trace point} other{{count} trace points}}'**
  String snapTracePointsCount(int count);

  /// Creates a simulated, imprecise GPS trace between the first and last points.
  ///
  /// In en, this message translates to:
  /// **'Generate noisy trace between first & last'**
  String get snapGenerateNoisyTrace;

  /// No description provided for @snapRadius.
  ///
  /// In en, this message translates to:
  /// **'Snap radius {meters} m'**
  String snapRadius(String meters);

  /// Button that matches the trace to roads.
  ///
  /// In en, this message translates to:
  /// **'Snap to roads'**
  String get snapRun;

  /// No description provided for @snapConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent}%'**
  String snapConfidence(String percent);

  /// No description provided for @snapSnappedPoints.
  ///
  /// In en, this message translates to:
  /// **'Snapped points'**
  String get snapSnappedPoints;

  /// How far a GPS point was moved onto the road.
  ///
  /// In en, this message translates to:
  /// **'moved {distance}'**
  String snapMoved(String distance);

  /// Default name for a new geofence, e.g. 'Circle 3'.
  ///
  /// In en, this message translates to:
  /// **'{shape} {number}'**
  String geofencesDefaultName(String shape, int number);

  /// No description provided for @geofencesOpenTracker.
  ///
  /// In en, this message translates to:
  /// **'Open tracker'**
  String get geofencesOpenTracker;

  /// No description provided for @geofencesTapTest.
  ///
  /// In en, this message translates to:
  /// **'Tap to test whether a point is inside'**
  String get geofencesTapTest;

  /// No description provided for @geofencesTapCircle.
  ///
  /// In en, this message translates to:
  /// **'Tap to place the circle center'**
  String get geofencesTapCircle;

  /// No description provided for @geofencesTapPolygon.
  ///
  /// In en, this message translates to:
  /// **'Tap to add polygon vertices'**
  String get geofencesTapPolygon;

  /// No description provided for @geofencesInfo.
  ///
  /// In en, this message translates to:
  /// **'Amazon Location geofence collections and trackers need IAM or Cognito credentials (API keys only cover Maps, Places and Routes). This screen stores geofences on the device and evaluates ENTER/EXIT events the same way.'**
  String get geofencesInfo;

  /// Tool: tap a point to check which geofences contain it.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get geofencesToolTest;

  /// No description provided for @geofencesShapeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get geofencesShapeCircle;

  /// No description provided for @geofencesShapePolygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get geofencesShapePolygon;

  /// No description provided for @geofencesOutsideAll.
  ///
  /// In en, this message translates to:
  /// **'Point is outside every geofence.'**
  String get geofencesOutsideAll;

  /// No description provided for @geofencesInside.
  ///
  /// In en, this message translates to:
  /// **'Inside: {names}'**
  String geofencesInside(String names);

  /// No description provided for @geofencesVerticesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 vertex} other{{count} vertices}}'**
  String geofencesVerticesCount(int count);

  /// No description provided for @geofencesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get geofencesName;

  /// No description provided for @geofencesNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Office, Warehouse'**
  String get geofencesNameHint;

  /// No description provided for @geofencesSave.
  ///
  /// In en, this message translates to:
  /// **'Save geofence'**
  String get geofencesSave;

  /// No description provided for @geofencesFromIsoline.
  ///
  /// In en, this message translates to:
  /// **'Create from a drive-time isoline'**
  String get geofencesFromIsoline;

  /// No description provided for @geofencesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 geofence} other{{count} geofences}}'**
  String geofencesCount(int count);

  /// No description provided for @geofencesDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get geofencesDeleteAll;

  /// No description provided for @geofencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No geofences yet. Draw one on the map.'**
  String get geofencesEmpty;

  /// Event: the device entered a geofence.
  ///
  /// In en, this message translates to:
  /// **'ENTER'**
  String get trackerEventEnter;

  /// Event: the device left a geofence.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get trackerEventExit;

  /// No description provided for @trackerTapStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to choose the trip start'**
  String get trackerTapStart;

  /// No description provided for @trackerTapEnd.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to choose the trip end'**
  String get trackerTapEnd;

  /// No description provided for @trackerReady.
  ///
  /// In en, this message translates to:
  /// **'Press Start tracking, or tap to pick a new start'**
  String get trackerReady;

  /// No description provided for @trackerFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow device'**
  String get trackerFollow;

  /// No description provided for @trackerSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate'**
  String get trackerSimulate;

  /// No description provided for @trackerDeviceGps.
  ///
  /// In en, this message translates to:
  /// **'Device GPS'**
  String get trackerDeviceGps;

  /// No description provided for @trackerPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed ×{speed}'**
  String trackerPlaybackSpeed(int speed);

  /// Button: stop tracking (verb).
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get trackerStop;

  /// No description provided for @trackerStart.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get trackerStart;

  /// Button: match the recorded trail to roads.
  ///
  /// In en, this message translates to:
  /// **'Snap trail'**
  String get trackerSnapTrail;

  /// Number of GPS position readings received.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fix} other{{count} fixes}}'**
  String trackerFixesCount(int count);

  /// No description provided for @trackerLocatingAddress.
  ///
  /// In en, this message translates to:
  /// **'Locating address…'**
  String get trackerLocatingAddress;

  /// No description provided for @trackerGeofences.
  ///
  /// In en, this message translates to:
  /// **'Geofences ({count})'**
  String trackerGeofences(int count);

  /// Number of geofences the device is currently inside.
  ///
  /// In en, this message translates to:
  /// **'inside {count}'**
  String trackerInsideCount(int count);

  /// No description provided for @trackerNoGeofences.
  ///
  /// In en, this message translates to:
  /// **'No geofences saved. Create some on the Geofences screen to get ENTER/EXIT events here.'**
  String get trackerNoGeofences;

  /// No description provided for @trackerEvents.
  ///
  /// In en, this message translates to:
  /// **'Events ({count})'**
  String trackerEvents(int count);

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String unitMeters(String value);

  /// No description provided for @unitKilometers.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String unitKilometers(String value);

  /// No description provided for @unitFeet.
  ///
  /// In en, this message translates to:
  /// **'{value} ft'**
  String unitFeet(String value);

  /// No description provided for @unitMiles.
  ///
  /// In en, this message translates to:
  /// **'{value} mi'**
  String unitMiles(String value);

  /// No description provided for @unitKmh.
  ///
  /// In en, this message translates to:
  /// **'{value} km/h'**
  String unitKmh(String value);

  /// No description provided for @unitMph.
  ///
  /// In en, this message translates to:
  /// **'{value} mph'**
  String unitMph(String value);

  /// Compact duration in seconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} s}}'**
  String unitSeconds(int count);

  /// Compact duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} min}}'**
  String unitMinutes(int count);

  /// Compact duration in hours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} h}}'**
  String unitHours(int count);

  /// Joins an hours part and a minutes part, e.g. '2 h 15 min'.
  ///
  /// In en, this message translates to:
  /// **'{hours} {minutes}'**
  String unitHoursMinutes(String hours, String minutes);

  /// Joins a short date and a time, e.g. 'Oct 19, 08:30'.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String dateTimeShort(String date, String time);

  /// A value range, e.g. a toll estimate 'E£10.00–E£15.00'.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to}'**
  String commonRange(String from, String to);

  /// {status} is the HTTP status (401/403); {detail} is the English message returned by AWS.
  ///
  /// In en, this message translates to:
  /// **'The AWS credentials were rejected ({status}): {detail} Check the identity pool role\'s permissions.'**
  String errorCredentialsRejected(int status, String detail);

  /// No description provided for @errorTrackerConfigIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter an identity pool ID and a tracker name.'**
  String get errorTrackerConfigIncomplete;

  /// 'region:uuid' describes the ID format and stays in English.
  ///
  /// In en, this message translates to:
  /// **'The identity pool ID should look like region:uuid.'**
  String get errorIdentityPoolIdInvalid;

  /// No description provided for @errorTrackerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Connect to the tracker first.'**
  String get errorTrackerNotConfigured;

  /// No description provided for @errorBackgroundTrackingUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Background tracking isn\'t available on this platform.'**
  String get errorBackgroundTrackingUnsupported;

  /// {detail} is the English message returned by AWS.
  ///
  /// In en, this message translates to:
  /// **'Cognito sign-in failed: {detail}'**
  String errorCognitoSignInFailed(String detail);

  /// {detail} is a technical error text from the tracking SDK, in English.
  ///
  /// In en, this message translates to:
  /// **'Tracking error: {detail}'**
  String errorTrackingPlatform(String detail);

  /// No description provided for @errorCloudTrackerSettingsNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Could not save the tracker settings.'**
  String get errorCloudTrackerSettingsNotSaved;

  /// Title of the screen that sends device positions to an Amazon Location tracker resource in AWS.
  ///
  /// In en, this message translates to:
  /// **'Cloud tracking'**
  String get cloudTrackingTitle;

  /// No description provided for @homeCloudTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Send device positions to an Amazon Location tracker with the Amazon Location Mobile SDKs, in the foreground or background.'**
  String get homeCloudTrackingDescription;

  /// Section with the identity pool and tracker settings.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get cloudTrackingSetupTitle;

  /// No description provided for @cloudTrackingIdentityPool.
  ///
  /// In en, this message translates to:
  /// **'Cognito identity pool ID'**
  String get cloudTrackingIdentityPool;

  /// No description provided for @cloudTrackingTrackerName.
  ///
  /// In en, this message translates to:
  /// **'Tracker name'**
  String get cloudTrackingTrackerName;

  /// The geo:... action names are AWS IAM permissions and are never translated.
  ///
  /// In en, this message translates to:
  /// **'Trackers don\'t accept API keys. Positions are signed with credentials from a Cognito identity pool whose unauthenticated role allows geo:BatchUpdateDevicePosition, geo:GetDevicePosition and geo:GetDevicePositionHistory on the tracker.'**
  String get cloudTrackingSetupHelp;

  /// No description provided for @cloudTrackingTimeFilter.
  ///
  /// In en, this message translates to:
  /// **'Time filter'**
  String get cloudTrackingTimeFilter;

  /// Minimum time between two uploaded positions.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{At least 1 second apart} other{At least {seconds} seconds apart}}'**
  String cloudTrackingTimeFilterValue(int seconds);

  /// No description provided for @cloudTrackingDistanceFilter.
  ///
  /// In en, this message translates to:
  /// **'Distance filter'**
  String get cloudTrackingDistanceFilter;

  /// Minimum distance between two uploaded positions; {distance} is formatted, e.g. '30 m'.
  ///
  /// In en, this message translates to:
  /// **'At least {distance} apart'**
  String cloudTrackingDistanceFilterValue(String distance);

  /// No description provided for @cloudTrackingAccuracyFilter.
  ///
  /// In en, this message translates to:
  /// **'Accuracy filter'**
  String get cloudTrackingAccuracyFilter;

  /// No description provided for @cloudTrackingAccuracyFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Skip moves smaller than the position\'s accuracy'**
  String get cloudTrackingAccuracyFilterHint;

  /// Button that signs in to the identity pool and prepares the tracker.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get cloudTrackingConnect;

  /// No description provided for @cloudTrackingNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get cloudTrackingNotConnected;

  /// {deviceId} is the ID positions are reported under.
  ///
  /// In en, this message translates to:
  /// **'Connected · device {deviceId}'**
  String cloudTrackingConnected(String deviceId);

  /// No description provided for @cloudTrackingStatusTracking.
  ///
  /// In en, this message translates to:
  /// **'Sending positions'**
  String get cloudTrackingStatusTracking;

  /// No description provided for @cloudTrackingStatusBackground.
  ///
  /// In en, this message translates to:
  /// **'Sending positions in the background'**
  String get cloudTrackingStatusBackground;

  /// No description provided for @cloudTrackingBackground.
  ///
  /// In en, this message translates to:
  /// **'Background tracking'**
  String get cloudTrackingBackground;

  /// Background tracking mode with continuous updates.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cloudTrackingBackgroundActive;

  /// Background tracking mode with infrequent updates.
  ///
  /// In en, this message translates to:
  /// **'Battery saver'**
  String get cloudTrackingBackgroundBatterySaver;

  /// No description provided for @cloudTrackingBackgroundStart.
  ///
  /// In en, this message translates to:
  /// **'Start in background'**
  String get cloudTrackingBackgroundStart;

  /// No description provided for @cloudTrackingBackgroundStop.
  ///
  /// In en, this message translates to:
  /// **'Stop background'**
  String get cloudTrackingBackgroundStop;

  /// No description provided for @cloudTrackingBackgroundHelp.
  ///
  /// In en, this message translates to:
  /// **'Android shows a notification while it runs; battery saver uploads about every 15 minutes. iOS needs the Always location permission.'**
  String get cloudTrackingBackgroundHelp;

  /// No description provided for @cloudTrackingBackgroundWeb.
  ///
  /// In en, this message translates to:
  /// **'Background tracking isn\'t available in the browser.'**
  String get cloudTrackingBackgroundWeb;

  /// No description provided for @cloudTrackingReadBack.
  ///
  /// In en, this message translates to:
  /// **'Read back from the tracker'**
  String get cloudTrackingReadBack;

  /// No description provided for @cloudTrackingLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest position'**
  String get cloudTrackingLatest;

  /// No description provided for @cloudTrackingHistory.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get cloudTrackingHistory;

  /// When the tracker stored the latest position; {time} is a formatted date and time.
  ///
  /// In en, this message translates to:
  /// **'Stored {time}'**
  String cloudTrackingLatestValue(String time);

  /// No description provided for @cloudTrackingNoPosition.
  ///
  /// In en, this message translates to:
  /// **'The tracker has no position for this device yet.'**
  String get cloudTrackingNoPosition;

  /// No description provided for @cloudTrackingHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No positions in the last 24 hours} =1{1 position in the last 24 hours} other{{count} positions in the last 24 hours}}'**
  String cloudTrackingHistoryCount(int count);

  /// Positions received from the device.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 received} other{{count} received}}'**
  String cloudTrackingReceived(int count);

  /// Positions stored by the tracker.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 uploaded} other{{count} uploaded}}'**
  String cloudTrackingUploaded(int count);

  /// Positions dropped by the time, distance or accuracy filter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 filtered} other{{count} filtered}}'**
  String cloudTrackingSkipped(int count);

  /// No description provided for @cloudTrackingErrors.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 error} other{{count} errors}}'**
  String cloudTrackingErrors(int count);

  /// No description provided for @cloudTrackingEventPosition.
  ///
  /// In en, this message translates to:
  /// **'Position received'**
  String get cloudTrackingEventPosition;

  /// No description provided for @cloudTrackingEventUploadStarted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Uploading 1 position} other{Uploading {count} positions}}'**
  String cloudTrackingEventUploadStarted(int count);

  /// No description provided for @cloudTrackingEventUploaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Uploaded 1 position} other{Uploaded {count} positions}}'**
  String cloudTrackingEventUploaded(int count);

  /// No description provided for @cloudTrackingEventSkipped.
  ///
  /// In en, this message translates to:
  /// **'Filtered out'**
  String get cloudTrackingEventSkipped;

  /// No description provided for @cloudTrackingEventAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location available'**
  String get cloudTrackingEventAvailable;

  /// No description provided for @cloudTrackingEventUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get cloudTrackingEventUnavailable;

  /// No description provided for @cloudTrackingEventBackgroundStopped.
  ///
  /// In en, this message translates to:
  /// **'Background tracking stopped'**
  String get cloudTrackingEventBackgroundStopped;

  /// {message} is a technical error text, in English.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String cloudTrackingEventError(String message);

  /// No description provided for @cloudTrackingLegendReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get cloudTrackingLegendReceived;

  /// No description provided for @cloudTrackingLegendUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get cloudTrackingLegendUploaded;

  /// No description provided for @cloudTrackingLegendHistory.
  ///
  /// In en, this message translates to:
  /// **'Stored history'**
  String get cloudTrackingLegendHistory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
