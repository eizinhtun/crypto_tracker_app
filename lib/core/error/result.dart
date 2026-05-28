import 'failures.dart';

enum ResultSource {
  remote,
  cache,
  local,
}

class DataResult<T> {
  const DataResult(
    this.data, {
    this.source = ResultSource.remote,
    this.lastUpdated,
  });

  const DataResult.remote(T data) : this(data);

  const DataResult.cache(
    T data, {
    DateTime? lastUpdated,
  }) : this(
          data,
          source: ResultSource.cache,
          lastUpdated: lastUpdated,
        );

  const DataResult.local(T data)
      : this(
          data,
          source: ResultSource.local,
        );

  final T data;
  final ResultSource source;
  final DateTime? lastUpdated;

  bool get isFromCache => source == ResultSource.cache;
  bool get isLocal => source == ResultSource.local;
  bool get isRemote => source == ResultSource.remote;
}

sealed class Result<T> {
  const Result();

  const factory Result.success(
    T value, {
    ResultSource source,
  }) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(value: final value) => success(value),
      Error<T>(failure: final error) => failure(error),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(
    this.value, {
    this.source = ResultSource.remote,
  });

  final T value;
  final ResultSource source;

  bool get isFromCache => source == ResultSource.cache;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}
