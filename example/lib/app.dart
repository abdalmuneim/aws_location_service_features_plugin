import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/l10n/app_locales.dart';
import 'core/l10n/l10n.dart';
import 'core/presentation/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'injection_container.dart';

class LocationStudioApp extends StatelessWidget {
  const LocationStudioApp({
    super.key,
    required this.initialSettings,
    this.initialLocale,
  });

  final AppSettings initialSettings;

  /// Saved UI language, or null to follow the device.
  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(sl(), initialSettings)),
        BlocProvider(create: (_) => LocaleCubit(sl(), initialLocale)),
      ],
      child: BlocSelector<SettingsCubit, AppSettings, AppThemePreference>(
        selector: (s) => s.theme,
        builder: (context, theme) => BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => MaterialApp(
            onGenerateTitle: (context) => context.l10n.appTitle,
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            localeListResolutionCallback: (preferred, _) =>
                AppLocales.resolve(preferred),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: switch (theme) {
              AppThemePreference.system => ThemeMode.system,
              AppThemePreference.light => ThemeMode.light,
              AppThemePreference.dark => ThemeMode.dark,
            },
            // Below Localizations, so it sees the resolved locale even when
            // following the device language.
            builder: (context, child) => Theme(
              data: AppTheme.forLocale(
                Theme.of(context),
                Localizations.localeOf(context),
              ),
              child: child!,
            ),
            home: const HomePage(),
          ),
        ),
      ),
    );
  }
}
