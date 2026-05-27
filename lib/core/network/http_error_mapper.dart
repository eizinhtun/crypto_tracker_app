import 'dart:convert';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

abstract final class HttpErrorMapper {
  static AppException fromDioException(DioException error) {
    final response = error.response;

    if (response != null) {
      return fromResponse(response);
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkException('Request timed out', code: 'timeout'),
      DioExceptionType.connectionError => const NetworkException(
          'Unable to connect to CoinGecko',
          code: 'connection_error',
        ),
      DioExceptionType.cancel => const NetworkException(
          'Request was cancelled',
          code: 'cancelled',
        ),
      DioExceptionType.badCertificate => const NetworkException(
          'Unable to verify the server certificate',
          code: 'bad_certificate',
        ),
      DioExceptionType.badResponse => const ServerException(
          'CoinGecko request failed',
          code: 'bad_response',
        ),
      DioExceptionType.unknown => const ServerException(
          'CoinGecko request failed',
          code: 'unknown',
        ),
    };
  }

  static AppException fromResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final code = statusCode.toString();
    final message = _messageFromResponse(response);

    return switch (statusCode) {
      400 => BadRequestException(
          message ?? 'Invalid CoinGecko request',
          code: code,
        ),
      401 => UnauthorizedException(
          message ?? 'CoinGecko API key is missing or invalid',
          code: code,
        ),
      403 => ForbiddenException(
          message ?? 'CoinGecko rejected this API request',
          code: code,
        ),
      404 => NotFoundException(
          message ?? 'CoinGecko resource was not found',
          code: code,
        ),
      408 => NetworkException(
          message ?? 'CoinGecko request timed out',
          code: code,
        ),
      429 => RateLimitException(
          _rateLimitMessage(response, message),
          code: code,
          retryAfter: _retryAfter(response.headers),
        ),
      >= 500 => ServerException(
          message ?? 'CoinGecko service is unavailable',
          code: code,
        ),
      _ => ServerException(
          message ?? 'CoinGecko request failed',
          code: code,
        ),
    };
  }

  static String _rateLimitMessage(
    Response<dynamic> response,
    String? responseMessage,
  ) {
    final retryAfter = _retryAfter(response.headers);
    if (retryAfter == null) {
      return responseMessage ?? 'CoinGecko rate limit exceeded';
    }

    final seconds = retryAfter.inSeconds;
    return responseMessage == null
        ? 'CoinGecko rate limit exceeded. Retry after ${seconds}s.'
        : '$responseMessage Retry after ${seconds}s.';
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

  static String? _messageFromResponse(Response<dynamic> response) {
    final data = response.data;
    final message = _messageFromData(data);

    if (message != null && message.isNotEmpty) {
      return message;
    }

    return response.statusMessage;
  }

  static String? _messageFromData(dynamic data) {
    if (data is Map) {
      final status = data['status'];
      if (status is Map && status['error_message'] is String) {
        return status['error_message'] as String;
      }

      final error = data['error'];
      if (error is String) {
        return error;
      }

      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        return null;
      }

      try {
        return _messageFromData(jsonDecode(trimmed)) ?? trimmed;
      } on FormatException {
        return trimmed;
      }
    }

    return null;
  }
}
