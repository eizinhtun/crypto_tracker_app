import 'package:equatable/equatable.dart';

import '../../../domain/entities/coin_detail.dart';

enum CoinDetailStatus {
  initial,
  loading,
  success,
  failure,
}

class CoinDetailState extends Equatable {
  const CoinDetailState({
    required this.status,
    required this.isFavorite,
    this.detail,
    this.errorMessage,
  });

  factory CoinDetailState.initial() {
    return const CoinDetailState(
      status: CoinDetailStatus.initial,
      isFavorite: false,
    );
  }

  final CoinDetailStatus status;
  final CoinDetail? detail;
  final bool isFavorite;
  final String? errorMessage;

  CoinDetailState copyWith({
    CoinDetailStatus? status,
    CoinDetail? detail,
    bool? isFavorite,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detail,
        isFavorite,
        errorMessage,
      ];
}
