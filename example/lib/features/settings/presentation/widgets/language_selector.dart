import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../core/l10n/l10n.dart';
import '../cubit/locale_cubit.dart';

/// Each language is named in its own script so it stays recognizable
/// whatever language the UI is in; these are deliberately not translated.
const Map<String, String> _languageNames = {'en': 'English', 'ar': 'العربية'};

/// Menu value for "follow the device"; a popup menu can't select `null`.
const String _device = 'device';

/// Dropdown for the settings screen: device language, English or Arabic.
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleCubit>().state;
    return DropdownButtonFormField<String?>(
      initialValue: locale?.languageCode,
      decoration: InputDecoration(
        labelText: l10n.settingsAppLanguage,
        prefixIcon: const Icon(Icons.language),
      ),
      items: [
        DropdownMenuItem(child: Text(l10n.settingsAppLanguageDevice)),
        for (final l in AppLocales.supported)
          DropdownMenuItem(
            value: l.languageCode,
            child: Text(_languageNames[l.languageCode]!),
          ),
      ],
      onChanged: (code) => context.read<LocaleCubit>().setLocale(
        code == null ? null : Locale(code),
      ),
    );
  }
}

/// App bar button that switches the UI language from any screen.
class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LocaleCubit>().state?.languageCode ?? _device;
    return PopupMenuButton<String>(
      tooltip: l10n.commonLanguage,
      icon: const Icon(Icons.language),
      initialValue: current,
      onSelected: (code) => context.read<LocaleCubit>().setLocale(
        code == _device ? null : Locale(code),
      ),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: _device,
          checked: current == _device,
          child: Text(l10n.settingsAppLanguageDevice),
        ),
        for (final l in AppLocales.supported)
          CheckedPopupMenuItem(
            value: l.languageCode,
            checked: current == l.languageCode,
            child: Text(_languageNames[l.languageCode]!),
          ),
      ],
    );
  }
}
