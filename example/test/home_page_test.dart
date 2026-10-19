// Android lays out the first frame at zero size; the home page must survive
// it (it used to throw from SliverGrid, cascading into null-check errors).
import 'package:aws_location_service_features_example/app.dart';
import 'package:aws_location_service_features_example/features/settings/domain/entities/app_settings.dart';
import 'package:aws_location_service_features_example/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initDependencies();
  });

  for (final size in [Size.zero, const Size(1080, 2340)]) {
    testWidgets('home renders at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        LocationStudioApp(initialSettings: AppSettings.defaults()),
      );
      await tester.pump();
      tester.view.physicalSize = const Size(1080, 2340);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  }
}
