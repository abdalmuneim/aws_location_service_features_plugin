import '../../../../core/error/exceptions.dart';
import '../../../../core/network/aws_signed_http_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/cloud_tracking.dart';

/// Amazon Location tracker APIs over REST (SigV4-signed): the web's
/// equivalent of what the mobile Tracking SDKs do natively.
class TrackerRemoteDataSource {
  TrackerRemoteDataSource(this._client, {required this.trackerName});

  final AwsSignedHttpClient _client;
  final String trackerName;

  /// BatchUpdateDevicePosition accepts at most 10 updates per call.
  static const maxBatch = 10;

  String get _tracker => Uri.encodeComponent(trackerName);

  /// Sends up to [maxBatch] positions. Throws when the tracker rejects any
  /// of them, so the caller can keep them queued.
  Future<void> batchUpdate(
    String deviceId,
    List<TrackerPosition> positions,
  ) async {
    assert(positions.length <= maxBatch);
    final json = await _client.postJson(
      _client.uri('tracking', '/tracking/v0/trackers/$_tracker/positions'),
      {
        'Updates': [
          for (final p in positions)
            {
              'DeviceId': deviceId,
              'Position': JsonUtils.position(p.point),
              'SampleTime': p.sampleTime.toUtc().toIso8601String(),
              if (p.accuracyMeters != null)
                'Accuracy': {'Horizontal': p.accuracyMeters},
            },
        ],
      },
    );
    final errors = JsonUtils.mapList(json['Errors']);
    if (errors.isNotEmpty) {
      final error = JsonUtils.map(errors.first['Error']);
      final detail = '${error['Code'] ?? ''}: ${error['Message'] ?? ''}';
      throw TrackingException(
        'The tracker rejected ${errors.length} position(s): $detail',
        code: FailureCode.trackingPlatformError,
        args: {'detail': detail},
      );
    }
  }

  /// GetDevicePosition; null when the tracker has nothing for the device.
  Future<TrackerPosition?> latest(String deviceId) async {
    try {
      final json = await _client.getJson(
        _client.uri(
          'tracking',
          '/tracking/v0/trackers/$_tracker/devices/'
              '${Uri.encodeComponent(deviceId)}/positions/latest',
        ),
      );
      return parsePosition(json);
    } on ServerException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// GetDevicePositionHistory, following NextToken until [maxResults]
  /// positions (or all of them when null) are collected.
  Future<List<TrackerPosition>> history(
    String deviceId, {
    DateTime? from,
    DateTime? to,
    int? maxResults,
  }) async {
    final out = <TrackerPosition>[];
    String? next;
    do {
      final remaining = maxResults == null ? 100 : maxResults - out.length;
      final json = await _client.postJson(
        _client.uri(
          'tracking',
          '/tracking/v0/trackers/$_tracker/devices/'
              '${Uri.encodeComponent(deviceId)}/list-positions',
        ),
        {
          'StartTimeInclusive': from?.toUtc().toIso8601String(),
          'EndTimeExclusive': to?.toUtc().toIso8601String(),
          'MaxResults': remaining.clamp(1, 100),
          'NextToken': next,
        },
      );
      for (final item in JsonUtils.mapList(json['DevicePositions'])) {
        final position = parsePosition(item);
        if (position != null) out.add(position);
      }
      next = JsonUtils.string(json['NextToken']);
    } while (next != null && (maxResults == null || out.length < maxResults));
    return out;
  }

  /// Reads a DevicePosition JSON object.
  static TrackerPosition? parsePosition(Map<String, dynamic> json) {
    final point = JsonUtils.parsePosition(json['Position']);
    final sampled = DateTime.tryParse('${json['SampleTime'] ?? ''}');
    if (point == null || sampled == null) return null;
    return TrackerPosition(
      point: point,
      sampleTime: sampled,
      deviceId: JsonUtils.string(json['DeviceId']),
      receivedTime: DateTime.tryParse('${json['ReceivedTime'] ?? ''}'),
      accuracyMeters: JsonUtils.toDouble(
        JsonUtils.map(json['Accuracy'])['Horizontal'],
      ),
    );
  }
}
