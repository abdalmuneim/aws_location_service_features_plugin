# aws_location_service_features

Amazon Location Service for Flutter on **Android, iOS and the web**.

| Feature | What you get | Auth | Android | iOS | Web |
|---|---|---|:-:|:-:|:-:|
| Maps | GetStyleDescriptor URLs for every style option, `AwsMapView` (MapLibre) with a declarative overlay, GetStaticMap | API key | ✓ | ✓ | ✓ |
| Places | Geocode, ReverseGeocode, Autocomplete, Suggest, SearchText, SearchNearby, GetPlace | API key | ✓ | ✓ | ✓ |
| Routes | CalculateRoutes, CalculateIsolines, CalculateRouteMatrix, OptimizeWaypoints, SnapToRoads | API key | ✓ | ✓ | ✓ |
| Geofencing | Circle/polygon geofences, ENTER/EXIT evaluation on the device, storage | none | ✓ | ✓ | ✓ |
| Device location | GPS / browser location, simulated trips along real routes | none | ✓ | ✓ | ✓ |
| Cloud tracking | Positions sent to an Amazon Location **tracker**, foreground and background, read back with GetDevicePosition / GetDevicePositionHistory | Cognito | ✓ ¹ | ✓ ¹ | ✓ ² |

¹ Through the official [Amazon Location Mobile Auth SDK](https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-android) and [Mobile Tracking SDK](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-android) ([iOS auth](https://github.com/aws-geospatial/amazon-location-mobile-auth-sdk-ios), [iOS tracking](https://github.com/aws-geospatial/amazon-location-mobile-tracking-sdk-ios)).
² AWS ships no tracking SDK for browsers, so the web uses the plugin's Dart implementation of the same calls (Cognito Identity + SigV4 + browser geolocation). Foreground only.

Maps, Places and Routes are plain HTTPS calls made from Dart on every platform, so they behave the same everywhere and need no native code.

The [example app](example/) ("Location Studio") uses every feature.

## Install

```yaml
dependencies:
  aws_location_service_features: ^0.1.0   # or a git dependency
```

### Android

The plugin's manifest brings the location, foreground-service and notification permissions and declares the Tracking SDK's `BackgroundLocationService`. `minSdk` 24 or later; below 26, enable core library desugaring (the AWS SDK for Kotlin uses `java.time`):

```kotlin
// android/app/build.gradle.kts
android { compileOptions { isCoreLibraryDesugaringEnabled = true } }
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") }
```

For **battery saver** background tracking (WorkManager) the user must allow location *all the time*; add `ACCESS_BACKGROUND_LOCATION` to your manifest if you use that mode. On Android 13+ ask for `POST_NOTIFICATIONS` so the tracking notification is visible.

### iOS

Cloud tracking needs **Swift Package Manager**, because the Amazon Location SDKs and the AWS SDK for Swift are only published there (Flutter 3.24+: `flutter config --enable-swift-package-manager`). With CocoaPods the plugin still builds; Maps, Places, Routes and geofencing work, and cloud tracking calls fail with `trackingPlatformError`.

Info.plist:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>…</string>
<!-- Background tracking only: -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>…</string>
<key>UIBackgroundModes</key>
<array><string>location</string></array>
```

### Web

Nothing to add. Location needs a secure context (HTTPS or localhost).

## Use

```dart
import 'package:aws_location_service_features/aws_location_service_features.dart';

final aws = AwsLocation(
  config: AwsLocationConfig(apiKey: 'v1.public…', region: 'eu-north-1'),
  geofenceStorage: await SharedPreferences.getInstance(), // optional
);
```

Every call returns a `Result<T>`, either `Ok(value)` or `Err(failure)`, and never throws:

```dart
final result = await aws.places.searchText(
  const SearchTextParams(queryText: 'koshary', biasPosition: GeoPoint(30.04, 31.24)),
);
switch (result) {
  case Ok(:final value): print(value.places.map((p) => p.title));
  case Err(:final failure): print(failure.message);
}
```

The use case classes (`SearchText`, `CalculateRoutes`, `SaveGeofence`, …) wrap the repositories with input validation and are the recommended entry points in a clean-architecture app.

`AwsLocationConfig` is mutable: change `apiKey`, `region`, `language` or `politicalView` and the next call uses the new value.

### Maps

```dart
AwsMapView(
  styleUrl: aws.styleUrl(const MapStyleOptions(
    style: MapStyle.standard,
    colorScheme: MapColorScheme.dark,
    terrain: MapTerrain.hillshade,
    traffic: true,
  )),
  initialCenter: const GeoPoint(30.0444, 31.2357),
  initialZoom: 12,
  overlay: MapOverlay(
    markers: [MapMarker(id: 'a', position: point, label: 'A')],
    polylines: [MapPolyline(id: 'route', points: route.geometry)],
  ),
  onTap: (point) {},
  onMapReady: (controller) => controller.fitPoints(points),
);
```

Static images: `aws.maps.getStaticMap(StaticMapRequest(...))`.

### Routes

```dart
final routes = await CalculateRoutes(aws.routes)(RouteRequest(
  origin: a, destination: b, travelMode: TravelMode.car, maxAlternatives: 2,
));
```

Also `CalculateIsolines`, `CalculateRouteMatrix`, `OptimizeWaypoints`, `SnapToRoads`.

### Geofencing

```dart
await SaveGeofence(aws.geofences)(Geofence(
  id: 'office', name: 'Office',
  shape: const CircleShape(centerPoint: office, radiusMeters: 150),
  colorValue: 0xFF7B1FA2, createdAt: DateTime.now(),
));
final evaluation = const EvaluateGeofences()(GeofenceEvaluationParams(
  geofences: fences, position: here, previouslyInside: inside, time: DateTime.now(),
));
// evaluation.events → ENTER / EXIT
```

### Cloud tracking

```dart
final tracking = aws.cloudTracking;
tracking.events.listen((event) => print(event)); // received, uploaded, skipped, errors

final deviceId = await ConfigureCloudTracker(tracking)(const CloudTrackerConfig(
  identityPoolId: 'eu-north-1:00000000-0000-0000-0000-000000000000',
  trackerName: 'my-tracker',
  minTimeBetweenUploads: Duration(seconds: 30), // null = off
  minDistanceMeters: 30,                        // null = off
  accuracyFilter: false,
));
await tracking.start();                                   // asks for permission
await tracking.startBackground(BackgroundTrackingMode.active); // Android, iOS
final latest = await tracking.latestPosition();
final history = await tracking.positionHistory(from: DateTime.now().subtract(const Duration(days: 1)));
```

#### AWS setup

Trackers don't accept API keys. Create:

1. An **Amazon Location tracker** (any position filtering).
2. An **Amazon Cognito identity pool** with guest (unauthenticated) access, in the same region.
3. A policy on the pool's unauthenticated role:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "geo:BatchUpdateDevicePosition",
      "geo:GetDevicePosition",
      "geo:GetDevicePositionHistory"
    ],
    "Resource": "arn:aws:geo:REGION:ACCOUNT_ID:tracker/TRACKER_NAME"
  }]
}
```

Devices report under a random id that the SDKs store on the device (not the Cognito identity), so don't add a `geo:DeviceIds` condition tied to `cognito-identity.amazonaws.com:sub`.

To get ENTER/EXIT events in the cloud, link the tracker to a geofence collection and route events with Amazon EventBridge.

#### Native SDK notes

The plugin works around three limits of the current SDKs (Android tracking 1.0.1 / auth 1.1.2, iOS tracking 1.1.0 / auth 1.2.0):

* **Credential expiry.** Both SDKs build their tracker client with a snapshot of the Cognito credentials, which last one hour. The plugin rebuilds the tracker when the credentials are refreshed (iOS) or expire (Android), and resumes tracking. Positions queued meanwhile stay in the SDK's database and are uploaded afterwards.
* **Android upload failures.** The Android SDK uploads in a coroutine without an exception handler, so an upload that still fails after its retries (offline, `AccessDenied`) would crash the app. The plugin intercepts *only* those SDK exceptions on coroutine worker threads, reports a `TrackingErrorEvent`, and rebuilds the foreground tracker (at most every 30 s). The SDK's background service can't be rebuilt from the background; it resumes the next time background tracking starts.
* **iOS events.** The iOS SDK has no callbacks, so `TrackingPositionReceived` events come from polling the SDK's last accepted position once a second. Upload events are Android/web only.

## Errors

`Failure` subclasses (`AuthFailure`, `ValidationFailure`, `ServerFailure`, `NetworkFailure`, `PermissionFailure`, `CacheFailure`, `TrackingFailure`, `UnexpectedFailure`) carry an English `message`, and, for errors the plugin raises itself, a `code` (`FailureCode`) with `args` so apps can translate them. Messages from AWS have no code.

Apps can add their own codes with an enum that implements `ErrorCode`.

## Architecture

```
lib/
├── aws_location_service_features.dart          public API
├── aws_location_service_features_web.dart      web registration (DartCloudTracker)
├── aws_location_service_features_platform_interface.dart
└── src/
    ├── aws_location.dart              AwsLocation: wires repositories to one config
    ├── core/                          config, auth (Cognito, SigV4), entities, errors,
    │                                  network clients, Result, use case contracts, utils
    ├── features/<maps|places|routes|geofencing|tracking>/
    │   ├── domain/                    entities, repository interfaces, use cases (pure Dart)
    │   ├── data/                      data sources, models, repository implementations
    │   └── presentation/widgets/      AwsMapView, MapOverlay, AwsMapController (maps)
    └── platform/                      AwsLocationPlatform + method channel (Android/iOS)
android/  Kotlin: CloudTracking over the Amazon Location Mobile Auth/Tracking SDKs
ios/      Swift (SwiftPM): CloudTracking over the iOS SDKs; CocoaPods stub
```

Dependency rule: presentation → domain ← data. Data sources throw, repositories wrap calls in `guard()` and return `Result<T>`.

## Tests

```bash
flutter test                                   # unit tests (SigV4 vectors, parsing, tracking, channel)
AWS_LIVE_TEST=1 AWS_LOCATION_API_KEY=v1.public... AWS_LOCATION_REGION=eu-north-1 \
  flutter test test/live_api_test.dart         # every Maps/Places/Routes call against AWS
cd example && flutter test                     # app, l10n and RTL tests
```
