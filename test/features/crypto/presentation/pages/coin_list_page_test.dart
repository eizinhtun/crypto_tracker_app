import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/error/failures.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/localization/locale_cubit.dart';
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
    'Given only optional overview data is cached, when markets page loads, then cached banner appears without offline state',
    (tester) async {
      final repository = _OptionalCachedOverviewRepository();
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

      expect(viewModel.state.isOffline, isFalse);
      expect(viewModel.state.hasCachedData, isTrue);
      expect(find.textContaining('Showing cached data'), findsOneWidget);
      expect(find.text('Cached Trend'), findsOneWidget);
    },
  );

  testWidgets(
    'Given markets page is refreshed, when pull-to-refresh succeeds, then list global market and trending data reload together',
    (tester) async {
      final repository = _RefreshSuccessRepository();
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

      expect(find.text('Initial Coin'), findsOneWidget);
      expect(find.text('Initial Trend'), findsOneWidget);
      expect(find.text(r'$2.00T'), findsOneWidget);

      final refresh = tester
          .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
          .show();
      await tester.pumpAndSettle();
      await refresh;
      await tester.pump();

      expect(find.text('Refreshed Coin'), findsOneWidget);
      expect(find.text('Refreshed Trend'), findsOneWidget);
      expect(find.text(r'$4.00T'), findsOneWidget);
      expect(repository.coinPageOneRequests, 2);
      expect(repository.globalMarketRequests, 2);
      expect(repository.trendingRequests, 2);
    },
  );

  testWidgets(
    'Given markets page is scrolled near the bottom, when page two loads, then rows are appended once',
    (tester) async {
      final repository = _PagedRepository();
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

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2200));
      await tester.pump();
      await tester.pump();

      expect(repository.requestedPages, [1, 2]);
      expect(viewModel.state.coins.map((coin) => coin.id), contains('coin-25'));
      expect(viewModel.state.coins.length, AppConstants.defaultPageSize + 1);
    },
  );

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

  testWidgets(
    'Given markets page is visible, when language toggle is tapped, then localized labels update',
    (tester) async {
      final repository = _LoadMoreFailureRepository();
      final localeCubit = LocaleCubit();
      final viewModel = CoinListViewModel(
        getCoinsUseCase: GetCoinsUseCase(repository),
        getCryptoOverviewUseCase: GetCryptoOverviewUseCase(repository),
        getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
        searchCoinsUseCase: SearchCoinsUseCase(repository),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      );
      addTearDown(localeCubit.close);
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: localeCubit,
          child: BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp(
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: BlocProvider.value(
                  value: viewModel,
                  child: const CoinListPage(),
                ),
              );
            },
          ),
        ),
      );

      viewModel.add(const CoinListStarted());
      await tester.pump();
      await tester.pump();

      expect(find.text('Markets'), findsOneWidget);
      expect(find.text('ASSET'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch language'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('စျေးကွက်များ'), findsOneWidget);
      expect(find.text('ပိုင်ဆိုင်မှု'), findsOneWidget);
    },
  );

  testWidgets(
    'Given submitted search returns market rows, when results render, then price market cap and 24h values are shown',
    (tester) async {
      final repository = _SearchResultsRepository();
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

      final searchCompleted = viewModel.stream.firstWhere(
        (state) => state.query == 'bitcoin' && state.coins.isNotEmpty,
      );
      await tester.enterText(find.byType(TextField), ' bitcoin ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await searchCompleted;
      await tester.pump();

      expect(repository.searchQueries, ['bitcoin']);
      expect(find.text('Bitcoin Search'), findsOneWidget);
      expect(find.text(r'$100,000.00'), findsOneWidget);
      expect(find.text(r'BTC  ·  $1.23T'), findsOneWidget);
      expect(find.text('1.25%'), findsOneWidget);
      expect(find.text('Search shows top 20 results'), findsOneWidget);
    },
  );
}

class _OptionalCachedOverviewRepository implements CryptoRepository {
  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    return const Result.success(
      DataResult.remote([
        Coin(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
      ]),
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
    return Result.success(
      DataResult.cache(
        const [
          TrendingCoin(
            id: 'cached-trend',
            name: 'Cached Trend',
            symbol: 'ct',
          ),
        ],
        lastUpdated: DateTime.utc(2026, 1, 1, 12),
      ),
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

class _RefreshSuccessRepository implements CryptoRepository {
  int coinPageOneRequests = 0;
  int globalMarketRequests = 0;
  int trendingRequests = 0;

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    if (page != AppConstants.firstPage) {
      return const Result.success(DataResult.remote([]));
    }

    coinPageOneRequests++;
    final isRefresh = coinPageOneRequests > 1;
    return Result.success(
      DataResult.remote([
        Coin(
          id: isRefresh ? 'refreshed-coin' : 'initial-coin',
          symbol: isRefresh ? 'ref' : 'ini',
          name: isRefresh ? 'Refreshed Coin' : 'Initial Coin',
        ),
      ]),
    );
  }

  @override
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() async {
    globalMarketRequests++;
    final isRefresh = globalMarketRequests > 1;
    return Result.success(
      DataResult.remote(
        GlobalMarket(
          activeCryptocurrencies: 10000,
          markets: 1000,
          totalMarketCapUsd: isRefresh ? 4000000000000 : 2000000000000,
          totalVolumeUsd: 90000000000,
          marketCapChangePercentage24hUsd: isRefresh ? 2.0 : 1.0,
        ),
      ),
    );
  }

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() async {
    trendingRequests++;
    final isRefresh = trendingRequests > 1;
    return Result.success(
      DataResult.remote([
        TrendingCoin(
          id: isRefresh ? 'refreshed-trend' : 'initial-trend',
          name: isRefresh ? 'Refreshed Trend' : 'Initial Trend',
          symbol: isRefresh ? 'ref' : 'ini',
        ),
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

class _PagedRepository implements CryptoRepository {
  final requestedPages = <int>[];

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    requestedPages.add(page);
    if (page == AppConstants.firstPage) {
      return Result.success(DataResult.remote(_pageOneCoins));
    }

    return const Result.success(
      DataResult.remote([
        Coin(id: 'coin-25', symbol: 'c25', name: 'Page Two Coin'),
      ]),
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
    return const Result.success(DataResult.remote([]));
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

class _SearchResultsRepository implements CryptoRepository {
  final searchQueries = <String>[];

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    return const Result.success(
      DataResult.remote([
        Coin(id: 'initial-coin', symbol: 'ini', name: 'Initial Coin'),
      ]),
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
    return const Result.success(DataResult.remote([]));
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) async {
    searchQueries.add(query);
    return const Result.success(
      DataResult.remote([
        Coin(
          id: 'bitcoin',
          symbol: 'btc',
          name: 'Bitcoin Search',
          currentPrice: 100000,
          marketCap: 1230000000000,
          priceChangePercentage24h: 1.25,
        ),
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
}

final _pageOneCoins = List<Coin>.generate(
  AppConstants.defaultPageSize,
  (index) => Coin(
    id: 'coin-$index',
    symbol: 'c$index',
    name: index == 0 ? 'Bitcoin' : 'Coin $index',
  ),
);
