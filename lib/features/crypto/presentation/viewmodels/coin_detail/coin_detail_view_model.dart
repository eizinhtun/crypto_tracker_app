import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/html_text_formatter.dart';
import '../../../domain/usecases/get_coin_detail_usecase.dart';
import '../../../domain/usecases/get_favorite_status_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'coin_detail_event.dart';
import 'coin_detail_state.dart';

/// MVVM ViewModel for the coin detail screen.
///
/// `Bloc` is the state-management implementation detail. The ViewModel owns
/// detail loading, favorite state, offline metadata, and presentation-ready
/// description text for the View.
class CoinDetailViewModel extends Bloc<CoinDetailEvent, CoinDetailState> {
  CoinDetailViewModel({
    required this.getCoinDetailUseCase,
    required this.getFavoriteStatusUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(CoinDetailState.initial()) {
    on<CoinDetailRequested>(_onRequested);
    on<CoinDetailFavoriteToggled>(_onFavoriteToggled);
  }

  final GetCoinDetailUseCase getCoinDetailUseCase;
  final GetFavoriteStatusUseCase getFavoriteStatusUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  String? _coinId;
  bool _isLoadingDetail = false;
  bool _isTogglingFavorite = false;

  Future<void> _onRequested(
    CoinDetailRequested event,
    Emitter<CoinDetailState> emit,
  ) async {
    final coinId = event.coinId.trim();
    final hasLoadedCoin =
        state.status == CoinDetailStatus.success && state.detail?.id == coinId;

    if (_isLoadingDetail || (_coinId == coinId && hasLoadedCoin)) {
      return;
    }

    _coinId = coinId;
    _isLoadingDetail = true;
    emit(
      state.copyWith(
        status: CoinDetailStatus.loading,
        isOffline: false,
        hasCachedData: false,
        clearFailure: true,
        clearLastUpdated: true,
      ),
    );

    try {
      final detailResult = await getCoinDetailUseCase(coinId);
      final favoriteResult = await getFavoriteStatusUseCase(coinId);
      final isFavorite = switch (favoriteResult) {
        Success<bool>(value: final value) => value,
        Error<bool>() => false,
      };

      switch (detailResult) {
        case Success(value: final detailResult):
          final detail = detailResult.data;
          emit(
            state.copyWith(
              status: CoinDetailStatus.success,
              detail: detail,
              descriptionText: HtmlTextFormatter.plainText(detail.description),
              isFavorite: isFavorite,
              isOffline: detailResult.isFromCache,
              hasCachedData: detailResult.isFromCache,
              lastUpdated: detailResult.lastUpdated,
              clearFailure: true,
              clearLastUpdated: !detailResult.isFromCache,
            ),
          );
        case Error(failure: final failure):
          emit(
            state.copyWith(
              status: CoinDetailStatus.failure,
              isFavorite: isFavorite,
              failureCategory: failure.category,
            ),
          );
      }
    } finally {
      _isLoadingDetail = false;
    }
  }

  Future<void> _onFavoriteToggled(
    CoinDetailFavoriteToggled event,
    Emitter<CoinDetailState> emit,
  ) async {
    final coinId = _coinId;
    if (coinId == null) {
      return;
    }

    if (_isTogglingFavorite) {
      return;
    }

    _isTogglingFavorite = true;
    try {
      final result = await toggleFavoriteUseCase(coinId);

      switch (result) {
        case Success<bool>(value: final isFavorite):
          emit(state.copyWith(isFavorite: isFavorite, clearFailure: true));
        case Error<bool>(failure: final failure):
          emit(state.copyWith(failureCategory: failure.category));
      }
    } finally {
      _isTogglingFavorite = false;
    }
  }
}
