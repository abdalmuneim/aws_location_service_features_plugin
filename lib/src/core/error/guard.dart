import 'package:flutter/foundation.dart';

import '../result/result.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Runs [action] and converts data-layer exceptions into [Failure]s.
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on ServerException catch (e) {
    return Err(_mapServer(e));
  } on NetworkException catch (e) {
    return Err(NetworkFailure(e.message, code: e.code, args: e.args));
  } on LocationPermissionException catch (e) {
    return Err(PermissionFailure(e.message, code: e.code, args: e.args));
  } on CacheException catch (e) {
    return Err(CacheFailure(e.message, code: e.code, args: e.args));
  } on TrackingException catch (e) {
    return Err(TrackingFailure(e.message, code: e.code, args: e.args));
  } catch (e, s) {
    debugPrint('Unexpected error: $e\n$s');
    return Err(UnexpectedFailure(e.toString()));
  }
}

Failure _mapServer(ServerException e) {
  switch (e.statusCode) {
    case 401:
    case 403:
      return e.signed
          ? AuthFailure(
              'The AWS credentials were rejected (${e.statusCode}): '
              '${e.message} Check the identity pool role\'s permissions.',
              code: FailureCode.credentialsRejected,
              args: {'status': e.statusCode, 'detail': e.message},
            )
          : AuthFailure(
              'The API key was rejected (${e.statusCode}): ${e.message} '
              'Check the key, its region and its allowed actions.',
              code: FailureCode.apiKeyRejected,
              args: {'status': e.statusCode, 'detail': e.message},
            );
    case 400:
    case 422:
      return ValidationFailure(
        e.message,
        code: e.code,
        args: e.args,
        fieldErrors: e.fieldErrors,
      );
    case 404:
      return ServerFailure(
        'Not found: ${e.message}',
        code: FailureCode.notFound,
        args: {'detail': e.message},
        statusCode: 404,
      );
    case 429:
      return const ServerFailure(
        'Too many requests. Wait a moment and try again.',
        code: FailureCode.tooManyRequests,
        statusCode: 429,
      );
    default:
      return ServerFailure(
        e.message,
        code: e.code,
        args: e.args,
        statusCode: e.statusCode,
      );
  }
}
