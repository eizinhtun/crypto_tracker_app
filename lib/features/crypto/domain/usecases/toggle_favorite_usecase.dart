import '../../../../core/error/result.dart';
import '../repositories/crypto_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<bool>> call(String coinId) {
    return repository.toggleFavorite(coinId);
  }
}
