import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features/src/features/places/data/models/place_model.dart';
import 'package:aws_location_service_features/src/features/routes/data/models/routes_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tower = GeoPoint(30.0459, 31.2243);
  const pyramids = GeoPoint(29.9792, 31.1342);

  group('GeoUtils', () {
    test('distance Cairo Tower -> Giza pyramids is about 11.6 km', () {
      expect(GeoUtils.distance(tower, pyramids), closeTo(11600, 300));
    });

    test('circle ring is closed and has the right radius', () {
      final ring = GeoUtils.circle(tower, 1000, segments: 32);
      expect(ring.first, ring.last);
      for (final p in ring) {
        expect(GeoUtils.distance(tower, p), closeTo(1000, 1));
      }
    });

    test('containsPoint', () {
      const square = [
        GeoPoint(0, 0),
        GeoPoint(0, 1),
        GeoPoint(1, 1),
        GeoPoint(1, 0),
      ];
      expect(GeoUtils.containsPoint(square, const GeoPoint(0.5, 0.5)), isTrue);
      expect(GeoUtils.containsPoint(square, const GeoPoint(1.5, 0.5)), isFalse);
    });

    test('densify keeps endpoints and limits spacing', () {
      final path = GeoUtils.densify([tower, pyramids], 500);
      expect(path.first, tower);
      expect(path.last, pyramids);
      for (var i = 1; i < path.length; i++) {
        expect(GeoUtils.distance(path[i - 1], path[i]), lessThanOrEqualTo(501));
      }
    });
  });

  group('EvaluateGeofences', () {
    final fence = Geofence(
      id: 'tower',
      name: 'Tower',
      shape: const CircleShape(centerPoint: tower, radiusMeters: 200),
      colorValue: 0xFF000000,
      createdAt: DateTime(2026),
    );
    const evaluate = EvaluateGeofences();

    test('emits ENTER then EXIT', () {
      final enter = evaluate(
        GeofenceEvaluationParams(
          geofences: [fence],
          position: tower,
          previouslyInside: const {},
          time: DateTime(2026),
        ),
      );
      expect(enter.inside, {'tower'});
      expect(enter.events.single.transition, GeofenceTransition.enter);

      final stay = evaluate(
        GeofenceEvaluationParams(
          geofences: [fence],
          position: tower,
          previouslyInside: enter.inside,
          time: DateTime(2026),
        ),
      );
      expect(stay.events, isEmpty);

      final exit = evaluate(
        GeofenceEvaluationParams(
          geofences: [fence],
          position: pyramids,
          previouslyInside: stay.inside,
          time: DateTime(2026),
        ),
      );
      expect(exit.inside, isEmpty);
      expect(exit.events.single.transition, GeofenceTransition.exit);
    });

    test('geofence JSON round trip', () {
      final polygon = Geofence(
        id: 'p',
        name: 'Poly',
        shape: const PolygonShape([
          GeoPoint(0, 0),
          GeoPoint(0, 1),
          GeoPoint(1, 1),
        ]),
        colorValue: 0xFF112233,
        createdAt: DateTime.utc(2026, 1, 2),
        source: GeofenceSource.polygon,
      );
      for (final g in [fence, polygon]) {
        expect(GeofenceModel.fromJson(GeofenceModel.toJson(g)), g);
      }
    });
  });

  group('Parsing', () {
    test('PlaceModel reads a GetPlace item', () {
      final place = PlaceModel.fromJson({
        'PlaceId': 'abc',
        'PlaceType': 'PointOfInterest',
        'Title': 'Cairo Tower',
        'Address': {
          'Label': 'Cairo Tower, El Borg Street, Cairo, Egypt',
          'Country': {'Code3': 'EGY', 'Name': 'Egypt'},
          'Locality': 'Cairo',
        },
        'Position': [31.22429, 30.04585],
        'Categories': [
          {
            'Id': 'tourist_attraction',
            'Name': 'Tourist Attraction',
            'Primary': true,
          },
        ],
        'Contacts': {
          'Phones': [
            {'Value': '+20227357187'},
          ],
        },
        'TimeZone': {'Name': 'Africa/Cairo', 'Offset': '+03:00'},
        'MapView': [31.2, 30.0, 31.3, 30.1],
      });
      expect(place.position, const GeoPoint(30.04585, 31.22429));
      expect(place.address?.countryCode, 'EGY');
      expect(place.primaryCategory?.id, 'tourist_attraction');
      expect(place.contacts.phones, ['+20227357187']);
      expect(place.timeZone?.name, 'Africa/Cairo');
      expect(place.mapView?.north, 30.1);
    });

    test('RoutesMapper reads legs, steps and summary', () {
      final result = RoutesMapper.parseRoutes({
        'Routes': [
          {
            'Summary': {'Distance': 1200, 'Duration': 300},
            'MajorRoadLabels': [
              {
                'RoadName': {'Value': 'Corniche'},
              },
            ],
            'Legs': [
              {
                'TravelMode': 'Car',
                'Type': 'Vehicle',
                'Geometry': {
                  'LineString': [
                    [31.22, 30.04],
                    [31.23, 30.05],
                  ],
                },
                'VehicleLegDetails': {
                  'TravelSteps': [
                    {
                      'Distance': 1200,
                      'Duration': 300,
                      'Instruction': 'Head north',
                      'Type': 'Depart',
                    },
                  ],
                },
              },
            ],
          },
        ],
      });
      final route = result.routes.single;
      expect(route.distance, 1200);
      expect(route.geometry.length, 2);
      expect(route.steps.single.instruction, 'Head north');
      expect(route.majorRoads, ['Corniche']);
    });

    test('JsonUtils.compact drops empty values', () {
      expect(
        JsonUtils.compact({
          'a': null,
          'b': '',
          'c': <String>[],
          'd': {'e': null},
          'f': 0,
          'g': false,
        }),
        {'f': 0, 'g': false},
      );
    });
  });

  group('Styles', () {
    test('satellite drops options the API rejects', () {
      const options = MapStyleOptions(
        style: MapStyle.satellite,
        terrain: MapTerrain.hillshade,
        contourDensity: ContourDensity.high,
        traffic: true,
        travelModes: TravelModesOverlay.truck,
      );
      expect(
        options.sanitized(),
        const MapStyleOptions(style: MapStyle.satellite),
      );
    });
  });
}
