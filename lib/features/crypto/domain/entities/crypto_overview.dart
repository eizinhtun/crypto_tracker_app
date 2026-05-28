import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import 'coin.dart';
import 'global_market.dart';
import 'trending_coin.dart';

class CryptoOverview extends Equatable {
  const CryptoOverview({
    required this.coins,
    required this.trendingCoins,
    required this.page,
    required this.perPage,
    this.globalMarket,
    this.warnings = const [],
    this.warningCategories = const [],
  });

  final List<Coin> coins;
  final List<TrendingCoin> trendingCoins;
  final GlobalMarket? globalMarket;
  final int page;
  final int perPage;
  final List<String> warnings;
  final List<FailureCategory> warningCategories;

  bool get hasReachedMax => coins.length < perPage;

  @override
  List<Object?> get props => [
        coins,
        trendingCoins,
        globalMarket,
        page,
        perPage,
        warnings,
        warningCategories,
      ];
}
