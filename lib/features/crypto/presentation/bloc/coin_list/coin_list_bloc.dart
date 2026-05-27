import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/result.dart';
import '../../../domain/entities/coin.dart';
import '../../../domain/usecases/get_coins_usecase.dart';
import '../../../domain/usecases/get_global_market_usecase.dart';
import '../../../domain/usecases/get_trending_coins_usecase.dart';
import '../../../domain/usecases/search_coins_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'coin_list_event.dart';
import 'coin_list_state.dart';

class CoinListBloc extends Bloc<CoinListEvent, CoinListState> {
  CoinListBloc({
    required this.getCoinsUseCase,
    required this.getTrendingCoinsUseCase,
    required this.getGlobalMarketUseCase,
    required this.searchCoinsUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(CoinListState.initial()) {
    on<CoinListStarted>(_onStarted);
    on<CoinListRefreshRequested>(_onRefreshRequested);
    on<CoinListNextPageRequested>(_onNextPageRequested);
    on<CoinListSearchChanged>(_onSearchChanged);
    on<CoinListFavoriteToggled>(_onFavoriteToggled);
  }

  final GetCoinsUseCase getCoinsUseCase;
  final GetTrendingCoinsUseCase getTrendingCoinsUseCase;
  final GetGlobalMarketUseCase getGlobalMarketUseCase;
  final SearchCoinsUseCase searchCoinsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  Future<void> _onStarted(
    CoinListStarted event,
    Emitter<CoinListState> emit,
  ) {
    return _loadFirstPage(emit);
  }

  Future<void> _onRefreshRequested(
    CoinListRefreshRequested event,
    Emitter<CoinListState> emit,
  ) {
    return _loadFirstPage(emit, isRefresh: true);
  }

  Future<void> _loadFirstPage(
    Emitter<CoinListState> emit, {
    bool isRefresh = false,
  }) async {
    emit(
      state.copyWith(
        status: isRefresh ? CoinListStatus.refreshing : CoinListStatus.loading,
        query: '',
        clearError: true,
      ),
    );

    final globalMarketResult = await getGlobalMarketUseCase();
    final trendingCoinsResult = await getTrendingCoinsUseCase();
    final coinsResult = await getCoinsUseCase();

    final globalMarket = _valueOrNull(globalMarketResult);
    final trendingCoins = _listOrExisting(
      trendingCoinsResult,
      state.trendingCoins,
    );

    switch (coinsResult) {
      case Success<List<Coin>>(value: final coins):
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: coins,
            trendingCoins: trendingCoins,
            globalMarket: globalMarket,
            page: AppConstants.firstPage,
            hasReachedMax: coins.length < AppConstants.defaultPageSize,
            isOffline: false,
            clearError: true,
          ),
        );
      case Error<List<Coin>>(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
            trendingCoins: trendingCoins,
            globalMarket: globalMarket,
            isOffline: true,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onNextPageRequested(
    CoinListNextPageRequested event,
    Emitter<CoinListState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == CoinListStatus.loadingMore ||
        state.query.trim().isNotEmpty) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: CoinListStatus.loadingMore));

    final result = await getCoinsUseCase(page: nextPage);

    switch (result) {
      case Success<List<Coin>>(value: final coins):
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: [...state.coins, ...coins],
            page: nextPage,
            hasReachedMax: coins.length < AppConstants.defaultPageSize,
            clearError: true,
          ),
        );
      case Error<List<Coin>>(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onSearchChanged(
    CoinListSearchChanged event,
    Emitter<CoinListState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      await _loadFirstPage(emit);
      return;
    }

    emit(
      state.copyWith(
        status: CoinListStatus.loading,
        query: query,
        coins: const [],
        hasReachedMax: true,
        clearError: true,
      ),
    );

    final result = await searchCoinsUseCase(query);

    switch (result) {
      case Success<List<Coin>>(value: final coins):
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: coins,
            hasReachedMax: true,
            clearError: true,
          ),
        );
      case Error<List<Coin>>(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onFavoriteToggled(
    CoinListFavoriteToggled event,
    Emitter<CoinListState> emit,
  ) async {
    final result = await toggleFavoriteUseCase(event.coinId);

    switch (result) {
      case Success<bool>(value: final isFavorite):
        emit(
          state.copyWith(
            coins: state.coins.map((coin) {
              if (coin.id != event.coinId) {
                return coin;
              }

              return coin.copyWith(isFavorite: isFavorite);
            }).toList(),
            clearError: true,
          ),
        );
      case Error<bool>(failure: final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  T? _valueOrNull<T>(Result<T> result) {
    return switch (result) {
      Success<T>(value: final value) => value,
      Error<T>() => null,
    };
  }

  List<T> _listOrExisting<T>(Result<List<T>> result, List<T> existing) {
    return switch (result) {
      Success<List<T>>(value: final value) => value,
      Error<List<T>>() => existing,
    };
  }
}
