import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto_tracker_app/core/constants/api_constants.dart';
import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/network/dio_client.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CryptoRemoteDataSourceImpl', () {
    test('fetches market coins with expected CoinGecko query parameters',
        () async {
      final adapter = _MockDioAdapter(
        responseFor: (options) {
          expect(options.uri.path, endsWith(ApiConstants.coinsMarkets));
          expect(options.uri.queryParameters['vs_currency'], 'usd');
          expect(options.uri.queryParameters['page'], '2');
          expect(options.uri.queryParameters['per_page'], '10');
          expect(options.headers['x-cg-demo-api-key'], 'test-api-key');

          return ResponseBody.fromString(
            jsonEncode([
              {
                'id': 'bitcoin',
                'symbol': 'btc',
                'name': 'Bitcoin',
                'current_price': 100000,
                'market_cap': 2000000000,
                'price_change_percentage_24h': 1.2,
              },
            ]),
            200,
            headers: _jsonHeaders,
          );
        },
      );
      final dataSource = _createDataSource(adapter, apiKey: 'test-api-key');

      final coins = await dataSource.getCoins(page: 2, perPage: 10);

      expect(coins, hasLength(1));
      expect(coins.single.id, 'bitcoin');
      expect(coins.single.currentPrice, 100000);
    });

    test('fetches global market data', () async {
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (options) {
            expect(options.uri.path, endsWith(ApiConstants.global));

            return ResponseBody.fromString(
              jsonEncode({
                'data': {
                  'active_cryptocurrencies': 10000,
                  'markets': 1200,
                  'total_market_cap': {'usd': 3000000000000},
                  'total_volume': {'usd': 100000000000},
                  'market_cap_change_percentage_24h_usd': 2.5,
                },
              }),
              200,
              headers: _jsonHeaders,
            );
          },
        ),
      );

      final market = await dataSource.getGlobalMarket();

      expect(market.activeCryptocurrencies, 10000);
      expect(market.totalMarketCapUsd, 3000000000000);
    });

    test('maps rate limits with retry-after metadata', () async {
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (_) => ResponseBody.fromString(
            '{"error":"rate limited"}',
            429,
            statusMessage: 'Too Many Requests',
            headers: {
              ..._jsonHeaders,
              'retry-after': ['30'],
            },
          ),
        ),
      );

      await expectLater(
        dataSource.getTrendingCoins(),
        throwsA(
          isA<RateLimitException>()
              .having((error) => error.code, 'code', '429')
              .having(
                (error) => error.retryAfter,
                'retryAfter',
                const Duration(seconds: 30),
              ),
        ),
      );
    });

    test('maps authorization failures', () async {
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (_) => ResponseBody.fromString(
            '{"error":"invalid key"}',
            401,
            statusMessage: 'Unauthorized',
            headers: _jsonHeaders,
          ),
        ),
      );

      await expectLater(
        dataSource.getTrendingCoins(),
        throwsA(
          isA<UnauthorizedException>()
              .having((error) => error.code, 'code', '401')
              .having((error) => error.message, 'message', 'invalid key'),
        ),
      );
    });
  });
}

final _jsonHeaders = {
  Headers.contentTypeHeader: [Headers.jsonContentType],
};

CryptoRemoteDataSourceImpl _createDataSource(
  HttpClientAdapter adapter, {
  String apiKey = '',
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return CryptoRemoteDataSourceImpl(DioClient(dio: dio, apiKey: apiKey));
}

class _MockDioAdapter implements HttpClientAdapter {
  const _MockDioAdapter({required this.responseFor});

  final ResponseBody Function(RequestOptions options) responseFor;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return responseFor(options);
  }

  @override
  void close({bool force = false}) {}
}
