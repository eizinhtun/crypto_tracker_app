import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../entities/coin_detail.dart';
import '../entities/global_market.dart';
import '../entities/trending_coin.dart';

abstract class CryptoRepository {
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  });

  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId);

  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins();

  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket();

  Future<Result<DataResult<List<Coin>>>> searchCoins(String query);

  Future<Result<bool>> toggleFavorite(String coinId);

  Future<Result<bool>> isFavorite(String coinId);
}
