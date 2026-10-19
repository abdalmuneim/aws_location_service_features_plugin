import '../result/result.dart';

/// A single application action. Use cases depend only on domain
/// repositories and entities.
abstract interface class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

/// A use case that emits a stream of values.
abstract interface class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

class NoParams {
  const NoParams();
}
