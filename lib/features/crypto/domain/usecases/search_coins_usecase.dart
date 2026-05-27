import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../repositories/crypto_repository.dart';

class SearchCoinsUseCase {
  const SearchCoinsUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<DataResult<List<Coin>>>> call(String query) {
    final safeQuery = query.trim();
    if (safeQuery.isEmpty) {
      return Future.value(
        const Result.success(DataResult.local([])),
      );
    }

    return repository.searchCoins(safeQuery);
  }
}
