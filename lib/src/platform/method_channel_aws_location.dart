import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/entities/geo_point.dart';
import '../core/error/exceptions.dart';
import '../features/tracking/domain/entities/cloud_tracking.dart';
import 'aws_location_platform.dart';

/// Android and iOS implementation, talking to the native plugin classes
/// (`AwsLocationServiceFeaturesPlugin`) that wrap the Amazon Location Mobile SDKs.
///
/// Wire format: dates are milliseconds since the epoch (UTC); positions are
/// maps with `latitude`, `longitude`, `sampleTime` and optional
/// `receivedTime`, `accuracy` and `deviceId`.
class MethodChannelAwsLocation extends AwsLocationPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('aws_location_service_features/tracking');

  @visibleForTesting
  final eventChannel = const EventChannel(
    'aws_location_service_features/tracking/events',
  );

  late final Stream<CloudTrackingEvent> _events = eventChannel
      .receiveBroadcastStream()
      .map((e) => decodeEvent(Map<Object?, Object?>.from(e as Map)))
      .where((e) => e != null)
      .cast<CloudTrackingEvent>()
      .asBroadcastStream();

  @override
  Stream<CloudTrackingEvent> get trackingEvents => _events;

  @override
  Future<String> configureTracker(CloudTrackerConfig config) async {
    final deviceId = await _invoke<String>('configure', {
      'identityPoolId': config.identityPoolId,
      'region': config.region,
      'trackerName': config.trackerName,
      'timeFilterMillis': config.minTimeBetweenUploads?.inMilliseconds,
      'distanceFilterMeters': config.minDistanceMeters,
      'accuracyFilter': config.accuracyFilter,
      'notification': config.notification.toMap(),
    });
    return deviceId ?? '';
  }

  @override
  Future<void> startTracking() => _invoke<void>('start');

  @override
  Future<void> stopTracking() => _invoke<void>('stop');

  @override
  Future<void> startBackgroundTracking(BackgroundTrackingMode mode) =>
      _invoke<void>('startBackground', {'mode': mode.name});

  @override
  Future<void> stopBackgroundTracking() => _invoke<void>('stopBackground');

  @override
  Future<bool> isTracking() async => await _invoke<bool>('isTracking') ?? false;

  @override
  Future<TrackerPosition?> latestPosition() async {
    final map = await _invoke<Map<Object?, Object?>>('latestPosition');
    return map == null ? null : decodePosition(map);
  }

  @override
  Future<List<TrackerPosition>> positionHistory({
    DateTime? from,
    DateTime? to,
    int? maxResults,
  }) async {
    final list = await _invoke<List<Object?>>('positionHistory', {
      'from': from?.millisecondsSinceEpoch,
      'to': to?.millisecondsSinceEpoch,
      'maxResults': maxResults,
    });
    return [
      for (final item in list ?? const [])
        if (item is Map) ?decodePosition(item),
    ];
  }

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await methodChannel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw mapPlatformException(e);
    } on MissingPluginException {
      throw const TrackingException(
        'Cloud tracking is not available on this platform.',
        code: FailureCode.trackingPlatformError,
        args: {'detail': 'MissingPluginException'},
      );
    }
  }

  /// Native error codes → the plugin's exceptions.
  @visibleForTesting
  static Exception mapPlatformException(PlatformException e) {
    final detail = e.message ?? e.code;
    return switch (e.code) {
      'NOT_CONFIGURED' => TrackingException(
        'Call configure before using the tracker.',
        code: FailureCode.trackerNotConfigured,
      ),
      'PERMISSION_DENIED' => LocationPermissionException(
        'Location permission denied.',
        code: FailureCode.locationPermissionDenied,
      ),
      'AUTH_FAILED' => TrackingException(
        'Cognito sign-in failed: $detail',
        code: FailureCode.cognitoSignInFailed,
        args: {'detail': detail},
      ),
      'ACCESS_DENIED' => ServerException(
        statusCode: 403,
        message: detail,
        signed: true,
      ),
      'UNSUPPORTED' => TrackingException(
        detail,
        code: FailureCode.backgroundTrackingUnsupported,
      ),
      _ => TrackingException(
        'Tracking error: $detail',
        code: FailureCode.trackingPlatformError,
        args: {'detail': detail},
      ),
    };
  }

  @visibleForTesting
  static TrackerPosition? decodePosition(Map<Object?, Object?> map) {
    final lat = map['latitude'], lng = map['longitude'];
    final sampled = map['sampleTime'];
    if (lat is! num || lng is! num || sampled is! num) return null;
    final received = map['receivedTime'];
    final accuracy = map['accuracy'];
    return TrackerPosition(
      point: GeoPoint(lat.toDouble(), lng.toDouble()),
      sampleTime: DateTime.fromMillisecondsSinceEpoch(
        sampled.toInt(),
        isUtc: true,
      ),
      receivedTime: received is num
          ? DateTime.fromMillisecondsSinceEpoch(received.toInt(), isUtc: true)
          : null,
      accuracyMeters: accuracy is num ? accuracy.toDouble() : null,
      deviceId: map['deviceId'] as String?,
    );
  }

  @visibleForTesting
  static CloudTrackingEvent? decodeEvent(Map<Object?, Object?> map) {
    final millis = map['time'];
    final time = millis is num
        ? DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: true)
        : DateTime.now().toUtc();
    TrackerPosition? position() {
      final p = map['position'];
      return p is Map ? decodePosition(p) : null;
    }

    List<TrackerPosition> positions() => [
      for (final p in map['positions'] as List? ?? const [])
        if (p is Map) ?decodePosition(p),
    ];

    switch (map['type']) {
      case 'position':
        final p = position();
        return p == null ? null : TrackingPositionReceived(time, p);
      case 'uploadStarted':
        return TrackingUploadStarted(time, positions());
      case 'uploaded':
        return TrackingUploaded(time, positions());
      case 'uploadSkipped':
        final p = position();
        return p == null ? null : TrackingUploadSkipped(time, p);
      case 'availability':
        return TrackingAvailabilityChanged(
          time,
          available: map['available'] == true,
        );
      case 'backgroundStopped':
        return TrackingBackgroundStopped(time);
      case 'error':
        return TrackingErrorEvent(time, '${map['message'] ?? ''}');
      default:
        return null;
    }
  }
}
