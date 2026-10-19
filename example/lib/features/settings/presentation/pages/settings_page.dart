import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/l10n/core_labels.dart';
import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../injection_container.dart';
import '../../../maps/presentation/widgets/map_style_sheet.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/language_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _key = TextEditingController(
    text: context.read<SettingsCubit>().state.apiKey,
  );
  bool _showKey = false;
  bool _testing = false;

  /// Resolved at build time, so it follows a language change.
  String Function(AppLocalizations l10n)? _testResult;
  bool? _testOk;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final r = await sl<ReverseGeocode>()(
      const ReverseGeocodeParams(position: AwsConfig.defaultCenter),
    );
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testOk = r.isOk;
      _testResult = r.fold((f) => f.localizedMessage, (places) {
        final answer = places.firstOrNull?.address?.label;
        return (l10n) => l10n.settingsTestSuccess(answer ?? l10n.commonOk);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final s = context.watch<SettingsCubit>().state;
    final keyChanged = _key.text.trim() != s.apiKey;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              SectionTitle(l10n.settingsSectionConnection),
              TextField(
                controller: _key,
                obscureText: !_showKey,
                maxLines: 1,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.commonApiKey,
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showKey ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showKey = !_showKey),
                  ),
                ),
              ),
              if (keyChanged)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () {
                      cubit.update(s.copyWith(apiKey: _key.text.trim()));
                      setState(() {});
                    },
                    child: Text(l10n.settingsSaveKey),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: s.region,
                decoration: InputDecoration(
                  labelText: l10n.settingsRegion,
                  prefixIcon: const Icon(Icons.public),
                  helperText: l10n.settingsRegionHelper,
                ),
                items: [
                  for (final r in AwsConfig.supportedRegions)
                    DropdownMenuItem(value: r, child: Text(r)),
                ],
                onChanged: (v) => cubit.update(s.copyWith(region: v)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    icon: _testing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: Text(l10n.settingsTestConnection),
                    onPressed: _testing ? null : _test,
                  ),
                ],
              ),
              if (_testResult != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _testOk == true ? Icons.check_circle : Icons.error,
                    color: _testOk == true ? Colors.green : Colors.red,
                  ),
                  title: Text(_testResult!(l10n)),
                ),
              SectionTitle(l10n.settingsSectionResults),
              DropdownButtonFormField<String>(
                initialValue: AwsConfig.languages.containsKey(s.language)
                    ? s.language
                    : 'en',
                decoration: InputDecoration(
                  labelText: l10n.settingsResultsLanguage,
                  prefixIcon: const Icon(Icons.translate),
                ),
                items: [
                  for (final e in AwsConfig.languages.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => cubit.update(s.copyWith(language: v)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: s.politicalView,
                decoration: InputDecoration(
                  labelText: l10n.commonPoliticalView,
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: [
                  DropdownMenuItem(child: Text(l10n.commonDefault)),
                  for (final code in AwsConfig.politicalViews.keys)
                    DropdownMenuItem(
                      value: code,
                      child: Text(politicalViewName(l10n, code)),
                    ),
                ],
                onChanged: (v) => cubit.update(
                  v == null
                      ? s.copyWith(clearPoliticalView: true)
                      : s.copyWith(politicalView: v),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.settingsUnits),
              const SizedBox(height: 6),
              SegmentedButton<MeasurementUnits>(
                segments: [
                  for (final u in MeasurementUnits.values)
                    ButtonSegment(
                      value: u,
                      label: Text(u.localizedLabel(l10n)),
                    ),
                ],
                selected: {s.units},
                onSelectionChanged: (v) =>
                    cubit.update(s.copyWith(units: v.first)),
              ),
              SectionTitle(l10n.settingsSectionAppearance),
              const LanguageDropdown(),
              const SizedBox(height: 12),
              SegmentedButton<AppThemePreference>(
                segments: [
                  ButtonSegment(
                    value: AppThemePreference.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(l10n.settingsThemeSystem),
                  ),
                  ButtonSegment(
                    value: AppThemePreference.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(l10n.commonLight),
                  ),
                  ButtonSegment(
                    value: AppThemePreference.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(l10n.commonDark),
                  ),
                ],
                selected: {s.theme},
                onSelectionChanged: (v) =>
                    cubit.update(s.copyWith(theme: v.first)),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.layers),
                title: Text(l10n.mapStyleTitle),
                subtitle: Text(
                  '${s.mapStyle.style.localizedLabel(l10n)} · '
                  '${s.mapStyle.colorScheme.localizedLabel(l10n)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showMapStyleSheet(context),
              ),
              const Divider(height: 32),
              OutlinedButton.icon(
                icon: const Icon(Icons.restore),
                label: Text(l10n.settingsResetDefaults),
                onPressed: () async {
                  await cubit.reset();
                  _key.text = cubit.state.apiKey;
                  setState(() {});
                },
              ),
              SectionTitle(l10n.settingsAboutApiKeysTitle),
              Text(l10n.settingsAboutApiKeysBody),
            ],
          ),
        ),
      ),
    );
  }
}
