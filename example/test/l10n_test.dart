import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features_example/app.dart';
import 'package:aws_location_service_features_example/core/l10n/app_locales.dart';
import 'package:aws_location_service_features_example/core/l10n/failure_messages.dart';
import 'package:aws_location_service_features_example/core/l10n/l10n.dart';
import 'package:aws_location_service_features_example/core/utils/formatters.dart';
import 'package:aws_location_service_features_example/features/home/presentation/pages/home_page.dart';
import 'package:aws_location_service_features_example/features/settings/domain/entities/app_settings.dart';
import 'package:aws_location_service_features_example/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocales.resolve', () {
    test('uses a supported device language', () {
      expect(AppLocales.resolve(const [Locale('ar', 'EG')]), AppLocales.arabic);
      expect(
        AppLocales.resolve(const [Locale('en', 'GB')]),
        AppLocales.english,
      );
    });

    test('falls back to English otherwise', () {
      expect(AppLocales.resolve(null), AppLocales.english);
      expect(AppLocales.resolve(const []), AppLocales.english);
      expect(
        AppLocales.resolve(const [Locale('fr'), Locale('ar')]),
        AppLocales.english,
      );
    });
  });

  group('messages', () {
    final ar = lookupAppLocalizations(AppLocales.arabic);
    final en = lookupAppLocalizations(AppLocales.english);

    test('Arabic plurals pick the grammatical form for the count', () {
      expect(ar.commonResultsCount(0), 'لا توجد نتائج');
      expect(ar.commonResultsCount(1), 'نتيجة واحدة');
      expect(ar.commonResultsCount(2), 'نتيجتان');
      expect(ar.commonResultsCount(5), '5 نتائج');
      expect(ar.commonResultsCount(23), '23 نتيجة');
      expect(en.commonResultsCount(1), '1 result');
      expect(en.commonResultsCount(7), '7 results');
    });

    test('formatters follow the UI language', () {
      expect(Formatters.distance(ar, 850), '850 م');
      expect(Formatters.distance(ar, 12345), '12 كم');
      expect(Formatters.duration(ar, 45), '45 ثانية');
      expect(Formatters.duration(ar, 120), 'دقيقتان');
      expect(Formatters.duration(ar, 3900), 'ساعة واحدة و5 دقائق');
      expect(Formatters.duration(en, 3900), '1 h 5 min');
      expect(Formatters.number(ar, 12500), '12,500');
      // Coordinates stay "lat, lng" inside right-to-left text.
      expect(
        Formatters.point(const GeoPoint(30.0444, 31.2357), 4),
        '\u206630.0444, 31.2357\u2069',
      );
    });

    test('failures with a code are translated, API messages are not', () {
      const coded = ValidationFailure(
        'A route can have at most 23 stops.',
        code: FailureCode.routeTooManyStops,
        args: {'max': 23},
      );
      expect(coded.localizedMessage(en), 'A route can have at most 23 stops.');
      expect(
        coded.localizedMessage(ar),
        'لا يمكن أن يضمّ المسار أكثر من 23 محطة.',
      );
      const fromApi = ServerFailure('Upstream says no', statusCode: 500);
      expect(fromApi.localizedMessage(ar), 'Upstream says no');
    });
  });

  group('language switching', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await initDependencies();
    });

    TextDirection homeDirection(WidgetTester tester) =>
        Directionality.of(tester.element(find.byType(HomePage)));

    testWidgets('follows an Arabic device, then switches instantly and '
        'persists', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ar', 'EG')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
        LocationStudioApp(initialSettings: AppSettings.defaults()),
      );
      await tester.pumpAndSettle();
      expect(homeDirection(tester), TextDirection.rtl);

      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'English'),
      );
      await tester.pumpAndSettle();

      expect(homeDirection(tester), TextDirection.ltr);
      expect(sl<SharedPreferences>().getString('app_locale_v1'), 'en');
    });
  });
}
