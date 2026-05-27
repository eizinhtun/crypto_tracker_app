import 'package:equatable/equatable.dart';

enum FavoriteStatus {
  initial,
  loading,
  success,
  failure,
}

class FavoriteState extends Equatable {
  const FavoriteState({
    required this.status,
    required this.isFavorite,
    this.coinId,
    this.errorMessage,
  });

  factory FavoriteState.initial() {
    return const FavoriteState(
      status: FavoriteStatus.initial,
      isFavorite: false,
    );
  }

  final FavoriteStatus status;
  final String? coinId;
  final bool isFavorite;
  final String? errorMessage;

  FavoriteState copyWith({
    FavoriteStatus? status,
    String? coinId,
    bool? isFavorite,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoriteState(
      status: status ?? this.status,
      coinId: coinId ?? this.coinId,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        coinId,
        isFavorite,
        errorMessage,
      ];
}
