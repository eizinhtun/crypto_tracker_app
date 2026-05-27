import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

class DioClient {
  DioClient({Dio? dio}) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = ApiConstants.baseUrl
      ..connectTimeout = AppConstants.requestTimeout
      ..receiveTimeout = AppConstants.requestTimeout
      ..sendTimeout = AppConstants.requestTimeout;
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
