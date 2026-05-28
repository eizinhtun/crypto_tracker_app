import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/network/http_error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpErrorMapper', () {
    test('maps client and server status codes to friendly exceptions', () {
      expect(_mapStatus(400), isA<BadRequestException>());
      expect(_mapStatus(403), isA<ForbiddenException>());
      expect(_mapStatus(404), isA<NotFoundException>());
      expect(_mapStatus(408), isA<NetworkException>());
      expect(_mapStatus(500), isA<ServerException>());

      for (final exception in [
        _mapStatus(400),
        _mapStatus(403),
        _mapStatus(404),
        _mapStatus(408),
        _mapStatus(500),
      ]) {
        expect(exception.message, isNot(contains('DioException')));
        expect(exception.message, isNot(contains('api.coingecko.com')));
      }
    });

    test('maps connection and unknown Dio failures to friendly exceptions', () {
      final connectionError = HttpErrorMapper.fromDioException(
        DioException(
          requestOptions: _requestOptions,
          type: DioExceptionType.connectionError,
        ),
      );
      final unknownError = HttpErrorMapper.fromDioException(
        DioException(
          requestOptions: _requestOptions,
          type: DioExceptionType.unknown,
        ),
      );

      expect(connectionError, isA<NetworkException>());
      expect(connectionError.code, 'connection_error');
      expect(connectionError.message, contains('No internet connection'));
      expect(unknownError, isA<ServerException>());
      expect(unknownError.message, 'Unable to load data. Please try again.');
    });
  });
}

final _requestOptions = RequestOptions(path: '/coins/markets');

AppException _mapStatus(int statusCode) {
  return HttpErrorMapper.fromDioException(
    DioException(
      requestOptions: _requestOptions,
      response: Response<dynamic>(
        requestOptions: _requestOptions,
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    ),
  );
}
