import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../repositories/crypto_repository.dart';

class GetCoinsUseCase {
  const GetCoinsUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<DataResult<List<Coin>>>> call({
    int page = AppConstants.firstPage,
    int perPage = AppConstants.defaultPageSize,
  }) {
    final safePage =
        page < AppConstants.firstPage ? AppConstants.firstPage : page;
    final safePerPage = perPage.clamp(1, AppConstants.maxPageSize).toInt();

    return repository.getCoins(page: safePage, perPage: safePerPage);
  }
}
