import 'package:equatable/equatable.dart';

import '../../../domain/entities/coin.dart';
import '../../../domain/entities/global_market.dart';
import '../../../domain/entities/trending_coin.dart';

enum CoinListStatus {
  initial,
  loading,
  success,
  failure,
  refreshing,
  loadingMore,
}

class CoinListState extends Equatable {
  const CoinListState({
    required this.status,
    required this.coins,
    required this.trendingCoins,
    required this.page,
    required this.hasReachedMax,
    required this.query,
    required this.isOffline,
    this.globalMarket,
    this.errorMessage,
  });

  factory CoinListState.initial() {
    return const CoinListState(
      status: CoinListStatus.initial,
      coins: [],
      trendingCoins: [],
      page: 1,
      hasReachedMax: false,
      query: '',
      isOffline: false,
    );
  }

  final CoinListStatus status;
  final List<Coin> coins;
  final List<TrendingCoin> trendingCoins;
  final GlobalMarket? globalMarket;
  final int page;
  final bool hasReachedMax;
  final String query;
  final bool isOffline;
  final String? errorMessage;

  CoinListState copyWith({
    CoinListStatus? status,
    List<Coin>? coins,
    List<TrendingCoin>? trendingCoins,
    GlobalMarket? globalMarket,
    int? page,
    bool? hasReachedMax,
    String? query,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoinListState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      trendingCoins: trendingCoins ?? this.trendingCoins,
      globalMarket: globalMarket ?? this.globalMarket,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      query: query ?? this.query,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        coins,
        trendingCoins,
        globalMarket,
        page,
        hasReachedMax,
        query,
        isOffline,
        errorMessage,
      ];
}
