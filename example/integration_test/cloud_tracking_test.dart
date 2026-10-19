// On-device checks of the native cloud tracking bridge (Android/iOS):
//   flutter test integration_test/cloud_tracking_test.dart -d <device>
import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:aws_location_service_features/aws_location_service_features_platform_interface.dart';
import 'package:aws_location_service_features_example/app.dart';
import 'package:aws_location_service_features_example/features/settings/domain/entities/app_settings.dart';
import 'package:aws_location_service_features_example/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('native bridge', () {
    final platform = AwsLocationPlatform.instance;

    testWidgets('is the method channel implementation', (_) async {
      expect(platform, isA<MethodChannelAwsLocation>());
      expect(await platform.isTracking(), isFalse);
    });

    testWidgets('calls before configure report NOT_CONFIGURED', (_) async {
      await expectLater(
        platform.startTracking(),
        throwsA(
          isA<TrackingException>().having(
            (e) => e.code,
            'code',
            FailureCode.trackerNotConfigured,
          ),
        ),
      );
    });

    testWidgets('an unknown identity pool fails sign-in cleanly', (_) async {
      await expectLater(
        platform.configureTracker(
          const CloudTrackerConfig(
            identityPoolId: 'eu-north-1:00000000-0000-4000-8000-000000000000',
            trackerName: 'probe',
          ),
        ),
        throwsA(
          isA<TrackingException>().having(
            (e) => e.code,
            'code',
            FailureCode.cognitoSignInFailed,
          ),
        ),
      );
    });
  });

  testWidgets('the Cloud tracking screen opens from home', (tester) async {
    await initDependencies();
    await tester.pumpWidget(
      LocationStudioApp(
        initialSettings: AppSettings.defaults(),
        initialLocale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    final card = find.text('Cloud tracking');
    await tester.scrollUntilVisible(card, 300);
    await tester.tap(card);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
