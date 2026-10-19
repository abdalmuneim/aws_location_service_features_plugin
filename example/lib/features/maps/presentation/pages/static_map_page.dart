import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/aws_config.dart';
import '../../../../core/l10n/core_labels.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../places/presentation/pages/location_picker_page.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/static_map_cubit.dart';

/// GetStaticMap playground: framing, size, style and GeoJSON overlays.
class StaticMapPage extends StatelessWidget {
  const StaticMapPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => StaticMapCubit(
      sl(),
      language: context.read<SettingsCubit>().state.language,
    )..render(),
    child: const _StaticMapView(),
  );
}

class _StaticMapView extends StatelessWidget {
  const _StaticMapView();

  static const _sizes = [
    (400, 300),
    (640, 400),
    (800, 600),
    (1024, 768),
    (1280, 720),
  ];

  static const _markerColors = [
    '#E53935',
    '#1E88E5',
    '#43A047',
    '#FB8C00',
    '#8E24AA',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaticMapCubit, StaticMapState>(
      builder: (context, state) {
        final controls = _controls(context, state);
        final preview = _preview(context, state);
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.staticMapTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LoadingBar(visible: state.status.isLoading),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.image),
            label: Text(context.l10n.staticMapRender),
            onPressed: state.status.isLoading
                ? null
                : context.read<StaticMapCubit>().render,
          ),
          body: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 900
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 400,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          children: controls,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [preview],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [preview, ...controls],
                  ),
          ),
        );
      },
    );
  }

  Widget _preview(BuildContext context, StaticMapState s) {
    final l10n = context.l10n;
    final img = s.image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (s.failure != null) FailureBanner(failure: s.failure!),
        if (img != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(img.bytes, gaplessPlayback: true),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.staticMapImageSize(
              Formatters.number(l10n, img.bytes.length / 1024),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.link),
              title: Text(l10n.staticMapRequestUrl),
              subtitle: SelectableText(
                img.url,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 11),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: img.url)),
              ),
            ),
          ),
        ] else if (!s.status.isLoading)
          EmptyHint(icon: Icons.image_outlined, message: l10n.staticMapEmpty),
      ],
    );
  }

  List<Widget> _controls(BuildContext context, StaticMapState s) {
    final l10n = context.l10n;
    final cubit = context.read<StaticMapCubit>();
    final r = s.request;
    void set(StaticMapRequest next) => cubit.update(next);

    return [
      SectionTitle(l10n.staticMapFraming),
      SegmentedButton<StaticFraming>(
        segments: [
          for (final f in StaticFraming.values)
            ButtonSegment(value: f, label: Text(f._label(l10n))),
        ],
        selected: {r.framing},
        onSelectionChanged: (v) => set(r.copyWith(framing: v.first)),
      ),
      if (r.framing != StaticFraming.fitMarkers)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.center_focus_strong),
          title: Text(l10n.staticMapCenter),
          subtitle: Text(Formatters.point(r.center)),
          trailing: TextButton(
            child: Text(l10n.commonPick),
            onPressed: () async {
              final picked = await pickLocation(
                context,
                title: l10n.staticMapPickCenter,
                center: r.center,
              );
              if (picked != null) set(r.copyWith(center: picked.point));
            },
          ),
        ),
      if (r.framing == StaticFraming.centerZoom)
        _slider(
          l10n.staticMapZoom(Formatters.number(l10n, r.zoom, 1)),
          r.zoom,
          1,
          20,
          (v) => set(r.copyWith(zoom: v)),
        ),
      if (r.framing == StaticFraming.centerRadius)
        _slider(
          l10n.staticMapRadius(Formatters.number(l10n, r.radiusMeters)),
          r.radiusMeters.toDouble(),
          100,
          50000,
          (v) => set(r.copyWith(radiusMeters: v.round())),
        ),
      if (r.framing == StaticFraming.fitMarkers)
        _slider(
          l10n.staticMapPadding(Formatters.number(l10n, r.padding)),
          r.padding.toDouble(),
          0,
          150,
          (v) => set(r.copyWith(padding: v.round())),
        ),
      SectionTitle(l10n.staticMapImage),
      DropdownButtonFormField<(int, int)>(
        initialValue: _sizes.contains((r.width, r.height))
            ? (r.width, r.height)
            : _sizes[1],
        decoration: InputDecoration(labelText: l10n.staticMapSize),
        items: [
          for (final size in _sizes)
            DropdownMenuItem(
              value: size,
              child: Text('${size.$1} × ${size.$2}'),
            ),
        ],
        onChanged: (v) => set(r.copyWith(width: v!.$1, height: v.$2)),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.staticMapHighDpi),
        value: r.highDpi,
        onChanged: (v) => set(r.copyWith(highDpi: v)),
      ),
      SectionTitle(l10n.staticMapStyle),
      SegmentedButton<StaticMapStyle>(
        segments: [
          ButtonSegment(
            value: StaticMapStyle.standard,
            icon: const Icon(Icons.map_outlined),
            label: Text(l10n.mapStyleStandard),
          ),
          ButtonSegment(
            value: StaticMapStyle.satellite,
            icon: const Icon(Icons.satellite_alt_outlined),
            label: Text(l10n.mapStyleSatellite),
          ),
        ],
        selected: {r.style},
        onSelectionChanged: (v) => set(r.copyWith(style: v.first)),
      ),
      if (r.isStandard) ...[
        const SizedBox(height: 12),
        SegmentedButton<MapColorScheme>(
          segments: [
            for (final c in MapColorScheme.values)
              ButtonSegment(value: c, label: Text(c.localizedLabel(l10n))),
          ],
          selected: {r.colorScheme},
          onSelectionChanged: (v) => set(r.copyWith(colorScheme: v.first)),
        ),
        const SizedBox(height: 12),
        SegmentedButton<StaticLabelSize>(
          segments: [
            ButtonSegment(
              value: StaticLabelSize.small,
              label: Text(l10n.staticMapLabelsSmall),
            ),
            ButtonSegment(
              value: StaticLabelSize.large,
              label: Text(l10n.staticMapLabelsLarge),
            ),
          ],
          selected: {r.labelSize},
          onSelectionChanged: (v) => set(r.copyWith(labelSize: v.first)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: r.language,
          decoration: InputDecoration(labelText: l10n.staticMapLabelLanguage),
          items: [
            DropdownMenuItem(child: Text(l10n.staticMapLabelLanguageLocal)),
            for (final e in AwsConfig.languages.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
          onChanged: (v) => set(
            v == null
                ? r.copyWith(clearLanguage: true)
                : r.copyWith(language: v),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: r.politicalView,
          decoration: InputDecoration(labelText: l10n.commonPoliticalView),
          items: [
            DropdownMenuItem(child: Text(l10n.commonDefault)),
            for (final code in AwsConfig.politicalViews.keys)
              DropdownMenuItem(
                value: code,
                child: Text(politicalViewName(l10n, code)),
              ),
          ],
          onChanged: (v) => set(
            v == null
                ? r.copyWith(clearPoliticalView: true)
                : r.copyWith(politicalView: v),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.staticMapPointsOfInterest),
          value: r.showPointsOfInterest,
          onChanged: (v) => set(r.copyWith(showPointsOfInterest: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.staticMapCropLabels),
          value: r.cropLabels,
          onChanged: (v) => set(r.copyWith(cropLabels: v)),
        ),
      ],
      const SizedBox(height: 12),
      DropdownButtonFormField<ScaleBarUnit>(
        initialValue: r.scaleUnit,
        decoration: InputDecoration(labelText: l10n.staticMapScaleBar),
        items: [
          for (final u in ScaleBarUnit.values)
            DropdownMenuItem(value: u, child: Text(u._label(l10n))),
        ],
        onChanged: (v) => set(r.copyWith(scaleUnit: v)),
      ),
      SectionTitle(
        l10n.staticMapMarkers,
        trailing: TextButton.icon(
          icon: const Icon(Icons.add_location_alt),
          label: Text(l10n.commonAdd),
          onPressed: () async {
            final picked = await pickLocation(
              context,
              title: l10n.staticMapAddMarker,
              center: r.center,
            );
            if (picked == null) return;
            set(
              r.copyWith(
                markers: [
                  ...r.markers,
                  StaticMapMarker(
                    position: picked.point,
                    label: picked.label.split(',').first,
                    colorHex:
                        _markerColors[r.markers.length % _markerColors.length],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      if (r.markers.isEmpty) Text(l10n.staticMapMarkersHint),
      for (final (i, m) in r.markers.indexed)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 12,
            backgroundColor: Color(
              int.parse('FF${m.colorHex.substring(1)}', radix: 16),
            ),
          ),
          title: Text(m.label ?? l10n.staticMapMarkerFallback(i + 1)),
          subtitle: Text(Formatters.point(m.position)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                set(r.copyWith(markers: [...r.markers]..removeAt(i))),
          ),
        ),
      if (r.markers.length >= 2)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.staticMapConnectMarkers),
          value: r.connectMarkers,
          onChanged: (v) => set(r.copyWith(connectMarkers: v)),
        ),
    ];
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      Text(label),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ],
  );
}

extension on StaticFraming {
  String _label(AppLocalizations l10n) => switch (this) {
    StaticFraming.centerZoom => l10n.staticMapFramingCenterZoom,
    StaticFraming.centerRadius => l10n.staticMapFramingCenterRadius,
    StaticFraming.fitMarkers => l10n.staticMapFramingFitMarkers,
  };
}

extension on ScaleBarUnit {
  String _label(AppLocalizations l10n) => switch (this) {
    ScaleBarUnit.off => l10n.commonOff,
    ScaleBarUnit.kilometers => l10n.staticMapScaleKilometers,
    ScaleBarUnit.miles => l10n.staticMapScaleMiles,
    ScaleBarUnit.kilometersMiles => l10n.staticMapScaleKilometersMiles,
    ScaleBarUnit.milesKilometers => l10n.staticMapScaleMilesKilometers,
  };
}
