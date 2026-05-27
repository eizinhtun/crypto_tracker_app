import 'package:equatable/equatable.dart';

sealed class CoinListEvent extends Equatable {
  const CoinListEvent();

  @override
  List<Object?> get props => [];
}

final class CoinListStarted extends CoinListEvent {
  const CoinListStarted();
}

final class CoinListRefreshRequested extends CoinListEvent {
  const CoinListRefreshRequested();
}

final class CoinListNextPageRequested extends CoinListEvent {
  const CoinListNextPageRequested();
}

final class CoinListSearchChanged extends CoinListEvent {
  const CoinListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CoinListFavoriteToggled extends CoinListEvent {
  const CoinListFavoriteToggled(this.coinId);

  final String coinId;

  @override
  List<Object?> get props => [coinId];
}
