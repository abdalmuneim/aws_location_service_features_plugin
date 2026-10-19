import 'package:aws_location_service_features/aws_location_service_features.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements CloudTrackingRepository {
  CloudTrackerConfig? configured;

  @override
  Future<Result<String>> configure(CloudTrackerConfig config) async {
    configured = config;
    return const Ok('device');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Repo repo;
  late ConfigureCloudTracker configure;

  setUp(() {
    repo = _Repo();
    configure = ConfigureCloudTracker(repo);
  });

  Future<Failure?> failureFor(String poolId, String tracker) async =>
      (await configure(
        CloudTrackerConfig(identityPoolId: poolId, trackerName: tracker),
      )).failureOrNull;

  test('both fields are required', () async {
    expect(
      (await failureFor('', 'studio'))?.code,
      FailureCode.trackerConfigIncomplete,
    );
    expect(
      (await failureFor('eu-north-1:x', '  '))?.code,
      FailureCode.trackerConfigIncomplete,
    );
    expect(repo.configured, isNull);
  });

  test('the pool id must be region:uuid', () async {
    expect(
      (await failureFor('my-pool', 'studio'))?.code,
      FailureCode.identityPoolIdInvalid,
    );
    expect(
      (await failureFor('eu-north-1:not-a-uuid', 'studio'))?.code,
      FailureCode.identityPoolIdInvalid,
    );
  });

  test('valid settings are trimmed and passed on', () async {
    final result = await configure(
      const CloudTrackerConfig(
        identityPoolId: ' us-east-1:1234abcd-0000-4000-8000-1234567890ab ',
        trackerName: ' studio ',
      ),
    );
    expect(result.valueOrNull, 'device');
    expect(
      repo.configured?.identityPoolId,
      'us-east-1:1234abcd-0000-4000-8000-1234567890ab',
    );
    expect(repo.configured?.trackerName, 'studio');
    expect(repo.configured?.region, 'us-east-1');
  });
}
