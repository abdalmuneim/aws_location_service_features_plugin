import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/cloud_tracking.dart';
import '../repositories/cloud_tracking_repository.dart';

/// Validates the settings, then signs in and prepares the tracker. Returns
/// this device's tracker id.
class ConfigureCloudTracker implements UseCase<String, CloudTrackerConfig> {
  const ConfigureCloudTracker(this._repository);

  final CloudTrackingRepository _repository;

  static final _poolId = RegExp(
    r'^[a-z]{2}(-[a-z]+)+-\d:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  Future<Result<String>> call(CloudTrackerConfig params) async {
    final poolId = params.identityPoolId.trim();
    final tracker = params.trackerName.trim();
    if (poolId.isEmpty || tracker.isEmpty) {
      return const Err(
        ValidationFailure(
          'Enter an identity pool id and a tracker name.',
          code: FailureCode.trackerConfigIncomplete,
        ),
      );
    }
    if (!_poolId.hasMatch(poolId)) {
      return const Err(
        ValidationFailure(
          'The identity pool id should look like "region:uuid".',
          code: FailureCode.identityPoolIdInvalid,
        ),
      );
    }
    return _repository.configure(
      params.copyWith(identityPoolId: poolId, trackerName: tracker),
    );
  }
}

class StartCloudTracking implements UseCase<void, NoParams> {
  const StartCloudTracking(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.start();
}

class StopCloudTracking implements UseCase<void, NoParams> {
  const StopCloudTracking(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.stop();
}

class StartBackgroundTracking implements UseCase<void, BackgroundTrackingMode> {
  const StartBackgroundTracking(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<void>> call(BackgroundTrackingMode params) =>
      _repository.startBackground(params);
}

class StopBackgroundTracking implements UseCase<void, NoParams> {
  const StopBackgroundTracking(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.stopBackground();
}

class GetTrackerPosition implements UseCase<TrackerPosition?, NoParams> {
  const GetTrackerPosition(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<TrackerPosition?>> call(NoParams params) =>
      _repository.latestPosition();
}

class TrackerHistoryParams extends Equatable {
  const TrackerHistoryParams({this.from, this.to, this.maxResults = 100});

  final DateTime? from;
  final DateTime? to;
  final int? maxResults;

  @override
  List<Object?> get props => [from, to, maxResults];
}

class GetTrackerHistory
    implements UseCase<List<TrackerPosition>, TrackerHistoryParams> {
  const GetTrackerHistory(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Future<Result<List<TrackerPosition>>> call(TrackerHistoryParams params) =>
      _repository.positionHistory(
        from: params.from,
        to: params.to,
        maxResults: params.maxResults,
      );
}

/// Positions, uploads and errors while tracking runs.
class WatchCloudTracking
    implements StreamUseCase<CloudTrackingEvent, NoParams> {
  const WatchCloudTracking(this._repository);

  final CloudTrackingRepository _repository;

  @override
  Stream<CloudTrackingEvent> call(NoParams params) => _repository.events;
}
