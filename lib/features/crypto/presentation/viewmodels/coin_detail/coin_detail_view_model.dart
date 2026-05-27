import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/html_text_formatter.dart';
import '../../../domain/usecases/get_coin_detail_usecase.dart';
import '../../../domain/usecases/get_favorite_status_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'coin_detail_event.dart';
import 'coin_detail_state.dart';

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

  Future<void> _onRequested(
    CoinDetailRequested event,
    Emitter<CoinDetailState> emit,
  ) async {
    _coinId = event.coinId;
    emit(state.copyWith(status: CoinDetailStatus.loading, clearError: true));

    final detailResult = await getCoinDetailUseCase(event.coinId);
    final favoriteResult = await getFavoriteStatusUseCase(event.coinId);
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
            clearError: true,
          ),
        );
      case Error(failure: final failure):
        emit(
          state.copyWith(
            status: CoinDetailStatus.failure,
            isFavorite: isFavorite,
            errorMessage: failure.message,
          ),
        );
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

    final result = await toggleFavoriteUseCase(coinId);

    switch (result) {
      case Success<bool>(value: final isFavorite):
        emit(state.copyWith(isFavorite: isFavorite, clearError: true));
      case Error<bool>(failure: final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }
}
