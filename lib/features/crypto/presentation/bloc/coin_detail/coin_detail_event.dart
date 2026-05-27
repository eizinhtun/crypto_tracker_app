import 'package:equatable/equatable.dart';

sealed class CoinDetailEvent extends Equatable {
  const CoinDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CoinDetailRequested extends CoinDetailEvent {
  const CoinDetailRequested(this.coinId);

  final String coinId;

  @override
  List<Object?> get props => [coinId];
}

final class CoinDetailFavoriteToggled extends CoinDetailEvent {
  const CoinDetailFavoriteToggled();
}
