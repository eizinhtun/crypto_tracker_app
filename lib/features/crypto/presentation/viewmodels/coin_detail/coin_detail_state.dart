import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
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
    this.hasCachedData = false,
    this.detail,
    this.descriptionText = '',
    this.failureCategory,
    this.lastUpdated,
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
  final bool hasCachedData;
  final FailureCategory? failureCategory;
  final DateTime? lastUpdated;

  CoinDetailState copyWith({
    CoinDetailStatus? status,
    CoinDetail? detail,
    String? descriptionText,
    bool? isFavorite,
    bool? isOffline,
    bool? hasCachedData,
    FailureCategory? failureCategory,
    DateTime? lastUpdated,
    bool clearFailure = false,
    bool clearLastUpdated = false,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      descriptionText: descriptionText ?? this.descriptionText,
      isFavorite: isFavorite ?? this.isFavorite,
      isOffline: isOffline ?? this.isOffline,
      hasCachedData: hasCachedData ?? this.hasCachedData,
      failureCategory:
          clearFailure ? null : failureCategory ?? this.failureCategory,
      lastUpdated: clearLastUpdated ? null : lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        status,
        detail,
        descriptionText,
        isFavorite,
        isOffline,
        hasCachedData,
        failureCategory,
        lastUpdated,
      ];
}
