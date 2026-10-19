import 'package:flutter/material.dart';

import 'over_map.dart';
import 'status_views.dart';

/// Layout shared by every map screen: a map plus a control/result panel.
///
/// Wide windows show the panel on the start side (left in LTR, right in
/// RTL); narrow ones show it as a draggable bottom sheet over the map.
/// [mapControls] are laid over the map in the top-end corner.
class MapScaffold extends StatelessWidget {
  const MapScaffold({
    super.key,
    required this.title,
    required this.map,
    required this.panel,
    this.actions,
    this.mapControls = const [],
    this.mapBanner,
    this.loading = false,
    this.initialSheetSize = 0.38,
  });

  final String title;
  final Widget map;
  final List<Widget> panel;
  final List<Widget>? actions;
  final List<Widget> mapControls;

  /// Optional hint shown at the top of the map (e.g. "Tap to add a stop").
  final Widget? mapBanner;
  final bool loading;
  final double initialSheetSize;

  static const double _wideBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LoadingBar(visible: loading),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) =>
            constraints.maxWidth >= _wideBreakpoint
            ? _wide(context)
            : _narrow(context),
      ),
    );
  }

  Widget _mapStack() => Stack(
    children: [
      Positioned.fill(child: map),
      if (mapBanner != null)
        PositionedDirectional(
          top: 12,
          start: 12,
          end: 72,
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: OverMap(child: mapBanner!),
          ),
        ),
      PositionedDirectional(
        top: 12,
        end: 12,
        child: Column(
          children: [
            for (final c in mapControls)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OverMap(child: c),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _wide(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 420,
        child: Material(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: panel,
          ),
        ),
      ),
      const VerticalDivider(width: 1),
      Expanded(child: _mapStack()),
    ],
  );

  Widget _narrow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: _mapStack()),
        DraggableScrollableSheet(
          initialChildSize: initialSheetSize,
          minChildSize: 0.1,
          maxChildSize: 0.92,
          builder: (context, controller) => OverMap(
            child: Material(
              elevation: 8,
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  ...panel,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Round button for the map control column.
class MapControlButton extends StatelessWidget {
  const MapControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon),
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        onPressed: onPressed,
      ),
    );
  }
}

/// Pill-shaped hint drawn over the map.
class MapHint extends StatelessWidget {
  const MapHint(this.text, {super.key, this.icon = Icons.touch_app});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        color: scheme.inverseSurface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: scheme.onInverseSurface),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: scheme.onInverseSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
