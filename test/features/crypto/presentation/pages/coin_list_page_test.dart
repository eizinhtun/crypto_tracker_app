import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/search_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/coin_list_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given next page fails with existing rows, when pagination fails, then warning snackbar is shown',
    (tester) async {
      final repository = _LoadMoreFailureRepository();
      final viewModel = CoinListViewModel(
        getCoinsUseCase: GetCoinsUseCase(repository),
        getCryptoOverviewUseCase: GetCryptoOverviewUseCase(repository),
        getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
        searchCoinsUseCase: SearchCoinsUseCase(repository),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      );
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BlocProvider.value(
            value: viewModel,
            child: const CoinListPage(),
          ),
        ),
      );

      viewModel.add(const CoinListStarted());
      await tester.pump();
      await tester.pump();

      expect(find.text('Coin 1'), findsOneWidget);

      viewModel.add(const CoinListNextPageRequested());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Coin 1'), findsOneWidget);
      expect(
        find.text('Too many requests. Please wait and try again.'),
        findsOneWidget,
      );
    },
  );
}

class _LoadMoreFailureRepository implements CryptoRepository {
  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    if (page == AppConstants.firstPage) {
      return Result.success(DataResult.remote(_pageOneCoins));
    }

    return const Result.failure(
      RateLimitFailure('Too many requests. Please wait and try again.'),
    );
  }

  @override
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() async {
    return const Result.success(
      DataResult.remote(
        GlobalMarket(
          activeCryptocurrencies: 10000,
          markets: 1000,
          totalMarketCapUsd: 2000000000000,
          totalVolumeUsd: 90000000000,
          marketCapChangePercentage24hUsd: 1.2,
        ),
      ),
    );
  }

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() async {
    return const Result.success(
      DataResult.remote([
        TrendingCoin(id: 'bitcoin', name: 'Bitcoin', symbol: 'btc'),
      ]),
    );
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) async {
    return const Result.success(false, source: ResultSource.local);
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) async {
    return const Result.success(true, source: ResultSource.local);
  }

  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) {
    throw UnimplementedError();
  }
}

final _pageOneCoins = List<Coin>.generate(
  AppConstants.defaultPageSize,
  (index) => Coin(
    id: 'coin-$index',
    symbol: 'c$index',
    name: index == 0 ? 'Bitcoin' : 'Coin $index',
  ),
);
