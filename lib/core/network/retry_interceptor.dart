import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxDelay = const Duration(seconds: 10),
  });

  static const _retryAttemptKey = 'retry_attempt';

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var error = err;

    while (_shouldRetry(error)) {
      final attempt =
          (error.requestOptions.extra[_retryAttemptKey] as int?) ?? 0;

      if (attempt >= maxRetries) {
        break;
      }

      error.requestOptions.extra[_retryAttemptKey] = attempt + 1;

      await Future<void>.delayed(_delayFor(error, attempt));

      try {
        final response = await dio.fetch<dynamic>(error.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        error = retryError;
      }
    }

    handler.next(error);
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }

    final statusCode = err.response?.statusCode;
    if (statusCode == 429 || (statusCode != null && statusCode >= 500)) {
      return true;
    }

    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };
  }

  Duration _delayFor(DioException err, int attempt) {
    final retryAfter = _retryAfter(err.response?.headers);

    if (retryAfter != null) {
      return _capDelay(retryAfter);
    }

    final calculatedDelay = baseDelay * (attempt + 1);
    return _capDelay(calculatedDelay);
  }

  Duration _capDelay(Duration delay) {
    if (delay > maxDelay) {
      return maxDelay;
    }

    return delay;
  }

  Duration? _retryAfter(Headers? headers) {
    final value = headers?.value('retry-after');
    if (value == null) {
      return null;
    }

    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 0) {
      return null;
    }

    return Duration(seconds: seconds);
  }
}