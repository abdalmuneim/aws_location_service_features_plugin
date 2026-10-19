// Live checks of every data-layer call against Amazon Location.
//
// Skipped unless AWS_LIVE_TEST=1 and an API key are set:
//   AWS_LIVE_TEST=1 AWS_LOCATION_API_KEY=v1.public... //   AWS_LOCATION_REGION=eu-north-1 flutter test test/live_api_test.dart
import 'dart:io';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  final env = Platform.environment;
  final apiKey = env['AWS_LOCATION_API_KEY'] ?? '';
  final live = env['AWS_LIVE_TEST'] == '1' && apiKey.isNotEmpty;
  final config = AwsLocationConfig(
    apiKey: apiKey,
    region: env['AWS_LOCATION_REGION'] ?? 'eu-north-1',
  );
  final client = AwsLocationHttpClient(http.Client(), config);
  final places = PlacesRemoteDataSourceImpl(client, config);
  final routes = RoutesRemoteDataSourceImpl(client, config);
  final maps = MapsRemoteDataSourceImpl(client);

  const tower = GeoPoint(30.0459, 31.2243);
  const pyramids = GeoPoint(29.9792, 31.1342);
  const tahrir = GeoPoint(30.0444, 31.2357);

  group('Places', skip: !live, () {
    test('geocode text + components', () async {
      final r = await places.geocode(
        const GeocodeParams(queryText: 'Cairo Tower', biasPosition: tahrir),
      );
      expect(r, isNotEmpty);
      expect(r.first.position, isNotNull);
      final c = await places.geocode(
        const GeocodeParams(
          components: AddressComponents(country: 'EGY', locality: 'Cairo'),
          includePlaceTypes: [PlaceTypeFilter.locality],
        ),
      );
      expect(c, isNotEmpty);
    });

    test('reverse geocode', () async {
      final r = await places.reverseGeocode(
        const ReverseGeocodeParams(position: tower, maxResults: 3),
      );
      expect(r.first.address?.label, isNotNull);
    });

    test('autocomplete -> getPlace', () async {
      final r = await places.autocomplete(
        const AutocompleteParams(queryText: 'Tahrir Sq', biasPosition: tahrir),
      );
      expect(r, isNotEmpty);
      final p = await places.getPlace(GetPlaceParams(placeId: r.first.placeId));
      expect(p.position, isNotNull);
    });

    test('suggest -> search by query id', () async {
      final r = await places.suggest(
        const SuggestParams(queryText: 'coffee', biasPosition: tahrir),
      );
      expect(r, isNotEmpty);
      final q = r.where((s) => s.kind == SuggestionKind.query).firstOrNull;
      if (q != null) {
        final page = await places.searchText(
          SearchTextParams(queryId: q.queryId, biasPosition: tahrir),
        );
        expect(page.places, isNotEmpty);
      }
    });

    test('search text with circle filter', () async {
      final page = await places.searchText(
        const SearchTextParams(
          queryText: 'pharmacy',
          circleCenter: tahrir,
          circleRadius: 3000,
        ),
      );
      expect(page.places, isNotEmpty);
    });

    test('search nearby with categories', () async {
      final page = await places.searchNearby(
        const SearchNearbyParams(
          position: tahrir,
          radiusMeters: 2000,
          includeCategories: ['restaurant', 'coffee_shop'],
        ),
      );
      expect(page.places, isNotEmpty);
    });
  });

  group('Routes', skip: !live, () {
    test('car with alternatives and avoidances', () async {
      final r = await routes.calculateRoutes(
        const RouteRequest(
          origin: tower,
          destination: pyramids,
          avoid: AvoidOptions(tollRoads: true, ferries: true),
        ),
      );
      expect(r.routes, isNotEmpty);
      expect(r.routes.first.geometry.length, greaterThan(10));
      expect(r.routes.first.steps, isNotEmpty);
    });

    test('truck', () async {
      final r = await routes.calculateRoutes(
        const RouteRequest(
          origin: tower,
          destination: pyramids,
          travelMode: TravelMode.truck,
        ),
      );
      expect(r.routes, isNotEmpty);
    });

    test('pedestrian with waypoint and departure time', () async {
      final r = await routes.calculateRoutes(
        RouteRequest(
          origin: tower,
          destination: tahrir,
          waypoints: const [GeoPoint(30.0480, 31.2290)],
          travelMode: TravelMode.pedestrian,
          departureTime: DateTime.now().add(const Duration(hours: 2)),
        ),
      );
      expect(r.routes.first.legs.length, 2);
    });

    test('scooter', () async {
      final r = await routes.calculateRoutes(
        const RouteRequest(
          origin: tower,
          destination: tahrir,
          travelMode: TravelMode.scooter,
        ),
      );
      expect(r.routes, isNotEmpty);
    });

    test('isolines time + distance', () async {
      final t = await routes.calculateIsolines(
        const IsolineRequest(origin: tahrir, thresholds: [300, 600]),
      );
      expect(t.isolines.length, 2);
      expect(t.isolines.first.polygons.first.first.length, greaterThan(3));
      final d = await routes.calculateIsolines(
        const IsolineRequest(
          origin: tahrir,
          thresholds: [1000],
          kind: ThresholdKind.distance,
          travelMode: TravelMode.pedestrian,
        ),
      );
      expect(d.isolines, isNotEmpty);
    });

    test('route matrix', () async {
      final m = await routes.calculateRouteMatrix(
        const RouteMatrixRequest(
          origins: [tower, tahrir],
          destinations: [pyramids, tahrir],
        ),
      );
      expect(m.rows.length, 2);
      expect(m.rows.first.first.duration, isNotNull);
    });

    test('optimize waypoints', () async {
      final o = await routes.optimizeWaypoints(
        const OptimizeWaypointsRequest(
          origin: tower,
          destination: pyramids,
          stops: [
            OptimizationStop(id: 'A', position: tahrir),
            OptimizationStop(
              id: 'B',
              position: GeoPoint(30.02, 31.20),
              serviceSeconds: 300,
            ),
          ],
        ),
      );
      expect(o.stops.length, 4);
    });

    test('every travel mode on isolines, matrix, optimize and snap', () async {
      final now = DateTime.now();
      for (final mode in TravelMode.values) {
        await routes.calculateIsolines(
          IsolineRequest(
            origin: tahrir,
            thresholds: const [300],
            travelMode: mode,
          ),
        );
        await routes.calculateRouteMatrix(
          RouteMatrixRequest(
            origins: const [tower],
            destinations: const [tahrir],
            travelMode: mode,
          ),
        );
        await routes.optimizeWaypoints(
          OptimizeWaypointsRequest(
            origin: tower,
            stops: const [OptimizationStop(id: 'A', position: tahrir)],
            travelMode: mode,
          ),
        );
        await routes.snapToRoads(
          SnapRequest(
            travelMode: mode,
            points: [
              TracePoint(
                position: const GeoPoint(30.0459, 31.2243),
                timestamp: now,
              ),
              TracePoint(
                position: const GeoPoint(30.0465, 31.2262),
                timestamp: now.add(const Duration(seconds: 30)),
              ),
            ],
          ),
        );
      }
    });

    test('snap to roads', () async {
      final now = DateTime.now();
      final s = await routes.snapToRoads(
        SnapRequest(
          points: [
            TracePoint(
              position: const GeoPoint(30.0459, 31.2243),
              timestamp: now,
            ),
            TracePoint(
              position: const GeoPoint(30.0465, 31.2262),
              timestamp: now.add(const Duration(seconds: 20)),
            ),
            TracePoint(
              position: const GeoPoint(30.0472, 31.2290),
              timestamp: now.add(const Duration(seconds: 40)),
            ),
          ],
        ),
      );
      expect(s.points.length, 3);
    });
  });

  group('Maps', skip: !live, () {
    test('style descriptors for all styles', () async {
      for (final style in MapStyle.values) {
        final options = MapStyleOptions(
          style: style,
          colorScheme: MapColorScheme.dark,
          traffic: true,
          contourDensity: ContourDensity.medium,
        ).sanitized();
        final uri = maps.styleDescriptorUri(options);
        final res = await http.get(uri);
        expect(res.statusCode, 200, reason: '$style ${res.body}');
      }
    });

    test('static map with markers', () async {
      final bytes = await maps.fetchStaticMap(
        maps.staticMapUri(
          const StaticMapRequest(
            center: tahrir,
            framing: StaticFraming.fitMarkers,
            connectMarkers: true,
            language: 'en',
            politicalView: 'EGY',
            scaleUnit: ScaleBarUnit.kilometersMiles,
            markers: [
              StaticMapMarker(position: tower, label: 'Tower'),
              StaticMapMarker(position: pyramids, label: 'Pyramids'),
            ],
          ),
        ),
      );
      expect(bytes.length, greaterThan(1000));
    });
  });
}
