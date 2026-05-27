import '../../../../core/error/result.dart';
import '../entities/coin_detail.dart';
import '../repositories/crypto_repository.dart';

class GetCoinDetailUseCase {
  const GetCoinDetailUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<CoinDetail>> call(String coinId) {
    return repository.getCoinDetail(coinId);
  }
}
