import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/l10n/core_labels.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

/// Opens the map style editor (styles, color scheme, political view,
/// terrain, contours, traffic and travel-mode overlays).
Future<void> showMapStyleSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const OverMap(child: _MapStyleSheet()),
      ),
    );

class _MapStyleSheet extends StatelessWidget {
  const _MapStyleSheet();

  static const _styleIcons = {
    MapStyle.standard: Icons.map_outlined,
    MapStyle.monochrome: Icons.contrast,
    MapStyle.hybrid: Icons.layers_outlined,
    MapStyle.satellite: Icons.satellite_alt_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SettingsCubit>();
    final settings = context.watch<SettingsCubit>().state;
    final o = settings.mapStyle;

    void set(MapStyleOptions next) => cubit.updateMapStyle(next);

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(l10n.mapStyleTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final s in MapStyle.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _StyleTile(
                    icon: _styleIcons[s]!,
                    label: s.localizedLabel(l10n),
                    selected: o.style == s,
                    onTap: () => set(o.copyWith(style: s)),
                  ),
                ),
              ),
          ],
        ),
        SectionTitle(l10n.mapStyleColorScheme),
        SegmentedButton<MapColorScheme>(
          segments: [
            ButtonSegment(
              value: MapColorScheme.light,
              icon: const Icon(Icons.light_mode),
              label: Text(l10n.commonLight),
            ),
            ButtonSegment(
              value: MapColorScheme.dark,
              icon: const Icon(Icons.dark_mode),
              label: Text(l10n.commonDark),
            ),
          ],
          selected: {o.colorScheme},
          onSelectionChanged: (v) => set(o.copyWith(colorScheme: v.first)),
        ),
        SectionTitle(l10n.commonPoliticalView),
        DropdownButtonFormField<String?>(
          initialValue: settings.politicalView,
          decoration: InputDecoration(
            helperText: o.supportsPoliticalView
                ? l10n.mapStylePoliticalViewHelper
                : l10n.mapStyleNotForSatellite,
          ),
          items: [
            DropdownMenuItem(child: Text(l10n.commonDefault)),
            for (final code in AwsConfig.politicalViews.keys)
              DropdownMenuItem(
                value: code,
                child: Text('${politicalViewName(l10n, code)} ($code)'),
              ),
          ],
          onChanged: (v) => cubit.update(
            v == null
                ? settings.copyWith(clearPoliticalView: true)
                : settings.copyWith(politicalView: v),
          ),
        ),
        SectionTitle(l10n.mapStyleTerrain),
        SegmentedButton<MapTerrain>(
          segments: [
            for (final t in MapTerrain.values)
              ButtonSegment(
                value: t,
                label: Text(t.localizedLabel(l10n)),
                enabled: t != MapTerrain.hillshade || o.supportsHillshade,
              ),
          ],
          selected: {o.terrain},
          onSelectionChanged: (v) => set(o.copyWith(terrain: v.first)),
        ),
        if (o.terrain == MapTerrain.terrain3d)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.mapStyleTerrain3dHint,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        SectionTitle(
          l10n.mapStyleContours,
          trailing: o.supportsContours ? null : Text(l10n.mapStyleNotAvailable),
        ),
        SegmentedButton<ContourDensity>(
          segments: [
            for (final c in ContourDensity.values)
              ButtonSegment(
                value: c,
                label: Text(c.localizedLabel(l10n)),
                enabled: o.supportsContours,
              ),
          ],
          selected: {o.contourDensity},
          onSelectionChanged: (v) => set(o.copyWith(contourDensity: v.first)),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.traffic),
          title: Text(l10n.mapStyleTraffic),
          value: o.traffic,
          onChanged: o.supportsTraffic
              ? (v) => set(o.copyWith(traffic: v))
              : null,
        ),
        SectionTitle(l10n.mapStyleTravelModes),
        SegmentedButton<TravelModesOverlay>(
          segments: [
            for (final t in TravelModesOverlay.values)
              ButtonSegment(
                value: t,
                label: Text(t.localizedLabel(l10n)),
                enabled: o.supportsTravelModes,
              ),
          ],
          selected: {o.travelModes},
          onSelectionChanged: (v) => set(o.copyWith(travelModes: v.first)),
        ),
      ],
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? scheme.primary : null),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
