import '../../../../core/error/result.dart';
import '../entities/global_market.dart';
import '../repositories/crypto_repository.dart';

class GetGlobalMarketUseCase {
  const GetGlobalMarketUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<GlobalMarket>> call() {
    return repository.getGlobalMarket();
  }
}
