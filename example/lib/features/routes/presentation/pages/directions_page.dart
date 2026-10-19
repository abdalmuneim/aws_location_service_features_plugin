import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/over_map.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../places/presentation/pages/location_picker_page.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/directions_cubit.dart';
import '../widgets/route_controls.dart';

/// CalculateRoutes: car, walking, scooter and truck directions with
/// waypoints, alternatives, avoidances, traffic and departure time.
class DirectionsPage extends StatelessWidget {
  const DirectionsPage({super.key, this.origin, this.destination});

  final NamedLocation? origin;
  final NamedLocation? destination;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DirectionsCubit(
      sl(),
      sl(),
      units: context.read<SettingsCubit>().state.units,
      origin: origin,
      destination: destination,
    ),
    child: const _DirectionsView(),
  );
}

class _DirectionsView extends StatefulWidget {
  const _DirectionsView();

  @override
  State<_DirectionsView> createState() => _DirectionsViewState();
}

class _DirectionsViewState extends State<_DirectionsView> {
  AwsMapController? _map;
  Object? _fitted;

  Future<NamedLocation?> _pick(String title, NamedLocation? current) =>
      pickLocation(
        context,
        title: title,
        initial: current,
        center: _map?.center,
      );

  void _fitRoutes(DirectionsState s) {
    final result = s.result;
    if (result == null || identical(result, _fitted)) return;
    _fitted = result;
    _map?.fitPoints([for (final r in result.routes) ...r.geometry]);
  }

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocConsumer<DirectionsCubit, DirectionsState>(
      listenWhen: (a, b) => a.result != b.result,
      listener: (_, s) => _fitRoutes(s),
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<DirectionsCubit>();
        final route = s.selectedRoute;
        return MapScaffold(
          title: l10n.directionsTitle,
          loading: s.status.isLoading,
          map: AppMapView(
            initialCenter: s.origin?.point ?? s.destination?.point,
            onMapReady: (c) {
              _map = c;
              _fitRoutes(s);
            },
            onTap: s.destination == null || s.origin == null
                ? cubit.tapAt
                : null,
            overlay: _overlay(s),
          ),
          mapBanner: s.ready
              ? null
              : MapHint(
                  s.origin == null
                      ? l10n.routeTapStart
                      : l10n.directionsTapDestination,
                ),
          panel: [
            LocationField(
              icon: Icons.trip_origin,
              iconColor: MapColors.origin,
              hint: l10n.directionsChooseStart,
              value: s.origin,
              onPick: () async {
                final l = await _pick(l10n.routeStart, s.origin);
                if (l != null) cubit.setOrigin(l);
              },
              onClear: () => cubit.setOrigin(null),
            ),
            for (final (i, w) in s.waypoints.indexed)
              LocationField(
                icon: Icons.more_vert,
                iconColor: MapColors.waypoint,
                hint: l10n.routeStop,
                value: w,
                onPick: () {},
                onClear: () => cubit.removeWaypoint(i),
              ),
            LocationField(
              icon: Icons.place,
              iconColor: MapColors.destination,
              hint: l10n.directionsChooseDestination,
              value: s.destination,
              onPick: () async {
                final l = await _pick(l10n.routeDestination, s.destination);
                if (l != null) cubit.setDestination(l);
              },
              onClear: () => cubit.setDestination(null),
            ),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(l10n.routeAddStop),
                  onPressed: () async {
                    final l = await _pick(l10n.routeAddStop, null);
                    if (l != null) cubit.addWaypoint(l);
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.directionsSwap,
                  icon: const Icon(Icons.swap_vert),
                  onPressed: s.ready ? cubit.swap : null,
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TravelModeSelector(
                value: s.travelMode,
                onChanged: cubit.setTravelMode,
              ),
            ),
            _options(context, s),
            if (s.failure != null) FailureBanner(failure: s.failure!),
            if (s.result != null) ...[
              for (final n in s.result!.notices)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.info_outline),
                  title: Text(n),
                ),
              SectionTitle(l10n.directionsRoutesCount(s.result!.routes.length)),
              for (final (i, r) in s.result!.routes.indexed)
                _RouteCard(
                  route: r,
                  index: i,
                  selected: i == s.selected,
                  units: units,
                  onTap: () => cubit.selectRoute(i),
                ),
              if (route != null) ...[
                SectionTitle(l10n.directionsTurnByTurn(route.steps.length)),
                for (final step in route.steps)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_stepIcon(step.type)),
                    title: Text(step.instruction),
                    trailing: Text(
                      '${Formatters.distance(l10n, step.distance, units)}\n'
                      '${Formatters.duration(l10n, step.duration)}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              JsonViewer(
                data: s.result!.raw,
                title: l10n.commonApiResponse('CalculateRoutes'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _options(BuildContext context, DirectionsState s) {
    final l10n = context.l10n;
    final cubit = context.read<DirectionsCubit>();
    final walking = s.travelMode == TravelMode.pedestrian;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.tune),
        title: Text(l10n.directionsRouteOptions),
        subtitle: Text(
          [
            s.optimizeFor.localizedLabel(l10n),
            if (s.avoid.any) l10n.directionsSummaryAvoid(s.avoid.count),
            s.departureTime == null
                ? l10n.directionsSummaryDepartNow
                : l10n.directionsSummaryDepartAt(
                    Formatters.dateTime(l10n, s.departureTime),
                  ),
          ].join(' · '),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!walking) ...[
            OptimizationSelector(
              value: s.optimizeFor,
              onChanged: cubit.setOptimization,
            ),
            SectionTitle(l10n.routeAvoid),
            AvoidChips(value: s.avoid, onChanged: cubit.setAvoid),
          ],
          SectionTitle(
            s.waypoints.isEmpty
                ? l10n.directionsAlternatives(s.maxAlternatives)
                : l10n.directionsAlternativesUnavailable,
          ),
          Slider(
            value: s.maxAlternatives.toDouble(),
            max: 5,
            divisions: 5,
            label: '${s.maxAlternatives}',
            onChanged: s.waypoints.isEmpty
                ? (v) => cubit.setAlternatives(v.round())
                : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.traffic_outlined),
            title: Text(l10n.directionsUseTraffic),
            value: s.useTraffic,
            onChanged: cubit.setTraffic,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(
              s.departureTime == null
                  ? l10n.directionsDepartNow
                  : l10n.directionsDepartAt(
                      Formatters.dateTime(l10n, s.departureTime),
                    ),
            ),
            trailing: Wrap(
              children: [
                if (s.departureTime != null)
                  TextButton(
                    onPressed: () => cubit.setDeparture(null),
                    child: Text(l10n.directionsNow),
                  ),
                TextButton(
                  onPressed: () => _pickDeparture(context, s),
                  child: Text(l10n.commonChange),
                ),
              ],
            ),
          ),
          if (s.travelMode == TravelMode.truck) ...[
            SectionTitle(l10n.travelModeTruck),
            TruckEditor(value: s.truck, onChanged: cubit.setTruck),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDeparture(BuildContext context, DirectionsState s) async {
    final cubit = context.read<DirectionsCubit>();
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: s.departureTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (_, child) => OverMap(child: child!),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(s.departureTime ?? now),
      builder: (_, child) => OverMap(child: child!),
    );
    if (time == null) return;
    cubit.setDeparture(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  MapOverlay _overlay(DirectionsState s) {
    final routes = s.result?.routes ?? const <RouteOption>[];
    return MapOverlay(
      polylines: [
        for (final (i, r) in routes.indexed)
          if (i != s.selected)
            MapPolyline(
              id: 'alt-$i',
              points: r.geometry,
              color: MapColors.alternative,
              width: 5,
            ),
        if (s.selectedRoute != null)
          MapPolyline(
            id: 'route',
            points: s.selectedRoute!.geometry,
            color: MapColors.primary,
            width: 6,
          ),
      ],
      markers: [
        if (s.origin != null)
          MapMarker(
            id: 'origin',
            position: s.origin!.point,
            color: MapColors.origin,
            label: 'A',
            radius: 11,
          ),
        for (final (i, w) in s.waypoints.indexed)
          MapMarker(
            id: 'wp-$i',
            position: w.point,
            color: MapColors.waypoint,
            label: '${i + 1}',
          ),
        if (s.destination != null)
          MapMarker(
            id: 'destination',
            position: s.destination!.point,
            color: MapColors.destination,
            label: 'B',
            radius: 11,
          ),
      ],
    );
  }

  static IconData _stepIcon(String type) => switch (type) {
    'Depart' => Icons.trip_origin,
    'Arrive' => Icons.flag,
    'Turn' => Icons.turn_right,
    'Keep' => Icons.fork_right,
    'RoundaboutEnter' ||
    'RoundaboutPass' ||
    'RoundaboutExit' => Icons.roundabout_right,
    'UTurn' => Icons.u_turn_left,
    'Ramp' || 'Exit' => Icons.ramp_right,
    'Ferry' => Icons.directions_boat,
    'Continue' || 'ContinueHighway' => Icons.straight,
    _ => Icons.navigation_outlined,
  };
}

String _tollText(AppLocalizations l10n, TollCost tolls) {
  final min = Formatters.money(l10n, tolls.min, tolls.currency);
  return tolls.isRange
      ? l10n.commonRange(
          min,
          Formatters.money(l10n, tolls.max!, tolls.currency),
        )
      : min;
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.index,
    required this.selected,
    required this.units,
    required this.onTap,
  });

  final RouteOption route;
  final int index;
  final bool selected;
  final MeasurementUnits units;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Wraps rather than overflows when the duration is long
                  // (e.g. Arabic "ساعتان و45 دقيقة").
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          Formatters.duration(l10n, route.duration),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(Formatters.distance(l10n, route.distance, units)),
                      ],
                    ),
                  ),
                  if (index == 0) Chip(label: Text(l10n.directionsBest)),
                ],
              ),
              if (route.majorRoads.isNotEmpty)
                Text(l10n.directionsVia(route.majorRoads.join(', '))),
              Wrap(
                spacing: 8,
                children: [
                  Text(l10n.directionsLegsCount(route.legs.length)),
                  if (route.tollSummary case final tolls?)
                    Text(l10n.directionsTolls(_tollText(l10n, tolls))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Truck dimensions, committed when a slider is released.
class TruckEditor extends StatefulWidget {
  const TruckEditor({super.key, required this.value, required this.onChanged});

  final TruckProfile value;
  final ValueChanged<TruckProfile> onChanged;

  @override
  State<TruckEditor> createState() => _TruckEditorState();
}

class _TruckEditorState extends State<TruckEditor> {
  late TruckProfile _t = widget.value;

  Widget _slider(
    String label,
    int value,
    int min,
    int max,
    TruckProfile Function(int) update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      Slider(
        value: value.toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max - min > 100 ? 100 : max - min,
        onChanged: (v) => setState(() => _t = update(v.round())),
        onChangeEnd: (_) => widget.onChanged(_t),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<TruckType>(
          initialValue: _t.type,
          decoration: InputDecoration(labelText: l10n.truckType),
          items: [
            for (final t in TruckType.values)
              DropdownMenuItem(value: t, child: Text(t.localizedLabel(l10n))),
          ],
          onChanged: (v) {
            setState(() => _t = _t.copyWith(type: v));
            widget.onChanged(_t);
          },
        ),
        const SizedBox(height: 8),
        _slider(
          l10n.truckGrossWeight(
            Formatters.number(l10n, _t.grossWeightKg / 1000, 1),
          ),
          _t.grossWeightKg,
          1000,
          44000,
          (v) => _t.copyWith(grossWeightKg: v),
        ),
        _slider(
          l10n.truckHeight(Formatters.number(l10n, _t.heightCm / 100, 2)),
          _t.heightCm,
          200,
          450,
          (v) => _t.copyWith(heightCm: v),
        ),
        _slider(
          l10n.truckWidth(Formatters.number(l10n, _t.widthCm / 100, 2)),
          _t.widthCm,
          150,
          300,
          (v) => _t.copyWith(widthCm: v),
        ),
        _slider(
          l10n.truckLength(Formatters.number(l10n, _t.lengthCm / 100, 1)),
          _t.lengthCm,
          400,
          2500,
          (v) => _t.copyWith(lengthCm: v),
        ),
        _slider(
          l10n.truckAxles(_t.axleCount),
          _t.axleCount,
          2,
          8,
          (v) => _t.copyWith(axleCount: v),
        ),
      ],
    );
  }
}
