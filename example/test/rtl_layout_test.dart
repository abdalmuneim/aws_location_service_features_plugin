// Arabic (RTL) layout smoke test: the non-map screens must lay out without
// overflow with the real Arabic font, whose glyphs are taller than Latin.
import 'dart:io';

import 'package:aws_location_service_features_example/app.dart';
import 'package:aws_location_service_features_example/core/l10n/app_locales.dart';
import 'package:aws_location_service_features_example/core/l10n/l10n.dart';
import 'package:aws_location_service_features_example/features/home/presentation/pages/home_page.dart';
import 'package:aws_location_service_features_example/features/settings/domain/entities/app_settings.dart';
import 'package:aws_location_service_features_example/features/settings/presentation/pages/settings_page.dart';
import 'package:aws_location_service_features_example/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadCairo() async {
  final loader = FontLoader('Cairo');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(
      File('assets/fonts/cairo/Cairo-$w.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
    await _loadCairo();
  });

  final ar = lookupAppLocalizations(AppLocales.arabic);

  for (final size in const [Size(360, 740), Size(900, 1200)]) {
    testWidgets('home and settings lay out in Arabic at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        LocationStudioApp(
          initialSettings: AppSettings.defaults(),
          initialLocale: AppLocales.arabic,
        ),
      );
      await tester.pumpAndSettle();

      final home = tester.element(find.byType(HomePage));
      expect(Directionality.of(home), TextDirection.rtl);
      expect(Theme.of(home).textTheme.bodyMedium?.fontFamily, 'Cairo');
      expect(find.text(ar.appTitle), findsOneWidget);
      await tester.dragUntilVisible(
        find.text(ar.trackerTitle),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      await tester.dragUntilVisible(
        find.text(ar.settingsAboutApiKeysTitle),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
    });
  }
}
