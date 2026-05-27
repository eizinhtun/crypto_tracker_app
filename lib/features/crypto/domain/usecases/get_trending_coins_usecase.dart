import '../../../../core/error/result.dart';
import '../entities/trending_coin.dart';
import '../repositories/crypto_repository.dart';

class GetTrendingCoinsUseCase {
  const GetTrendingCoinsUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<List<TrendingCoin>>> call() {
    return repository.getTrendingCoins();
  }
}
