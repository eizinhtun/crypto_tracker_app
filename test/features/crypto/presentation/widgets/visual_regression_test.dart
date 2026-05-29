import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/search_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/coin_detail_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/coin_list_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/coin_list_item.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  late GoldenFileComparator previousGoldenFileComparator;

  setUpAll(() {
    previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.file(
        '${Directory.current.path}/test/features/crypto/presentation/widgets/visual_regression_test.dart',
      ),
      precisionTolerance: 0.05,
    );
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDownAll(() {
    goldenFileComparator = previousGoldenFileComparator;
    GoogleFonts.config.allowRuntimeFetching = true;
  });

  testWidgets('Given dark theme, when coin row renders, then it matches golden',
      (tester) async {
    _setTestView(tester, const Size(390, 90));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: Center(
            child: CoinListItem(
              rank: 128,
              coin: Coin(
                id: 'ethereum',
                symbol: 'eth',
                name: 'Ethereum',
                currentPrice: 2495.42,
                marketCap: 301000000000,
                priceChangePercentage24h: -2.34,
                isFavorite: true,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CoinListItem),
      matchesGoldenFile('goldens/coin_list_item_dark.png'),
    );
  });

  testWidgets(
    'Given long detail content on a narrow screen, when rendered, then it does not overflow',
    (tester) async {
      _setTestView(tester, const Size(360, 780));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(
            body: SizedBox.expand(
              child: DetailContent(
                detail: CoinDetail(
                  id: 'very-long-market-asset-name',
                  symbol: 'superlongsymbol',
                  name:
                      'Extremely Long Cryptocurrency Name That Should Never Overflow',
                  currentPrice: 0.00000012345678,
                  marketCap: 123456789012345,
                  priceChangePercentage24h: 12345.67,
                  totalVolume: 98765432109876,
                  allTimeHigh: 999999999,
                  allTimeHighChangePercentage: -99.99,
                  allTimeLow: 0.00000001,
                  allTimeLowChangePercentage: 987654.32,
                  circulatingSupply: 123456789012345,
                  maxSupply: null,
                ),
                descriptionText:
                    'This is a deliberately long description used to verify that paragraph text wraps naturally on compact screens without pushing stat cards or headers outside their available layout.',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(DetailContent), findsOneWidget);
      expect(
          find.textContaining('EXTREMELY LONG CRYPTOCURRENCY'), findsWidgets);
      expect(find.text('MARKET STATS'), findsOneWidget);
      expect(find.text('MARKET CAP'), findsOneWidget);
      expect(find.text('MAX SUPPLY'), findsOneWidget);
      expect(
          find.textContaining('deliberately long description'), findsOneWidget);
    },
  );

  testWidgets(
    'Given English light theme, when full coin list page renders, then it matches golden',
    (tester) async {
      await _pumpCoinListGolden(
        tester,
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        goldenFile: 'goldens/coin_list_page_en_light.png',
      );
    },
  );

  testWidgets(
    'Given Myanmar dark theme, when full coin list page renders, then it matches golden',
    (tester) async {
      await _pumpCoinListGolden(
        tester,
        locale: const Locale('my'),
        themeMode: ThemeMode.dark,
        goldenFile: 'goldens/coin_list_page_my_dark.png',
      );
    },
  );

  testWidgets(
    'Given English light theme, when full detail page renders, then it matches golden',
    (tester) async {
      await _pumpCoinDetailGolden(
        tester,
        locale: const Locale('en'),
        themeMode: ThemeMode.light,
        goldenFile: 'goldens/coin_detail_page_en_light.png',
      );
    },
  );

  testWidgets(
    'Given Myanmar dark theme, when full detail page renders, then it matches golden',
    (tester) async {
      await _pumpCoinDetailGolden(
        tester,
        locale: const Locale('my'),
        themeMode: ThemeMode.dark,
        goldenFile: 'goldens/coin_detail_page_my_dark.png',
      );
    },
  );
}

void _setTestView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _pumpCoinListGolden(
  WidgetTester tester, {
  required Locale locale,
  required ThemeMode themeMode,
  required String goldenFile,
}) async {
  _setTestView(tester, const Size(390, 844));
  final repository = _GoldenRepository();
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
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: BlocProvider.value(
        value: viewModel,
        child: const CoinListPage(),
      ),
    ),
  );
  viewModel.add(const CoinListStarted());
  await tester.pump();
  await tester.pump();

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(CoinListPage), matchesGoldenFile(goldenFile));
}

Future<void> _pumpCoinDetailGolden(
  WidgetTester tester, {
  required Locale locale,
  required ThemeMode themeMode,
  required String goldenFile,
}) async {
  _setTestView(tester, const Size(390, 844));
  final repository = _GoldenRepository();
  final viewModel = CoinDetailViewModel(
    getCoinDetailUseCase: GetCoinDetailUseCase(repository),
    getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
    toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
  );
  addTearDown(viewModel.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: BlocProvider.value(
        value: viewModel,
        child: const CoinDetailPage(coinId: 'bitcoin'),
      ),
    ),
  );
  viewModel.add(const CoinDetailRequested('bitcoin'));
  await tester.pump();
  await tester.pump();

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(CoinDetailPage), matchesGoldenFile(goldenFile));
}

class _GoldenRepository implements CryptoRepository {
  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    return const Result.success(
      DataResult.remote([
        Coin(
          id: 'bitcoin',
          symbol: 'btc',
          name: 'Bitcoin',
          currentPrice: 100000,
          marketCap: 2000000000000,
          priceChangePercentage24h: 1.25,
        ),
        Coin(
          id: 'ethereum',
          symbol: 'eth',
          name: 'Ethereum',
          currentPrice: 2495.42,
          marketCap: 301000000000,
          priceChangePercentage24h: -2.34,
          isFavorite: true,
        ),
        Coin(
          id: 'solana',
          symbol: 'sol',
          name: 'Solana',
          currentPrice: 178.77,
          marketCap: 85000000000,
          priceChangePercentage24h: 4.11,
        ),
        Coin(
          id: 'chainlink',
          symbol: 'link',
          name: 'Chainlink',
          currentPrice: 16.81,
          marketCap: 10500000000,
          priceChangePercentage24h: -0.8,
        ),
        Coin(
          id: 'uniswap',
          symbol: 'uni',
          name: 'Uniswap',
          currentPrice: 9.22,
          marketCap: 5600000000,
          priceChangePercentage24h: 0.46,
        ),
        Coin(
          id: 'aave',
          symbol: 'aave',
          name: 'Aave',
          currentPrice: 268.44,
          marketCap: 4100000000,
          priceChangePercentage24h: -1.08,
        ),
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
          totalMarketCapUsd: 3000000000000,
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
        TrendingCoin(id: 'ethereum', name: 'Ethereum', symbol: 'eth'),
        TrendingCoin(id: 'solana', name: 'Solana', symbol: 'sol'),
      ]),
    );
  }

  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) async {
    return const Result.success(
      DataResult.remote(
        CoinDetail(
          id: 'bitcoin',
          symbol: 'btc',
          name: 'Bitcoin',
          description:
              'Bitcoin is a decentralized digital asset used for peer-to-peer value transfer and long-term market tracking.',
          homepage: 'https://bitcoin.org/',
          currentPrice: 100000,
          marketCap: 2000000000000,
          marketCapRank: 1,
          priceChangePercentage24h: 1.25,
          totalVolume: 48000000000,
          allTimeHigh: 108786,
          allTimeHighChangePercentage: -8.1,
          allTimeLow: 67.81,
          allTimeLowChangePercentage: 147000,
          circulatingSupply: 19800000,
          maxSupply: 21000000,
        ),
      ),
    );
  }

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) async {
    return const Result.success(DataResult.remote([]));
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) async {
    return Result.success(coinId == 'ethereum', source: ResultSource.local);
  }

  @override
  Future<Result<bool>> toggleFavorite(String coinId) async {
    return const Result.success(true, source: ResultSource.local);
  }
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  })  : assert(
          precisionTolerance >= 0 && precisionTolerance <= 1,
          'precisionTolerance must be between 0 and 1.',
        ),
        _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;

    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    final diffPercent = (result.diffPercent * 100).toStringAsFixed(2);
    final tolerancePercent = (_precisionTolerance * 100).toStringAsFixed(2);
    result.dispose();
    throw FlutterError(
      '$error\nDiff was $diffPercent%, above tolerance $tolerancePercent%.',
    );
  }
}
