import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../domain/usecases/get_favorite_status_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

/// MVVM ViewModel for reusable favorite interactions.
///
/// This keeps favorite UI state and events out of widgets while delegating
/// persistence to domain use cases.
class FavoriteViewModel extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteViewModel({
    required this.getFavoriteStatusUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(FavoriteState.initial()) {
    on<FavoriteStatusRequested>(_onStatusRequested);
    on<FavoriteToggled>(_onToggled);
  }

  final GetFavoriteStatusUseCase getFavoriteStatusUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  Future<void> _onStatusRequested(
    FavoriteStatusRequested event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FavoriteStatus.loading,
        coinId: event.coinId,
        clearError: true,
      ),
    );

    final result = await getFavoriteStatusUseCase(event.coinId);

    switch (result) {
      case Success<bool>(value: final isFavorite):
        emit(
          state.copyWith(
            status: FavoriteStatus.success,
            isFavorite: isFavorite,
            clearError: true,
          ),
        );
      case Error<bool>(failure: final failure):
        emit(
          state.copyWith(
            status: FavoriteStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> _onToggled(
    FavoriteToggled event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FavoriteStatus.loading,
        coinId: event.coinId,
        clearError: true,
      ),
    );

    final result = await toggleFavoriteUseCase(event.coinId);

    switch (result) {
      case Success<bool>(value: final isFavorite):
        emit(
          state.copyWith(
            status: FavoriteStatus.success,
            isFavorite: isFavorite,
            clearError: true,
          ),
        );
      case Error<bool>(failure: final failure):
        emit(
          state.copyWith(
            status: FavoriteStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }
}
