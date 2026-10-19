import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/cognito_credentials_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/aws_signed_http_client.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../../platform/aws_location_platform.dart';
import '../../domain/entities/cloud_tracking.dart';
import '../../domain/entities/device_position.dart';
import 'device_location_data_source.dart';
import 'tracker_remote_data_source.dart';

/// Cloud tracking in pure Dart: Cognito credentials, SigV4-signed
/// BatchUpdateDevicePosition calls and positions from
/// [DeviceLocationDataSource] (browser geolocation on the web).
///
/// It mirrors the mobile Tracking SDKs: positions pass the time, distance
/// and accuracy filters, are queued, and are sent in batches of up to 10;
/// failed uploads stay queued and are retried with the next position.
/// Background tracking is not available.
class DartCloudTracker extends AwsLocationPlatform {
  DartCloudTracker({
    http.Client? httpClient,
    DeviceLocationDataSource? location,
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? clock,
  }) : _http = httpClient ?? http.Client(),
       _location = location ?? const GeolocatorDataSource(),
       _preferences = preferences ?? SharedPreferences.getInstance,
       _clock = clock ?? DateTime.now;

  final http.Client _http;
  final DeviceLocationDataSource _location;
  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _clock;

  static const _deviceIdKey = 'aws_location_service_features.device_id';

  final _events = StreamController<CloudTrackingEvent>.broadcast();
  final _queue = <TrackerPosition>[];

  CloudTrackerConfig? _config;
  TrackerRemoteDataSource? _remote;
  String? _deviceId;
  StreamSubscription<DevicePosition>? _watch;
  TrackerPosition? _lastAccepted;
  bool _uploading = false;

  @override
  Stream<CloudTrackingEvent> get trackingEvents => _events.stream;

  /// Positions waiting to be uploaded.
  @visibleForTesting
  List<TrackerPosition> get queued => List.unmodifiable(_queue);

  @override
  Future<String> configureTracker(CloudTrackerConfig config) async {
    await stopTracking();
    final cognito = CognitoCredentialsProvider(
      identityPoolId: config.identityPoolId,
      httpClient: _http,
      preferences: _preferences,
      clock: _clock,
    );
    // Sign in now so a wrong pool id fails here, not at the first upload.
    await cognito.credentials();
    _remote = TrackerRemoteDataSource(
      AwsSignedHttpClient(
        httpClient: _http,
        region: config.region,
        credentials: cognito.credentials,
        clock: _clock,
      ),
      trackerName: config.trackerName,
    );
    _config = config;
    _queue.clear();
    _lastAccepted = null;
    return _deviceId = await _loadDeviceId();
  }

  @override
  Future<void> startTracking() async {
    _requireConfigured();
    if (_watch != null) return;
    _watch = _location
        .watch(0)
        .listen(
          onPosition,
          onError: (Object e) => _emit(TrackingErrorEvent(_clock(), '$e')),
        );
  }

  @override
  Future<void> stopTracking() async {
    await _watch?.cancel();
    _watch = null;
  }

  @override
  Future<void> startBackgroundTracking(BackgroundTrackingMode mode) async {
    throw const TrackingException(
      'Background tracking is not available on the web.',
      code: FailureCode.backgroundTrackingUnsupported,
    );
  }

  @override
  Future<void> stopBackgroundTracking() async {}

  @override
  Future<bool> isTracking() async => _watch != null;

  @override
  Future<TrackerPosition?> latestPosition() {
    final remote = _requireConfigured();
    return remote.latest(_deviceId!);
  }

  @override
  Future<List<TrackerPosition>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  }) {
    final remote = _requireConfigured();
    return remote.history(
      _deviceId!,
      from: from,
      to: to,
      maxResults: maxResults,
    );
  }

  /// Handles one device position: filter, queue, upload.
  @visibleForTesting
  Future<void> onPosition(DevicePosition device) async {
    final config = _config;
    if (config == null) return;
    final position = TrackerPosition(
      point: device.point,
      sampleTime: device.timestamp.toUtc(),
      accuracyMeters: device.accuracyMeters,
      deviceId: _deviceId,
    );
    _emit(TrackingPositionReceived(_clock(), position));
    if (!passesFilters(config, position, _lastAccepted)) {
      _emit(TrackingUploadSkipped(_clock(), position));
      return;
    }
    _lastAccepted = position;
    _queue.add(position);
    await _flush();
  }

  /// The SDKs' filters, applied against the last accepted position.
  @visibleForTesting
  static bool passesFilters(
    CloudTrackerConfig config,
    TrackerPosition current,
    TrackerPosition? previous,
  ) {
    if (previous == null) return true;
    final minTime = config.minTimeBetweenUploads;
    if (minTime != null &&
        current.sampleTime.difference(previous.sampleTime) <= minTime) {
      return false;
    }
    final moved = GeoUtils.distance(previous.point, current.point);
    final minDistance = config.minDistanceMeters;
    if (minDistance != null && moved <= minDistance) return false;
    final accuracy = current.accuracyMeters;
    if (config.accuracyFilter && accuracy != null && moved <= accuracy) {
      return false;
    }
    return true;
  }

  Future<void> _flush() async {
    final remote = _remote;
    if (_uploading || remote == null) return;
    _uploading = true;
    try {
      while (_queue.isNotEmpty) {
        final batch = _queue
            .take(TrackerRemoteDataSource.maxBatch)
            .toList(growable: false);
        _emit(TrackingUploadStarted(_clock(), batch));
        await remote.batchUpdate(_deviceId!, batch);
        _queue.removeRange(0, batch.length);
        _emit(TrackingUploaded(_clock(), batch));
      }
    } catch (e) {
      // Keep the queue; the next position triggers another attempt.
      _emit(TrackingErrorEvent(_clock(), _describe(e)));
    } finally {
      _uploading = false;
    }
  }

  TrackerRemoteDataSource _requireConfigured() {
    final remote = _remote;
    if (remote == null || _deviceId == null) {
      throw const TrackingException(
        'Call configure before using the tracker.',
        code: FailureCode.trackerNotConfigured,
      );
    }
    return remote;
  }

  Future<String> _loadDeviceId() async {
    final prefs = await _preferences();
    final saved = prefs.getString(_deviceIdKey);
    if (saved != null && saved.isNotEmpty) return saved;
    final id = _uuidV4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  void _emit(CloudTrackingEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  static String _describe(Object e) => switch (e) {
    ServerException(:final statusCode, :final message) =>
      'HTTP $statusCode: $message',
    NetworkException(:final message) => message,
    TrackingException(:final message) => message,
    _ => '$e',
  };

  static String _uuidV4() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
