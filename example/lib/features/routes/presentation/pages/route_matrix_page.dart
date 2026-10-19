import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/json_viewer.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../places/presentation/pages/location_picker_page.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/matrix_cubit.dart';
import '../widgets/route_controls.dart';

/// CalculateRouteMatrix: time & distance between many origins and
/// destinations in a single request.
class RouteMatrixPage extends StatelessWidget {
  const RouteMatrixPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => MatrixCubit(sl()),
    child: const _MatrixView(),
  );
}

class _MatrixView extends StatefulWidget {
  const _MatrixView();

  @override
  State<_MatrixView> createState() => _MatrixViewState();
}

class _MatrixViewState extends State<_MatrixView> {
  AwsMapController? _map;

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocBuilder<MatrixCubit, MatrixState>(
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<MatrixCubit>();
        return MapScaffold(
          title: l10n.routeMatrixTitle,
          loading: s.status.isLoading,
          actions: [
            IconButton(
              tooltip: l10n.commonClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: cubit.clear,
            ),
          ],
          map: AppMapView(
            onMapReady: (c) => _map = c,
            onTap: cubit.addPoint,
            overlay: MapOverlay(
              markers: [
                for (final (i, o) in s.origins.indexed)
                  MapMarker(
                    id: 'o$i',
                    position: o.point,
                    color: MapColors.origin,
                    label: 'O${i + 1}',
                    radius: 12,
                  ),
                for (final (i, d) in s.destinations.indexed)
                  MapMarker(
                    id: 'd$i',
                    position: d.point,
                    color: MapColors.destination,
                    label: 'D${i + 1}',
                    radius: 12,
                  ),
              ],
            ),
          ),
          mapBanner: MapHint(
            s.addingOrigins
                ? l10n.matrixTapOrigins
                : l10n.matrixTapDestinations,
          ),
          panel: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.trip_origin),
                  label: Text(l10n.matrixAddOrigins),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.place),
                  label: Text(l10n.matrixAddDestinations),
                ),
              ],
              selected: {s.addingOrigins},
              onSelectionChanged: (v) => cubit.setAddingOrigins(v.first),
            ),
            _list(context, s, origin: true),
            _list(context, s, origin: false),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: TravelModeSelector(
                value: s.travelMode,
                onChanged: cubit.setTravelMode,
              ),
            ),
            if (s.travelMode != TravelMode.pedestrian) ...[
              const SizedBox(height: 8),
              OptimizationSelector(
                value: s.optimizeFor,
                onChanged: cubit.setOptimization,
              ),
              SectionTitle(l10n.routeAvoid),
              AvoidChips(value: s.avoid, onChanged: cubit.setAvoid),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.grid_on),
              label: Text(
                l10n.matrixCalculate(s.origins.length, s.destinations.length),
              ),
              onPressed:
                  s.origins.isEmpty ||
                      s.destinations.isEmpty ||
                      s.status.isLoading
                  ? null
                  : () async {
                      await cubit.calculate();
                      _map?.fitPoints([
                        for (final o in s.origins) o.point,
                        for (final d in s.destinations) d.point,
                      ]);
                    },
            ),
            if (s.failure != null) FailureBanner(failure: s.failure!),
            if (s.result != null) ...[
              SectionTitle(
                s.result!.errorCount > 0
                    ? '${l10n.commonResults} · '
                          '${l10n.matrixErrorsCount(s.result!.errorCount)}'
                    : l10n.commonResults,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  columns: [
                    const DataColumn(label: Text('')),
                    for (var j = 0; j < s.destinations.length; j++)
                      DataColumn(label: Text('D${j + 1}')),
                  ],
                  rows: [
                    for (final (i, row) in s.result!.rows.indexed)
                      DataRow(
                        cells: [
                          DataCell(Text('O${i + 1}')),
                          for (final cell in row)
                            DataCell(
                              cell.error != null
                                  ? Tooltip(
                                      message: cell.error!,
                                      child: const Icon(Icons.block, size: 18),
                                    )
                                  : Text(
                                      '${Formatters.duration(l10n, cell.duration)}\n'
                                      '${Formatters.distance(l10n, cell.distance, units)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              JsonViewer(
                data: s.result!.raw,
                title: l10n.commonApiResponse('CalculateRouteMatrix'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _list(BuildContext context, MatrixState s, {required bool origin}) {
    final l10n = context.l10n;
    final cubit = context.read<MatrixCubit>();
    final items = origin ? s.origins : s.destinations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          origin
              ? l10n.matrixOrigins(items.length)
              : l10n.matrixDestinations(items.length),
          trailing: TextButton.icon(
            icon: const Icon(Icons.search, size: 18),
            label: Text(l10n.commonSearch),
            onPressed: () async {
              final l = await pickLocation(
                context,
                title: origin
                    ? l10n.matrixAddOrigin
                    : l10n.matrixAddDestination,
                center: _map?.center,
              );
              if (l != null) cubit.add(l, origin: origin);
            },
          ),
        ),
        for (final (i, l) in items.indexed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: origin
                  ? MapColors.origin
                  : MapColors.destination,
              child: Text(
                '${origin ? 'O' : 'D'}${i + 1}',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
            title: Text(l.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => cubit.remove(i, origin: origin),
            ),
          ),
      ],
    );
  }
}
