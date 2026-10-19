import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/device_position.dart';
import '../../domain/repositories/device_location_repository.dart';
import '../datasources/device_location_data_source.dart';

class DeviceLocationRepositoryImpl implements DeviceLocationRepository {
  const DeviceLocationRepositoryImpl(this._source);

  final DeviceLocationDataSource _source;

  @override
  Future<Result<DevicePosition>> currentPosition() => guard(_source.current);

  @override
  Stream<Result<DevicePosition>> watchPosition({
    int distanceFilterMeters = 5,
  }) => _source
      .watch(distanceFilterMeters)
      .transform(
        StreamTransformer<DevicePosition, Result<DevicePosition>>.fromHandlers(
          handleData: (position, sink) => sink.add(Ok(position)),
          handleError: (error, _, sink) => sink.add(
            Err(
              error is LocationPermissionException
                  ? PermissionFailure(
                      error.message,
                      code: error.code,
                      args: error.args,
                    )
                  : UnexpectedFailure('$error'),
            ),
          ),
        ),
      );
}
