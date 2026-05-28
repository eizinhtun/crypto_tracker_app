import 'package:dio/dio.dart';

import '../error/exceptions.dart';

abstract final class HttpErrorMapper {
  static const unableToLoadData = 'Unable to load data. Please try again.';
  static const requestTimedOut = 'Request timed out. Please try again.';
  static const noInternet =
      'No internet connection. Showing cached data if available.';
  static const notFound = 'Requested data was not found.';
  static const rateLimited = 'Too many requests. Please wait and try again.';

  static AppException fromDioException(DioException error) {
    final response = error.response;

    if (response != null) {
      return fromResponse(response);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkException(requestTimedOut, code: 'timeout'),
      DioExceptionType.connectionError => const NetworkException(
          noInternet,
          code: 'connection_error',
        ),
      DioExceptionType.cancel => const NetworkException(
          unableToLoadData,
          code: 'cancelled',
        ),
      DioExceptionType.badCertificate => const NetworkException(
          unableToLoadData,
          code: 'bad_certificate',
        ),
      DioExceptionType.badResponse => const ServerException(
          unableToLoadData,
          code: 'bad_response',
        ),
      DioExceptionType.unknown => const ServerException(
          unableToLoadData,
          code: 'unknown',
        ),
    };
  }

  static AppException fromResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final code = statusCode.toString();

    return switch (statusCode) {
      400 => const BadRequestException(unableToLoadData, code: '400'),
      401 => const UnauthorizedException(unableToLoadData, code: '401'),
      403 => const ForbiddenException(unableToLoadData, code: '403'),
      404 => const NotFoundException(notFound, code: '404'),
      408 => const NetworkException(requestTimedOut, code: '408'),
      429 => RateLimitException(
          rateLimited,
          code: code,
          retryAfter: _retryAfter(response.headers),
        ),
      >= 500 => ServerException(unableToLoadData, code: code),
      _ => ServerException(unableToLoadData, code: code),
    };
  }

  static Duration? _retryAfter(Headers headers) {
    final value = headers.value('retry-after');
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
