import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  /// Strings for the current UI language: `context.l10n.appTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
