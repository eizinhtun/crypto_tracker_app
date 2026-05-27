import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import 'http_error_mapper.dart';

class HttpErrorInterceptor extends Interceptor {
  const HttpErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final originalError = err.error;
    if (originalError is AppException) {
      handler.next(err);
      return;
    }

    final mappedError = HttpErrorMapper.fromDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mappedError,
        message: mappedError.message,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
