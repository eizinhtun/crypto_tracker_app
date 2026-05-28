import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/debounce.dart';
import '../../../domain/entities/coin.dart';
import '../../../domain/usecases/get_coins_usecase.dart';
import '../../../domain/usecases/get_crypto_overview_usecase.dart';
import '../../../domain/usecases/get_favorite_status_usecase.dart';
import '../../../domain/usecases/search_coins_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'coin_list_event.dart';
import 'coin_list_state.dart';

/// MVVM ViewModel for the markets list screen.
///
/// This class uses `Bloc` for event/state mechanics, but its architectural role
/// is ViewModel: it receives View events, exposes immutable UI state, invokes
/// domain use cases, and maps domain results into renderable state.
class CoinListViewModel extends Bloc<CoinListEvent, CoinListState> {
  CoinListViewModel({
    required this.getCoinsUseCase,
    required this.getCryptoOverviewUseCase,
    required this.getFavoriteStatusUseCase,
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
    on<CoinListFavoriteStatusRequested>(_onFavoriteStatusRequested);
  }

  final GetCoinsUseCase getCoinsUseCase;
  final GetCryptoOverviewUseCase getCryptoOverviewUseCase;
  final GetFavoriteStatusUseCase getFavoriteStatusUseCase;
  final SearchCoinsUseCase searchCoinsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  final Debounce _searchDebounce = Debounce(AppConstants.debounceDuration);
  final Set<String> _favoriteToggleIds = <String>{};
  bool _isFirstPageLoading = false;
  bool _isPaginationRequestQueued = false;
  int _searchRequestId = 0;

  @override
  Future<void> close() {
    _searchDebounce.dispose();
    return super.close();
  }

  Future<void> _onStarted(
    CoinListStarted event,
    Emitter<CoinListState> emit,
  ) {
    if (_isFirstPageLoading || state.status == CoinListStatus.loading) {
      return Future<void>.value();
    }

    return _loadFirstPage(emit);
  }

  Future<void> _onRefreshRequested(
    CoinListRefreshRequested event,
    Emitter<CoinListState> emit,
  ) {
    if (_isFirstPageLoading) {
      return Future<void>.value();
    }

    return _loadFirstPage(emit, isRefresh: true);
  }

  void _onScrollChanged(
    CoinListScrollChanged event,
    Emitter<CoinListState> emit,
  ) {
    if (event.remainingExtent > AppConstants.paginationScrollThreshold ||
        _isPaginationRequestQueued ||
        state.hasReachedMax ||
        state.query.trim().isNotEmpty ||
        state.status == CoinListStatus.loading ||
        state.status == CoinListStatus.refreshing ||
        state.status == CoinListStatus.loadingMore) {
      return;
    }

    _isPaginationRequestQueued = true;
    add(const CoinListNextPageRequested());
  }

  Future<void> _loadFirstPage(
    Emitter<CoinListState> emit, {
    bool isRefresh = false,
  }) async {
    _isFirstPageLoading = true;
    emit(
      state.copyWith(
        status: isRefresh ? CoinListStatus.refreshing : CoinListStatus.loading,
        query: '',
        isOffline: false,
        clearFailure: true,
        clearLastUpdated: true,
      ),
    );

    try {
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
              clearGlobalMarket: overview.globalMarket == null,
              page: overview.page,
              hasReachedMax: overview.hasReachedMax,
              isOffline: overviewResult.isFromCache,
              lastUpdated: overviewResult.lastUpdated,
              clearFailure: true,
              clearLastUpdated: !overviewResult.isFromCache,
            ),
          );
        case Error(failure: final failure):
          emit(
            state.copyWith(
              status: CoinListStatus.failure,
              isOffline: true,
              failureCategory: failure.category,
            ),
          );
      }
    } finally {
      _isFirstPageLoading = false;
    }
  }

  Future<void> _onNextPageRequested(
    CoinListNextPageRequested event,
    Emitter<CoinListState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == CoinListStatus.loadingMore ||
        state.query.trim().isNotEmpty) {
      _isPaginationRequestQueued = false;
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(status: CoinListStatus.loadingMore));

    try {
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
              lastUpdated: coinsResult.lastUpdated,
              clearFailure: true,
              clearLastUpdated: !coinsResult.isFromCache,
            ),
          );
        case Error<DataResult<List<Coin>>>(failure: final failure):
          emit(
            state.copyWith(
              status: CoinListStatus.failure,
              failureCategory: failure.category,
            ),
          );
      }
    } finally {
      _isPaginationRequestQueued = false;
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
    final requestId = ++_searchRequestId;
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
        isOffline: false,
        clearFailure: true,
        clearLastUpdated: true,
      ),
    );

    final result = await searchCoinsUseCase(query);

    if (!_isLatestSearchRequest(requestId, query)) {
      return;
    }

    switch (result) {
      case Success<DataResult<List<Coin>>>(value: final coinsResult):
        final coins = coinsResult.data;
        emit(
          state.copyWith(
            status: CoinListStatus.success,
            coins: coins,
            hasReachedMax: true,
            isOffline: coinsResult.isFromCache,
            lastUpdated: coinsResult.lastUpdated,
            clearFailure: true,
            clearLastUpdated: !coinsResult.isFromCache,
          ),
        );
      case Error<DataResult<List<Coin>>>(failure: final failure):
        emit(
          state.copyWith(
            status: CoinListStatus.failure,
            failureCategory: failure.category,
          ),
        );
    }
  }

  bool _isLatestSearchRequest(int requestId, String query) {
    return requestId == _searchRequestId && state.query.trim() == query;
  }

  Future<void> _onFavoriteToggled(
    CoinListFavoriteToggled event,
    Emitter<CoinListState> emit,
  ) async {
    if (!_favoriteToggleIds.add(event.coinId)) {
      return;
    }

    try {
      final result = await toggleFavoriteUseCase(event.coinId);

      switch (result) {
        case Success<bool>(value: final isFavorite):
          emit(_favoriteUpdatedState(event.coinId, isFavorite));
        case Error<bool>(failure: final failure):
          emit(state.copyWith(failureCategory: failure.category));
      }
    } finally {
      _favoriteToggleIds.remove(event.coinId);
    }
  }

  Future<void> _onFavoriteStatusRequested(
    CoinListFavoriteStatusRequested event,
    Emitter<CoinListState> emit,
  ) async {
    if (!state.coins.any((coin) => coin.id == event.coinId)) {
      return;
    }

    final result = await getFavoriteStatusUseCase(event.coinId);

    switch (result) {
      case Success<bool>(value: final isFavorite):
        emit(_favoriteUpdatedState(event.coinId, isFavorite));
      case Error<bool>(failure: final failure):
        emit(state.copyWith(failureCategory: failure.category));
    }
  }

  CoinListState _favoriteUpdatedState(String coinId, bool isFavorite) {
    return state.copyWith(
      coins: state.coins.map((coin) {
        if (coin.id != coinId) {
          return coin;
        }

        return coin.copyWith(isFavorite: isFavorite);
      }).toList(),
      clearFailure: true,
    );
  }
}
