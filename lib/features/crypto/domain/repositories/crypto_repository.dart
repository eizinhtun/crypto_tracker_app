import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../entities/coin_detail.dart';
import '../entities/global_market.dart';
import '../entities/trending_coin.dart';

abstract class CryptoRepository {
  Future<Result<List<Coin>>> getCoins({
    required int page,
    required int perPage,
  });

  Future<Result<CoinDetail>> getCoinDetail(String coinId);

  Future<Result<List<TrendingCoin>>> getTrendingCoins();

  Future<Result<GlobalMarket>> getGlobalMarket();

  Future<Result<List<Coin>>> searchCoins(String query);

  Future<Result<bool>> toggleFavorite(String coinId);

  Future<Result<bool>> isFavorite(String coinId);
}
