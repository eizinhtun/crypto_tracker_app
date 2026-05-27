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
    required this.isOffline,
    this.detail,
    this.descriptionText = '',
    this.errorMessage,
  });

  factory CoinDetailState.initial() {
    return const CoinDetailState(
      status: CoinDetailStatus.initial,
      isFavorite: false,
      isOffline: false,
    );
  }

  final CoinDetailStatus status;
  final CoinDetail? detail;
  final String descriptionText;
  final bool isFavorite;
  final bool isOffline;
  final String? errorMessage;

  CoinDetailState copyWith({
    CoinDetailStatus? status,
    CoinDetail? detail,
    String? descriptionText,
    bool? isFavorite,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      descriptionText: descriptionText ?? this.descriptionText,
      isFavorite: isFavorite ?? this.isFavorite,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detail,
        descriptionText,
        isFavorite,
        isOffline,
        errorMessage,
      ];
}
