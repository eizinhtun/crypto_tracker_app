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
    test(
        'Given market coins request, when fetched, then CoinGecko query parameters are sent',
        () async {
      final adapter = _MockDioAdapter(
        responseFor: (options) {
          expect(options.uri.path, endsWith(ApiConstants.coinsMarkets));
          expect(options.uri.queryParameters['vs_currency'], 'usd');
          expect(options.uri.queryParameters['page'], '2');
          expect(options.uri.queryParameters['per_page'], '10');
          expect(
            options.headers.keys.where(
              (key) => key.toString().toLowerCase().contains('key'),
            ),
            isEmpty,
          );

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
      final dataSource = _createDataSource(adapter);

      final coins = await dataSource.getCoins(page: 2, perPage: 10);

      expect(coins, hasLength(1));
      expect(coins.single.id, 'bitcoin');
      expect(coins.single.currentPrice, 100000);
    });

    test('Given global endpoint response, when fetched, then market data maps',
        () async {
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

    test(
        'Given coin detail response, when fetched, then detail market data maps',
        () async {
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (options) {
            expect(options.uri.path, endsWith('/coins/ethereum'));
            expect(options.uri.queryParameters['market_data'], 'true');

            return ResponseBody.fromString(
              jsonEncode({
                'id': 'ethereum',
                'symbol': 'eth',
                'name': 'Ethereum',
                'market_cap_rank': 2,
                'image': {'large': 'https://example.com/eth.png'},
                'description': {'en': 'Ethereum description'},
                'links': {
                  'homepage': ['https://ethereum.org/'],
                },
                'market_data': {
                  'current_price': {'usd': 2095.85},
                  'market_cap': {'usd': 253150000000},
                  'total_volume': {'usd': 9780000000},
                  'price_change_percentage_24h': -0.13,
                  'ath': {'usd': 4878},
                  'ath_change_percentage': {'usd': -57.03},
                  'atl': {'usd': 0.43},
                  'atl_change_percentage': {'usd': 487306.98},
                  'circulating_supply': 120280000,
                },
              }),
              200,
              headers: _jsonHeaders,
            );
          },
        ),
      );

      final detail = await dataSource.getCoinDetail('ethereum');

      expect(detail.id, 'ethereum');
      expect(detail.currentPrice, 2095.85);
      expect(detail.marketCap, 253150000000);
      expect(detail.totalVolume, 9780000000);
      expect(detail.allTimeLow, 0.43);
    });

    test(
        'Given search response coins, when searching, then one CoinGecko search request maps rows',
        () async {
      final requestedPaths = <String>[];
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (options) {
            requestedPaths.add(options.uri.path);

            if (options.uri.path.endsWith(ApiConstants.search)) {
              expect(options.uri.queryParameters['query'], 'bit');
              return ResponseBody.fromString(
                jsonEncode({
                  'coins': [
                    {
                      'id': 'bitcoin',
                      'symbol': 'btc',
                      'name': 'Bitcoin',
                      'large': 'https://example.com/btc.png',
                    },
                    {
                      'id': 'wrapped-bitcoin',
                      'symbol': 'wbtc',
                      'name': 'WBTC',
                      'thumb': 'https://example.com/wbtc.png',
                    },
                  ],
                }),
                200,
                headers: _jsonHeaders,
              );
            }

            fail('Unexpected request: ${options.uri}');
          },
        ),
      );

      final coins = await dataSource.searchCoins('bit');

      expect(requestedPaths, hasLength(1));
      expect(coins.map((coin) => coin.id), ['bitcoin', 'wrapped-bitcoin']);
      expect(coins.first.image, 'https://example.com/btc.png');
      expect(coins.first.currentPrice, isNull);
      expect(coins.first.marketCap, isNull);
    });

    test(
        'Given search has no ids, when searching, then market data is not fetched',
        () async {
      final requestedPaths = <String>[];
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (options) {
            requestedPaths.add(options.uri.path);
            expect(options.uri.path, endsWith(ApiConstants.search));

            return ResponseBody.fromString(
              jsonEncode({'coins': []}),
              200,
              headers: _jsonHeaders,
            );
          },
        ),
      );

      final coins = await dataSource.searchCoins('no-match');

      expect(coins, isEmpty);
      expect(requestedPaths, hasLength(1));
    });

    test(
        'Given CoinGecko returns 429, when request fails, then retry metadata is mapped',
        () async {
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
                (error) => error.message,
                'message',
                'Too many requests. Please wait and try again.',
              )
              .having(
                (error) => error.retryAfter,
                'retryAfter',
                const Duration(seconds: 30),
              ),
        ),
      );
    });

    test(
        'Given CoinGecko returns 500, when request fails, then server exception is mapped',
        () async {
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (_) => ResponseBody.fromString(
            '{"error":"temporary outage"}',
            500,
            statusMessage: 'Internal Server Error',
            headers: _jsonHeaders,
          ),
        ),
      );

      await expectLater(
        dataSource.getGlobalMarket(),
        throwsA(
          isA<ServerException>()
              .having((error) => error.code, 'code', '500')
              .having(
                (error) => error.message,
                'message',
                'Unable to load data. Please try again.',
              ),
        ),
      );
    });

    test(
        'Given transient server failure, when retry succeeds, then response is returned',
        () async {
      var requestCount = 0;
      final dataSource = _createDataSource(
        _MockDioAdapter(
          responseFor: (_) {
            requestCount++;
            if (requestCount == 1) {
              return ResponseBody.fromString(
                '{"error":"temporary outage"}',
                500,
                statusMessage: 'Internal Server Error',
                headers: _jsonHeaders,
              );
            }

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
        maxRetries: 1,
        retryBaseDelay: Duration.zero,
      );

      final market = await dataSource.getGlobalMarket();

      expect(requestCount, 2);
      expect(market.activeCryptocurrencies, 10000);
    });

    test(
        'Given CoinGecko returns unauthorized, when request fails, then auth exception is mapped',
        () async {
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
              .having(
                (error) => error.message,
                'message',
                'Unable to load data. Please try again.',
              ),
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
  int maxRetries = 0,
  Duration retryBaseDelay = Duration.zero,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return CryptoRemoteDataSourceImpl(
    DioClient(
      dio: dio,
      maxRetries: maxRetries,
      retryBaseDelay: retryBaseDelay,
      enableLogging: false,
    ),
  );
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
