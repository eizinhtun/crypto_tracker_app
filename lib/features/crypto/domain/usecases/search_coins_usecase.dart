import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../repositories/crypto_repository.dart';

class SearchCoinsUseCase {
  const SearchCoinsUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<List<Coin>>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(const Result.success([]));
    }

    return repository.searchCoins(query);
  }
}
