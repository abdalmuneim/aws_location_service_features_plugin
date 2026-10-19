import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_map_view.dart';
import '../../../../core/presentation/widgets/map_scaffold.dart';
import '../../../../core/presentation/widgets/status_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../injection_container.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../cubit/cloud_tracking_cubit.dart';

/// Sends device positions to an Amazon Location tracker with the plugin's
/// cloud tracking (Amazon Location Mobile SDKs on Android and iOS, Dart on
/// the web) and reads them back from AWS.
class CloudTrackingPage extends StatelessWidget {
  const CloudTrackingPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CloudTrackingCubit(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    )..init(),
    child: const _CloudTrackingView(),
  );
}

class _CloudTrackingView extends StatefulWidget {
  const _CloudTrackingView();

  @override
  State<_CloudTrackingView> createState() => _CloudTrackingViewState();
}

class _CloudTrackingViewState extends State<_CloudTrackingView> {
  static const _historyColor = Color(0xFF7B1FA2);

  final _poolId = TextEditingController();
  final _tracker = TextEditingController();
  AwsMapController? _map;
  bool _follow = true;
  bool _filledForm = false;

  @override
  void dispose() {
    _poolId.dispose();
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = context.select((SettingsCubit c) => c.state.units);
    return BlocConsumer<CloudTrackingCubit, CloudTrackingState>(
      listenWhen: (a, b) =>
          (b.failure != null && a.failure != b.failure) ||
          a.received.length != b.received.length ||
          a.history != b.history ||
          a.latest != b.latest ||
          a.settingsLoaded != b.settingsLoaded,
      listener: (context, s) {
        if (!_filledForm && s.settingsLoaded) {
          // Saved settings arrive once, right after the page opens.
          _filledForm = true;
          _poolId.text = s.config.identityPoolId;
          _tracker.text = s.config.trackerName;
        }
        if (s.failure != null) {
          showSnack(context, s.failure!.localizedMessage(context.l10n));
        }
        final last = s.received.lastOrNull;
        if (_follow && last != null) _map?.moveTo(last.point);
      },
      builder: (context, s) {
        final l10n = context.l10n;
        final cubit = context.read<CloudTrackingCubit>();
        return MapScaffold(
          title: l10n.cloudTrackingTitle,
          loading: s.status.isLoading,
          map: AppMapView(
            initialZoom: 14,
            onMapReady: (c) => _map = c,
            overlay: _overlay(s),
          ),
          mapControls: [
            MapControlButton(
              icon: _follow ? Icons.gps_fixed : Icons.gps_not_fixed,
              tooltip: l10n.trackerFollow,
              selected: _follow,
              onPressed: () => setState(() => _follow = !_follow),
            ),
          ],
          panel: [
            _StatusTile(state: s),
            _setup(context, s, units),
            const SizedBox(height: 8),
            _controls(context, s),
            SectionTitle(l10n.cloudTrackingBackground),
            if (kIsWeb)
              Text(l10n.cloudTrackingBackgroundWeb)
            else
              ..._background(context, s),
            SectionTitle(l10n.cloudTrackingReadBack),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: Text(l10n.cloudTrackingLatest),
                  onPressed: s.connected ? cubit.fetchLatest : null,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.history),
                  label: Text(l10n.cloudTrackingHistory),
                  onPressed: s.connected ? cubit.fetchHistory : null,
                ),
              ],
            ),
            if (s.latest != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_done_outlined),
                title: Text(Formatters.point(s.latest!.point)),
                subtitle: Text(
                  l10n.cloudTrackingLatestValue(
                    Formatters.dateTime(
                      l10n,
                      s.latest!.receivedTime ?? s.latest!.sampleTime,
                    ),
                  ),
                ),
              ),
            if (s.history case final history?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.cloudTrackingHistoryCount(history.length)),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatChip(
                  icon: Icons.sensors,
                  label: l10n.cloudTrackingReceived(s.received.length),
                  color: MapColors.device,
                ),
                StatChip(
                  icon: Icons.cloud_upload_outlined,
                  label: l10n.cloudTrackingUploaded(s.uploaded.length),
                  color: MapColors.origin,
                ),
                StatChip(
                  icon: Icons.filter_alt_outlined,
                  label: l10n.cloudTrackingSkipped(s.skipped),
                ),
                StatChip(
                  icon: Icons.error_outline,
                  label: l10n.cloudTrackingErrors(s.errors),
                  color: s.errors > 0 ? MapColors.destination : null,
                ),
              ],
            ),
            SectionTitle(
              l10n.trackerEvents(s.log.length),
              trailing: s.log.isEmpty
                  ? null
                  : TextButton(
                      onPressed: cubit.clearSession,
                      child: Text(l10n.commonClear),
                    ),
            ),
            for (final e in s.log) _EventTile(event: e),
          ],
        );
      },
    );
  }

  MapOverlay _overlay(CloudTrackingState s) {
    List<GeoPoint> points(List<TrackerPosition> list) => [
      for (final p in list) p.point,
    ];
    final last = s.received.lastOrNull;
    final history = s.history ?? const [];
    return MapOverlay(
      polylines: [
        if (history.length >= 2)
          MapPolyline(
            id: 'history',
            points: points(history),
            color: _historyColor,
            width: 4,
            dashed: true,
          ),
        if (s.received.length >= 2)
          MapPolyline(
            id: 'received',
            points: points(s.received),
            color: MapColors.device,
            width: 3,
            opacity: 0.7,
          ),
      ],
      markers: [
        for (final (i, p) in s.uploaded.indexed)
          MapMarker(
            id: 'uploaded-$i',
            position: p.point,
            color: MapColors.origin,
            radius: 5,
          ),
        if (s.latest != null)
          MapMarker(
            id: 'latest',
            position: s.latest!.point,
            color: _historyColor,
            radius: 9,
            label: 'A',
          ),
        if (last != null)
          MapMarker(
            id: 'device',
            position: last.point,
            color: MapColors.device,
            radius: 10,
          ),
      ],
    );
  }

  Widget _setup(
    BuildContext context,
    CloudTrackingState s,
    MeasurementUnits units,
  ) {
    final l10n = context.l10n;
    final cubit = context.read<CloudTrackingCubit>();
    final c = s.config;
    final seconds = c.minTimeBetweenUploads?.inSeconds;
    final meters = c.minDistanceMeters;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      initiallyExpanded: !s.connected,
      title: Text(l10n.cloudTrackingSetupTitle),
      subtitle: c.trackerName.isEmpty ? null : Text(c.trackerName),
      children: [
        Text(
          l10n.cloudTrackingSetupHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _poolId,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.cloudTrackingIdentityPool,
            hintText: 'eu-north-1:00000000-0000-0000-0000-000000000000',
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateConfig(c.copyWith(identityPoolId: v)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _tracker,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: l10n.cloudTrackingTrackerName,
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => cubit.updateConfig(c.copyWith(trackerName: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.cloudTrackingTimeFilter),
          subtitle: seconds == null
              ? null
              : Text(l10n.cloudTrackingTimeFilterValue(seconds)),
          value: seconds != null,
          onChanged: (on) => cubit.updateConfig(
            on
                ? c.copyWith(minTimeBetweenUploads: const Duration(seconds: 30))
                : c.copyWith(clearTimeFilter: true),
          ),
        ),
        if (seconds != null)
          Slider(
            value: seconds.clamp(5, 300).toDouble(),
            min: 5,
            max: 300,
            divisions: 59,
            label: '$seconds',
            onChanged: (v) => cubit.updateConfig(
              c.copyWith(minTimeBetweenUploads: Duration(seconds: v.round())),
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.cloudTrackingDistanceFilter),
          subtitle: meters == null
              ? null
              : Text(
                  l10n.cloudTrackingDistanceFilterValue(
                    Formatters.distance(l10n, meters, units),
                  ),
                ),
          value: meters != null,
          onChanged: (on) => cubit.updateConfig(
            on
                ? c.copyWith(minDistanceMeters: 30)
                : c.copyWith(clearDistanceFilter: true),
          ),
        ),
        if (meters != null)
          Slider(
            value: meters.clamp(5, 500),
            min: 5,
            max: 500,
            divisions: 99,
            label: Formatters.distance(l10n, meters, units),
            onChanged: (v) => cubit.updateConfig(
              c.copyWith(minDistanceMeters: v.roundToDouble()),
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.cloudTrackingAccuracyFilter),
          subtitle: Text(l10n.cloudTrackingAccuracyFilterHint),
          value: c.accuracyFilter,
          onChanged: (on) => cubit.updateConfig(c.copyWith(accuracyFilter: on)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.icon(
            icon: const Icon(Icons.link),
            label: Text(l10n.cloudTrackingConnect),
            onPressed: s.status.isLoading || s.active ? null : cubit.connect,
          ),
        ),
      ],
    );
  }

  Widget _controls(BuildContext context, CloudTrackingState s) {
    final l10n = context.l10n;
    final cubit = context.read<CloudTrackingCubit>();
    return SizedBox(
      width: double.infinity,
      child: s.tracking
          ? FilledButton.tonalIcon(
              icon: const Icon(Icons.stop),
              label: Text(l10n.trackerStop),
              onPressed: cubit.stop,
            )
          : FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.trackerStart),
              onPressed: s.connected && !s.status.isLoading
                  ? cubit.start
                  : null,
            ),
    );
  }

  List<Widget> _background(BuildContext context, CloudTrackingState s) {
    final l10n = context.l10n;
    final cubit = context.read<CloudTrackingCubit>();
    return [
      SegmentedButton<BackgroundTrackingMode>(
        segments: [
          ButtonSegment(
            value: BackgroundTrackingMode.active,
            icon: const Icon(Icons.bolt),
            label: Text(l10n.cloudTrackingBackgroundActive),
          ),
          ButtonSegment(
            value: BackgroundTrackingMode.batterySaver,
            icon: const Icon(Icons.battery_saver),
            label: Text(l10n.cloudTrackingBackgroundBatterySaver),
          ),
        ],
        selected: {s.backgroundMode},
        onSelectionChanged: s.background
            ? null
            : (v) => cubit.setBackgroundMode(v.first),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.cloudTrackingBackgroundHelp,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: s.background
            ? OutlinedButton.icon(
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n.cloudTrackingBackgroundStop),
                onPressed: cubit.stopBackground,
              )
            : OutlinedButton.icon(
                icon: const Icon(Icons.nights_stay_outlined),
                label: Text(l10n.cloudTrackingBackgroundStart),
                onPressed: s.connected && !s.status.isLoading
                    ? cubit.startBackground
                    : null,
              ),
      ),
    ];
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.state});

  final CloudTrackingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, color, title) = switch (state) {
      CloudTrackingState(background: true) => (
        Icons.cloud_sync,
        MapColors.origin,
        l10n.cloudTrackingStatusBackground,
      ),
      CloudTrackingState(tracking: true) => (
        Icons.cloud_upload,
        MapColors.origin,
        l10n.cloudTrackingStatusTracking,
      ),
      CloudTrackingState(:final deviceId?) => (
        Icons.cloud_done_outlined,
        MapColors.primary,
        l10n.cloudTrackingConnected(deviceId),
      ),
      _ => (
        Icons.cloud_off_outlined,
        Theme.of(context).colorScheme.onSurfaceVariant,
        l10n.cloudTrackingNotConnected,
      ),
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: state.connected
          ? Text(
              '${state.config.trackerName} · ${state.config.region}',
              textDirection: TextDirection.ltr,
            )
          : null,
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final CloudTrackingEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, color, title, detail) = switch (event) {
      TrackingPositionReceived(:final position) => (
        Icons.sensors,
        MapColors.device,
        l10n.cloudTrackingEventPosition,
        Formatters.point(position.point),
      ),
      TrackingUploadStarted(:final positions) => (
        Icons.upload,
        MapColors.primary,
        l10n.cloudTrackingEventUploadStarted(positions.length),
        null,
      ),
      TrackingUploaded(:final positions) => (
        Icons.cloud_done,
        MapColors.origin,
        l10n.cloudTrackingEventUploaded(positions.length),
        null,
      ),
      TrackingUploadSkipped(:final position) => (
        Icons.filter_alt,
        MapColors.alternative,
        l10n.cloudTrackingEventSkipped,
        Formatters.point(position.point),
      ),
      TrackingAvailabilityChanged(:final available) => (
        available ? Icons.location_on : Icons.location_off,
        MapColors.alternative,
        available
            ? l10n.cloudTrackingEventAvailable
            : l10n.cloudTrackingEventUnavailable,
        null,
      ),
      TrackingBackgroundStopped() => (
        Icons.stop_circle_outlined,
        MapColors.alternative,
        l10n.cloudTrackingEventBackgroundStopped,
        null,
      ),
      TrackingErrorEvent(:final message) => (
        Icons.error_outline,
        MapColors.destination,
        l10n.cloudTrackingEventError(message),
        null,
      ),
    };
    final time = Formatters.time(l10n, event.time);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(detail == null ? time : '$time · $detail'),
    );
  }
}
