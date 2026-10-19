import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/usecases/settings_usecases.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final settings =
      (await sl<LoadSettings>()(const NoParams())).valueOrNull ??
      AppSettings.defaults();
  final languageCode = (await sl<LoadAppLocale>()(const NoParams()))
      .valueOrNull;
  runApp(
    LocationStudioApp(
      initialSettings: settings,
      initialLocale: languageCode == null ? null : Locale(languageCode),
    ),
  );
}
