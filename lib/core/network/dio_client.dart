import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'http_error_interceptor.dart';
import 'retry_interceptor.dart';

class DioClient {
  DioClient({
    Dio? dio,
    int maxRetries = 2,
    Duration retryBaseDelay = const Duration(milliseconds: 300),
    bool enableLogging = kDebugMode,
    List<Interceptor> interceptors = const [],
  }) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = AppConstants.requestTimeout
      ..receiveTimeout = AppConstants.requestTimeout
      ..sendTimeout = AppConstants.requestTimeout
      ..headers = {
        ...this.dio.options.headers,
        Headers.acceptHeader: Headers.jsonContentType,
      };

    this.dio.interceptors.addAll([
      RetryInterceptor(
        dio: this.dio,
        maxRetries: maxRetries,
        baseDelay: retryBaseDelay,
      ),
      const HttpErrorInterceptor(),
      ...interceptors,
      if (enableLogging)
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
        ),
    ]);
  }

  final Dio dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
  }
}
