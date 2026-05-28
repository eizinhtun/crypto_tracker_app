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

final class CoinListScrollChanged extends CoinListEvent {
  const CoinListScrollChanged({
    required this.pixels,
    required this.maxScrollExtent,
  });

  final double pixels;
  final double maxScrollExtent;

  double get remainingExtent => maxScrollExtent - pixels;

  @override
  List<Object?> get props => [pixels, maxScrollExtent];
}

final class CoinListSearchChanged extends CoinListEvent {
  const CoinListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class CoinListSearchDebounced extends CoinListEvent {
  const CoinListSearchDebounced(this.query);

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

final class CoinListFavoriteStatusRequested extends CoinListEvent {
  const CoinListFavoriteStatusRequested(this.coinId);

  final String coinId;

  @override
  List<Object?> get props => [coinId];
}
