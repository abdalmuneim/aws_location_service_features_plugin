import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';

extension TravelModeIcon on TravelMode {
  IconData get icon => switch (this) {
    TravelMode.car => Icons.directions_car,
    TravelMode.pedestrian => Icons.directions_walk,
    TravelMode.scooter => Icons.electric_scooter,
    TravelMode.truck => Icons.local_shipping,
  };
}

extension TravelModeL10n on TravelMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TravelMode.car => l10n.travelModeCar,
    TravelMode.pedestrian => l10n.travelModeWalk,
    TravelMode.scooter => l10n.travelModeScooter,
    TravelMode.truck => l10n.travelModeTruck,
  };
}

extension RouteOptimizationL10n on RouteOptimization {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    RouteOptimization.fastest => l10n.routeFastest,
    RouteOptimization.shortest => l10n.routeShortest,
  };
}

extension TruckTypeL10n on TruckType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TruckType.straightTruck => l10n.truckTypeStraight,
    TruckType.tractor => l10n.truckTypeTractor,
    TruckType.lightTruck => l10n.truckTypeLight,
  };
}

class TravelModeSelector extends StatelessWidget {
  const TravelModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TravelMode value;
  final ValueChanged<TravelMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<TravelMode>(
    showSelectedIcon: false,
    segments: [
      for (final m in TravelMode.values)
        ButtonSegment(
          value: m,
          icon: Icon(m.icon),
          label: Text(m.localizedLabel(context.l10n)),
          tooltip: m.localizedLabel(context.l10n),
        ),
    ],
    selected: {value},
    onSelectionChanged: (v) => onChanged(v.first),
  );
}

class OptimizationSelector extends StatelessWidget {
  const OptimizationSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RouteOptimization value;
  final ValueChanged<RouteOptimization> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<RouteOptimization>(
    segments: [
      ButtonSegment(
        value: RouteOptimization.fastest,
        icon: const Icon(Icons.speed),
        label: Text(context.l10n.routeFastest),
      ),
      ButtonSegment(
        value: RouteOptimization.shortest,
        icon: const Icon(Icons.straighten),
        label: Text(context.l10n.routeShortest),
      ),
    ],
    selected: {value},
    onSelectionChanged: (v) => onChanged(v.first),
  );
}

/// Filter chips for every avoidable road feature.
class AvoidChips extends StatelessWidget {
  const AvoidChips({super.key, required this.value, required this.onChanged});

  final AvoidOptions value;
  final ValueChanged<AvoidOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = value;
    final items = <(String, IconData, bool, AvoidOptions Function(bool))>[
      (
        l10n.avoidTolls,
        Icons.toll,
        a.tollRoads,
        (v) => a.copyWith(tollRoads: v),
      ),
      (
        l10n.avoidFerries,
        Icons.directions_boat,
        a.ferries,
        (v) => a.copyWith(ferries: v),
      ),
      (
        l10n.avoidHighways,
        Icons.add_road,
        a.controlledAccessHighways,
        (v) => a.copyWith(controlledAccessHighways: v),
      ),
      (
        l10n.avoidTunnels,
        Icons.subway,
        a.tunnels,
        (v) => a.copyWith(tunnels: v),
      ),
      (
        l10n.avoidUTurns,
        Icons.u_turn_left,
        a.uTurns,
        (v) => a.copyWith(uTurns: v),
      ),
      (
        l10n.avoidDirtRoads,
        Icons.terrain,
        a.dirtRoads,
        (v) => a.copyWith(dirtRoads: v),
      ),
      (
        l10n.avoidCarTrains,
        Icons.train,
        a.carShuttleTrains,
        (v) => a.copyWith(carShuttleTrains: v),
      ),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (label, icon, selected, update) in items)
          FilterChip(
            avatar: Icon(icon, size: 16),
            label: Text(label),
            selected: selected,
            onSelected: (v) => onChanged(update(v)),
          ),
      ],
    );
  }
}

/// A route endpoint row: icon, label and pick/clear buttons.
class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final IconData icon;
  final Color iconColor;
  final String hint;
  final NamedLocation? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPick,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value?.label ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value == null ? scheme.onSurfaceVariant : null,
                    ),
                  ),
                ),
                if (value != null && onClear != null)
                  InkWell(
                    onTap: onClear,
                    child: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
