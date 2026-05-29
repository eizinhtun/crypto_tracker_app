import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/coin_detail_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given first detail load fails, when retry is tapped, then original coin id is requested again',
    (tester) async {
      final repository = _RetryCryptoRepository();
      final viewModel = CoinDetailViewModel(
        getCoinDetailUseCase: GetCoinDetailUseCase(repository),
        getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      );
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: viewModel,
            child: const CoinDetailPage(coinId: 'bitcoin'),
          ),
        ),
      );

      viewModel.add(const CoinDetailRequested('bitcoin'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unable to load data. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(repository.detailRequests, ['bitcoin', 'bitcoin']);
      expect(find.text('BITCOIN'), findsOneWidget);
    },
  );

  testWidgets(
    'Given Myanmar locale, when detail load fails, then native error and retry labels are shown',
    (tester) async {
      final repository = _RetryCryptoRepository();
      final viewModel = CoinDetailViewModel(
        getCoinDetailUseCase: GetCoinDetailUseCase(repository),
        getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      );
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('my'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BlocProvider.value(
            value: viewModel,
            child: const CoinDetailPage(coinId: 'bitcoin'),
          ),
        ),
      );

      viewModel.add(const CoinDetailRequested('bitcoin'));
      await tester.pumpAndSettle();

      expect(
        find.text('အချက်အလက် မရယူနိုင်ပါ။ ထပ်မံကြိုးစားပါ။'),
        findsOneWidget,
      );
      expect(find.text('ထပ်မံကြိုးစားမည်'), findsOneWidget);
    },
  );
}

class _RetryCryptoRepository implements CryptoRepository {
  final detailRequests = <String>[];

  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) async {
    detailRequests.add(coinId);

    if (detailRequests.length == 1) {
      return const Result.failure(ServerFailure('Unable to load detail'));
    }

    return Result.success(
      DataResult.remote(
        CoinDetail(
          id: coinId,
          symbol: 'btc',
          name: 'Bitcoin',
          currentPrice: 100000,
        ),
      ),
    );
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) async {
    return const Result.success(false, source: ResultSource.local);
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) {
    throw UnimplementedError();
  }
}
