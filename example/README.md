# Location Studio

The example app of the [aws_location_service_features](../) plugin. It uses every
feature of the plugin: **Maps**, **Places** and **Routes** (v2) with an API
key, on-device geofencing and tracking, and **cloud tracking** to an Amazon
Location tracker through the Amazon Location Mobile SDKs.

Runs on **Android, iOS and Web** (map rendering uses
[maplibre_gl](https://pub.dev/packages/maplibre_gl), which has no desktop
support). The UI is in English and Arabic (RTL).

## Features

| Area | Screen | Amazon Location APIs |
|---|---|---|
| Maps | Map explorer | GetStyleDescriptor (Standard, Monochrome, Hybrid, Satellite · light/dark · political views · hillshade & 3D terrain · contour lines · real-time traffic · transit/truck overlays), tiles, glyphs, sprites; tap to reverse geocode |
| Maps | Static maps | GetStaticMap (center/zoom, center/radius, fit markers, size, @2x, style, labels, language, political view, POIs, scale bar, GeoJSON overlay) |
| Places | Search | SearchText (paged, circle & country filters), Suggest (places + query refinements), Autocomplete, GetPlace |
| Places | Nearby | SearchNearby with category filters and radius |
| Places | Geocode / Reverse geocode | Geocode (free text and structured address), ReverseGeocode (radius, place-type filters) |
| Routes | Directions | CalculateRoutes: car, walk, scooter, truck (dimensions & weight), stops, alternatives, avoidances, traffic, departure time, turn-by-turn |
| Routes | Isolines | CalculateIsolines by time or distance (save any area as a geofence) |
| Routes | Route matrix | CalculateRouteMatrix (many origins × destinations) |
| Routes | Optimize stops | OptimizeWaypoints, then CalculateRoutes through the optimized order |
| Routes | Snap to roads | SnapToRoads with tapped or generated noisy GPS traces |
| Geofencing | Geofences | Circle, polygon and isoline geofences, stored on the device |
| Tracking | Tracker | Device GPS or a simulated trip; ENTER/EXIT events, live reverse geocoding, SnapToRoads on the trail |
| Tracking | Cloud tracking | Amazon Location Mobile Tracking SDK (Android, iOS) or Dart (web): BatchUpdateDevicePosition with time/distance/accuracy filters, background tracking, GetDevicePosition, GetDevicePositionHistory |

Every result screen has a **Raw response** panel with the API's JSON.

## Running

```bash
flutter pub get
flutter run -d chrome          # web
flutter run                    # connected Android/iOS device
```

The API key and region default to the values in
[lib/core/config/aws_config.dart](lib/core/config/aws_config.dart). Override
them at build time without editing code:

```bash
flutter run --dart-define=AWS_LOCATION_API_KEY=v1.public... --dart-define=AWS_LOCATION_REGION=eu-north-1
```

or at runtime in **Settings** (saved on the device). Settings also holds the
results language, political view, units, theme and map style.

Cloud tracking needs a Cognito identity pool and a tracker (see the
[plugin README](../README.md#aws-setup)). Enter them on the Cloud tracking
screen, or pass them at build time:

```bash
flutter run --dart-define=AWS_COGNITO_IDENTITY_POOL_ID=eu-north-1:... --dart-define=AWS_TRACKER_NAME=my-tracker
```

Android builds need JDK 21 (a maplibre_gl requirement). iOS cloud tracking
needs Swift Package Manager (`flutter config --enable-swift-package-manager`).

### API key hygiene

Amazon Location API keys are meant to ship in client apps, but restrict
yours in the AWS console: limit it to the actions this app uses, and add
allowed referrers (web) or bundle/package IDs (mobile) plus an expiry.

## Architecture

Clean Architecture, feature-first. The **domain and data layers live in the
plugin**; this app holds the presentation layer, its own settings, and the
composition root:

```
lib/
├── core/
│   ├── config/              AwsConfig: defaults (key, region, map center, Cognito)
│   ├── error/               AppFailureCode: errors the app raises itself
│   ├── l10n/                locales, enum labels, translated failure messages
│   ├── presentation/        theme, MapScaffold, AppMapView, shared widgets
│   └── utils/               locale-aware formatters
├── features/
│   ├── maps · places · routes · geofencing · tracking
│   │   └── presentation/    Cubits (flutter_bloc), pages, widgets
│   ├── cloud_tracking/      saved tracker settings (data/domain) + Cubit and page
│   ├── settings/            app settings and UI language (all layers)
│   └── home/
├── l10n/                    ARB files (en, ar) and generated localizations
├── injection_container.dart get_it: AwsLocation (plugin) + use cases + Cubits' deps
├── app.dart                 MaterialApp + SettingsCubit + LocaleCubit
└── main.dart
```

- **Dependency rule:** presentation → domain ← data. Cubits depend on the
  plugin's use cases; repositories come from `AwsLocation`.
- **Errors:** repositories return `Result<T>`; Cubits never see exceptions.
  Failures with a `FailureCode` (plugin) or `AppFailureCode` (app) are shown
  in the UI language; AWS messages stay as they are.
- **Config:** `SettingsRepositoryImpl` writes the user's key, region,
  language and political view into the shared `AwsLocationConfig`, so changes
  apply to the next request.
- **Maps:** `AppMapView` wraps the plugin's `AwsMapView` and builds the style
  URL from the user's map settings.

## Tests

```bash
flutter test        # settings, formatters, l10n, RTL layout, home screen
```

The plugin's own tests (including live API checks) are in [../test](../test).
