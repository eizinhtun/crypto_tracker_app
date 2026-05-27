import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../repositories/crypto_repository.dart';

class GetCoinsUseCase {
  const GetCoinsUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<List<Coin>>> call({
    int page = AppConstants.firstPage,
    int perPage = AppConstants.defaultPageSize,
  }) {
    return repository.getCoins(page: page, perPage: perPage);
  }
}
