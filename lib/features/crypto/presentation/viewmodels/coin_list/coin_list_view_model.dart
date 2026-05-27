import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/debounce.dart';
import '../../../domain/entities/coin.dart';
import '../../../domain/usecases/get_coins_usecase.dart';
import '../../../domain/usecases/get_crypto_overview_usecase.dart';
import '../../../domain/usecases/search_coins_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'coin_list_event.dart';
import 'coin_list_state.dart';

class CoinListViewModel extends Bloc<CoinListEvent, CoinListState> {
  CoinListViewModel({
    required this.getCoinsUseCase,
    required this.getCryptoOverviewUseCase,
    required this.searchCoinsUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(CoinListState.initial()) {
    on<CoinListStarted>(_onStarted);
    on<CoinListRefreshRequested>(_onRefreshRequested);
    on<CoinListScrollChanged>(_onScrollChanged);
    on<CoinListNextPageRequested>(_onNextPageRequested);
    on<CoinListSearchChanged>(_onSearchChanged);
    on<CoinListSearchDebounced>(_onSearchDebounced);
    on<CoinListFavoriteToggled>(_onFavoriteToggled);
  }

  final GetCoinsUseCase getCoinsUseCase;
  final GetCryptoOverviewUseCase getCryptoOverviewUseCase;
  final SearchCoinsUseCase searchCoinsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  final Debounce _searchDebounce = Debounce(AppConstants.debounceDuration);

  @override
  Future<void> close() {
    _searchDebounce.dispose();
    return super.close();
  }

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

  void _onScrollChanged(
    CoinListScrollChanged event,
    Emitter<CoinListState> emit,
  ) {
    if (event.remainingExtent <= AppConstants.paginationScrollThreshold) {
      add(const CoinListNextPageRequested());
    }
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

    final overviewResult = await getCryptoOverviewUseCase();

    switch (overviewResult) {
      case Success(value: final overviewResult):
        final overview = overviewResult.data;
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: overview.coins,
            trendingCoins: overview.trendingCoins,
            globalMarket: overview.globalMarket,
            page: overview.page,
            hasReachedMax: overview.hasReachedMax,
            isOffline: overviewResult.isFromCache,
            clearError: true,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
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
      case Success<DataResult<List<Coin>>>(value: final coinsResult):
        final coins = coinsResult.data;
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: [...state.coins, ...coins],
            page: nextPage,
            hasReachedMax: coins.length < AppConstants.defaultPageSize,
            isOffline: coinsResult.isFromCache,
            clearError: true,
          ),
        );
      case Error<DataResult<List<Coin>>>(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  void _onSearchChanged(
    CoinListSearchChanged event,
    Emitter<CoinListState> emit,
  ) {
    final query = event.query.trim();
    if (query.isEmpty) {
      _searchDebounce.dispose();
      add(const CoinListSearchDebounced(''));
      return;
    }

    _searchDebounce(() => add(CoinListSearchDebounced(query)));
  }

  Future<void> _onSearchDebounced(
    CoinListSearchDebounced event,
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
      case Success<DataResult<List<Coin>>>(value: final coinsResult):
        final coins = coinsResult.data;
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: coins,
            hasReachedMax: true,
            isOffline: coinsResult.isFromCache,
            clearError: true,
          ),
        );
      case Error<DataResult<List<Coin>>>(failure: final failure):
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
}
