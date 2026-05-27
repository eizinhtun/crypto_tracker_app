import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_key_interceptor.dart';
import 'http_error_interceptor.dart';

class DioClient {
  DioClient({
    Dio? dio,
    String apiKey = ApiConstants.apiKey,
    String apiKeyHeader = ApiConstants.apiKeyHeader,
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
      ApiKeyInterceptor(apiKey: apiKey, headerName: apiKeyHeader),
      const HttpErrorInterceptor(),
      ...interceptors,
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
