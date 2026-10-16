import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/entities/coin.dart';
import '../../../domain/usecases/get_favorites_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';

enum FavoriteSort { name, marketCap, price, change }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.coins = const [],
    this.query = '',
    this.sort = FavoriteSort.name,
    this.loading = false,
    this.failure,
    this.removing = const {},
  });

  final List<Coin> coins;
  final String query;
  final FavoriteSort sort;
  final bool loading;
  final FailureCategory? failure;
  final Set<String> removing;

  List<Coin> get visibleCoins {
    final search = query.trim().toLowerCase();
    final result = coins
        .where((coin) =>
            coin.name.toLowerCase().contains(search) ||
            coin.symbol.toLowerCase().contains(search))
        .toList();
    result.sort((a, b) {
      int compareNullable(double? a, double? b) {
        if (a == null) return b == null ? 0 : 1;
        if (b == null) return -1;
        return b.compareTo(a);
      }

      final order = switch (sort) {
        FavoriteSort.name =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        FavoriteSort.marketCap => compareNullable(a.marketCap, b.marketCap),
        FavoriteSort.price => compareNullable(a.currentPrice, b.currentPrice),
        FavoriteSort.change => compareNullable(
            a.priceChangePercentage24h, b.priceChangePercentage24h),
      };
      return order == 0 ? a.id.compareTo(b.id) : order;
    });
    return result;
  }

  @override
  List<Object?> get props => [coins, query, sort, loading, failure, removing];
}

class FavoritesViewModel extends Cubit<FavoritesState> {
  FavoritesViewModel(this.getFavorites, this.toggleFavorite)
      : super(const FavoritesState());

  final GetFavoritesUseCase getFavorites;
  final ToggleFavoriteUseCase toggleFavorite;

  void _update(
      {List<Coin>? coins,
      String? query,
      FavoriteSort? sort,
      bool? loading,
      FailureCategory? failure,
      Set<String>? removing}) {
    if (isClosed) return;
    emit(FavoritesState(
        coins: coins ?? state.coins,
        query: query ?? state.query,
        sort: sort ?? state.sort,
        loading: loading ?? state.loading,
        failure: failure,
        removing: removing ?? state.removing));
  }

  Future<void> load() async {
    if (state.loading || state.removing.isNotEmpty) return;
    _update(loading: true);
    final result = await getFavorites();
    if (isClosed) return;
    switch (result) {
      case Success(value: final coins):
        _update(coins: coins, loading: false);
      case Error(failure: final failure):
        _update(loading: false, failure: failure.category);
    }
  }

  void search(String query) => _update(query: query);
  void sortBy(FavoriteSort sort) => _update(sort: sort);

  Future<void> remove(String id) async {
    if (state.loading || state.removing.contains(id)) return;
    _update(removing: {...state.removing, id});
    final result = await toggleFavorite(id);
    if (isClosed) return;
    final pending = {...state.removing}..remove(id);
    switch (result) {
      case Success(value: final isFavorite):
        _update(
            coins: isFavorite
                ? state.coins
                : state.coins.where((coin) => coin.id != id).toList(),
            removing: pending);
      case Error(failure: final failure):
        _update(failure: failure.category, removing: pending);
    }
  }
}
