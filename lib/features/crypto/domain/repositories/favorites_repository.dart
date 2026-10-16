import '../../../../core/error/result.dart';
import '../entities/coin.dart';

abstract class FavoritesRepository {
  Future<Result<List<Coin>>> getFavorites();
}
