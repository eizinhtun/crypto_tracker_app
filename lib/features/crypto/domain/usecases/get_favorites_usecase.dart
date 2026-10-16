import '../../../../core/error/result.dart';
import '../entities/coin.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  const GetFavoritesUseCase(this.repository);

  final FavoritesRepository repository;

  Future<Result<List<Coin>>> call() => repository.getFavorites();
}
