import 'package:dio/dio.dart';

class ApiKeyInterceptor extends Interceptor {
  const ApiKeyInterceptor({
    required this.apiKey,
    required this.headerName,
  });

  final String apiKey;
  final String headerName;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final safeApiKey = apiKey.trim();
    final safeHeaderName = headerName.trim();

    if (safeApiKey.isNotEmpty && safeHeaderName.isNotEmpty) {
      options.headers[safeHeaderName] = safeApiKey;
    }

    handler.next(options);
  }
}
