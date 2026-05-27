import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/crypto_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<bool>> call(String coinId) {
    final safeCoinId = coinId.trim();
    if (safeCoinId.isEmpty) {
      return Future.value(
        const Result.failure(ValidationFailure('Coin id is required')),
      );
    }

    return repository.toggleFavorite(safeCoinId);
  }
}
