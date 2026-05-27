import '../../../../core/error/result.dart';
import '../repositories/crypto_repository.dart';

class GetFavoriteStatusUseCase {
  const GetFavoriteStatusUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<bool>> call(String coinId) {
    return repository.isFavorite(coinId);
  }
}
