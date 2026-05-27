import 'package:equatable/equatable.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

final class FavoriteStatusRequested extends FavoriteEvent {
  const FavoriteStatusRequested(this.coinId);

  final String coinId;

  @override
  List<Object?> get props => [coinId];
}

final class FavoriteToggled extends FavoriteEvent {
  const FavoriteToggled(this.coinId);

  final String coinId;

  @override
  List<Object?> get props => [coinId];
}
