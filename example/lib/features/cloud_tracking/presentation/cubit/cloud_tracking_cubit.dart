import 'dart:async';

import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/load_status.dart';
import '../../domain/usecases/cloud_tracker_settings_usecases.dart';

class CloudTrackingState extends Equatable {
  const CloudTrackingState({
    this.config = const CloudTrackerConfig(identityPoolId: '', trackerName: ''),
    this.settingsLoaded = false,
    this.deviceId,
    this.tracking = false,
    this.background = false,
    this.backgroundMode = BackgroundTrackingMode.active,
    this.received = const [],
    this.uploaded = const [],
    this.skipped = 0,
    this.errors = 0,
    this.log = const [],
    this.latest,
    this.history,
    this.status = LoadStatus.idle,
    this.failure,
  });

  /// The settings being edited; applied by `connect`.
  final CloudTrackerConfig config;

  /// True once the saved settings have been read.
  final bool settingsLoaded;

  /// Set once the tracker is configured.
  final String? deviceId;
  final bool tracking;
  final bool background;
  final BackgroundTrackingMode backgroundMode;

  /// Positions the SDK received from the device, oldest first.
  final List<TrackerPosition> received;

  /// Positions the tracker stored, oldest first.
  final List<TrackerPosition> uploaded;
  final int skipped;
  final int errors;

  /// Newest first.
  final List<CloudTrackingEvent> log;

  /// Read back from the tracker (GetDevicePosition).
  final TrackerPosition? latest;

  /// Read back from the tracker (GetDevicePositionHistory), oldest first;
  /// null until fetched.
  final List<TrackerPosition>? history;
  final LoadStatus status;
  final Failure? failure;

  bool get connected => deviceId != null;

  bool get active => tracking || background;

  CloudTrackingState copyWith({
    CloudTrackerConfig? config,
    bool? settingsLoaded,
    String? deviceId,
    bool clearDevice = false,
    bool? tracking,
    bool? background,
    BackgroundTrackingMode? backgroundMode,
    List<TrackerPosition>? received,
    List<TrackerPosition>? uploaded,
    int? skipped,
    int? errors,
    List<CloudTrackingEvent>? log,
    TrackerPosition? latest,
    List<TrackerPosition>? history,
    bool clearHistory = false,
    LoadStatus? status,
    Failure? failure,
  }) => CloudTrackingState(
    config: config ?? this.config,
    settingsLoaded: settingsLoaded ?? this.settingsLoaded,
    deviceId: clearDevice ? null : deviceId ?? this.deviceId,
    tracking: tracking ?? this.tracking,
    background: background ?? this.background,
    backgroundMode: backgroundMode ?? this.backgroundMode,
    received: received ?? this.received,
    uploaded: uploaded ?? this.uploaded,
    skipped: skipped ?? this.skipped,
    errors: errors ?? this.errors,
    log: log ?? this.log,
    latest: latest ?? this.latest,
    history: clearHistory ? null : history ?? this.history,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    config,
    settingsLoaded,
    deviceId,
    tracking,
    background,
    backgroundMode,
    received,
    uploaded,
    skipped,
    errors,
    log,
    latest,
    history,
    status,
    failure,
  ];
}

/// Sends device positions to an Amazon Location tracker through the
/// plugin's cloud tracking (Amazon Location Mobile SDKs on Android and iOS,
/// Dart on the web) and reads them back.
class CloudTrackingCubit extends Cubit<CloudTrackingState> {
  CloudTrackingCubit(
    this._loadSettings,
    this._saveSettings,
    this._configure,
    this._start,
    this._stop,
    this._startBackground,
    this._stopBackground,
    this._latest,
    this._history,
    this._watch,
  ) : super(const CloudTrackingState());

  final LoadCloudTrackerSettings _loadSettings;
  final SaveCloudTrackerSettings _saveSettings;
  final ConfigureCloudTracker _configure;
  final StartCloudTracking _start;
  final StopCloudTracking _stop;
  final StartBackgroundTracking _startBackground;
  final StopBackgroundTracking _stopBackground;
  final GetTrackerPosition _latest;
  final GetTrackerHistory _history;
  final WatchCloudTracking _watch;

  static const _maxPoints = 500;
  static const _maxLog = 60;

  StreamSubscription<CloudTrackingEvent>? _events;

  Future<void> init() async {
    final saved = await _loadSettings(const NoParams());
    if (isClosed) return;
    emit(state.copyWith(config: saved.valueOrNull, settingsLoaded: true));
    _events = _watch(const NoParams()).listen(_onEvent);
  }

  void updateConfig(CloudTrackerConfig config) =>
      emit(state.copyWith(config: config));

  void setBackgroundMode(BackgroundTrackingMode mode) =>
      emit(state.copyWith(backgroundMode: mode));

  /// Saves the settings, signs in to the identity pool and prepares the
  /// tracker.
  Future<void> connect() async {
    emit(state.copyWith(status: LoadStatus.loading));
    await _saveSettings(state.config);
    final result = await _configure(state.config);
    if (isClosed) return;
    result.fold(
      (f) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          failure: f,
          clearDevice: true,
          tracking: false,
          background: false,
        ),
      ),
      (deviceId) => emit(
        state.copyWith(
          status: LoadStatus.success,
          deviceId: deviceId,
          tracking: false,
          background: false,
        ),
      ),
    );
  }

  Future<void> start() => _run(_start(const NoParams()), tracking: true);

  Future<void> stop() => _run(_stop(const NoParams()), tracking: false);

  Future<void> startBackground() =>
      _run(_startBackground(state.backgroundMode), background: true);

  Future<void> stopBackground() =>
      _run(_stopBackground(const NoParams()), background: false);

  Future<void> fetchLatest() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _latest(const NoParams());
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (p) => emit(state.copyWith(status: LoadStatus.success, latest: p)),
    );
  }

  /// The last 24 hours stored by the tracker.
  Future<void> fetchHistory() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final now = DateTime.now();
    final result = await _history(
      TrackerHistoryParams(
        from: now.subtract(const Duration(hours: 24)),
        to: now.add(const Duration(minutes: 1)),
        maxResults: _maxPoints,
      ),
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (h) => emit(state.copyWith(status: LoadStatus.success, history: h)),
    );
  }

  void clearSession() => emit(
    state.copyWith(
      received: const [],
      uploaded: const [],
      skipped: 0,
      errors: 0,
      log: const [],
      clearHistory: true,
    ),
  );

  Future<void> _run(
    Future<Result<void>> call, {
    bool? tracking,
    bool? background,
  }) async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await call;
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: LoadStatus.failure, failure: f)),
      (_) => emit(
        state.copyWith(
          status: LoadStatus.success,
          tracking: tracking,
          background: background,
        ),
      ),
    );
  }

  void _onEvent(CloudTrackingEvent event) {
    final log = [event, ...state.log.take(_maxLog - 1)];
    List<TrackerPosition> add(
      List<TrackerPosition> list,
      Iterable<TrackerPosition> more,
    ) {
      final all = [...list, ...more];
      return all.length > _maxPoints
          ? all.sublist(all.length - _maxPoints)
          : all;
    }

    emit(switch (event) {
      TrackingPositionReceived(:final position) => state.copyWith(
        log: log,
        received: add(state.received, [position]),
      ),
      TrackingUploaded(:final positions) => state.copyWith(
        log: log,
        uploaded: add(state.uploaded, positions),
      ),
      TrackingUploadSkipped() => state.copyWith(
        log: log,
        skipped: state.skipped + 1,
      ),
      TrackingErrorEvent() => state.copyWith(
        log: log,
        errors: state.errors + 1,
      ),
      TrackingBackgroundStopped() => state.copyWith(
        log: log,
        background: false,
      ),
      TrackingUploadStarted() ||
      TrackingAvailabilityChanged() => state.copyWith(log: log),
    });
  }

  @override
  Future<void> close() async {
    await _events?.cancel();
    return super.close();
  }
}
