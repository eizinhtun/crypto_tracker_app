import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/http_error_mapper.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/global_market_model.dart';
import '../models/trending_coin_model.dart';

abstract class CryptoRemoteDataSource {
  Future<List<CoinModel>> getCoins({
    required int page,
    required int perPage,
  });

  Future<CoinDetailModel> getCoinDetail(String coinId);

  Future<List<TrendingCoinModel>> getTrendingCoins();

  Future<GlobalMarketModel> getGlobalMarket();

  Future<List<CoinModel>> searchCoins(String query);
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  const CryptoRemoteDataSourceImpl(this.dioClient);

  final DioClient dioClient;

  @override
  Future<List<CoinModel>> getCoins({
    required int page,
    required int perPage,
  }) async {
    final response = await _safeGet(
      ApiConstants.coinsMarkets,
      queryParameters: {
        'vs_currency': AppConstants.defaultCurrency,
        'order': 'market_cap_desc',
        'per_page': perPage,
        'page': page,
        'sparkline': false,
        'price_change_percentage': '24h',
      },
    );

    final data = response.data;
    if (data is! List) {
      throw const ServerException('Unexpected coins response');
    }

    return data
        .whereType<Map>()
        .map((item) => CoinModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    final response = await _safeGet(
      ApiConstants.coinDetail(coinId),
      queryParameters: {
        'localization': false,
        'tickers': false,
        'market_data': true,
        'community_data': false,
        'developer_data': false,
        'sparkline': false,
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const ServerException('Unexpected coin detail response');
    }

    return CoinDetailModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<TrendingCoinModel>> getTrendingCoins() async {
    final response = await _safeGet(ApiConstants.trending);
    final data = response.data;

    if (data is! Map || data['coins'] is! List) {
      throw const ServerException('Unexpected trending coins response');
    }

    return (data['coins'] as List)
        .whereType<Map>()
        .map(
          (item) => TrendingCoinModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  @override
  Future<GlobalMarketModel> getGlobalMarket() async {
    final response = await _safeGet(ApiConstants.global);
    final data = response.data;

    if (data is! Map) {
      throw const ServerException('Unexpected global market response');
    }

    return GlobalMarketModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<CoinModel>> searchCoins(String query) async {
    final response = await _safeGet(
      ApiConstants.search,
      queryParameters: {'query': query},
    );
    final data = response.data;

    if (data is! Map || data['coins'] is! List) {
      throw const ServerException('Unexpected search response');
    }

    return (data['coins'] as List)
        .whereType<Map>()
        .map(
          (item) => CoinModel.fromSearchJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<Response<dynamic>> _safeGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dioClient.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (error) {
      final mappedError = error.error;
      if (mappedError is AppException) {
        throw mappedError;
      }

      throw HttpErrorMapper.fromDioException(error);
    }
  }
}
