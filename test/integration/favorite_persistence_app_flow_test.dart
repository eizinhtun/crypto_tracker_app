import 'dart:io';

import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/database/hive_boxes.dart';
import 'package:crypto_tracker_app/core/database/hive_initializer.dart';
import 'package:crypto_tracker_app/core/di/injection_container.dart';
import 'package:crypto_tracker_app/core/error/exceptions.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/network/network_info.dart';
import 'package:crypto_tracker_app/features/crypto/data/cache/crypto_cache_records.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_local_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_remote_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_detail_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/global_market_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/trending_coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/search_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/pages/coin_list_page.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_state.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('crypto_app_flow_test_');
    await resetDependencies(dispose: false);
    await Hive.close();
    Hive.resetAdapters();
    await HiveInitializer.init(path: tempDir.path);
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() async {
    await resetDependencies(dispose: false);
    await Hive.close();
    Hive.resetAdapters();
    GoogleFonts.config.allowRuntimeFetching = true;
    await tempDir.delete(recursive: true);
  });

  testWidgets(
    'Given favorite is saved, when app restarts offline, then cached favorite remains selected',
    (tester) async {
      final networkInfo = _MutableNetworkInfo(isConnected: true);

      _registerAppDependencies(
        networkInfo: networkInfo,
        remoteDataSource: const _FakeRemoteDataSource(),
      );
      final firstViewModel = await _createLoadedViewModel(tester);
      addTearDown(firstViewModel.close);
      await tester.pumpWidget(_TestMarketsApp(viewModel: firstViewModel));
      await tester.pump();

      expect(firstViewModel.state.coins.single.name, 'Bitcoin');
      await _scrollUntilFound(tester, find.byIcon(Icons.star_border_sharp));
      expect(find.byIcon(Icons.star_border_sharp), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_border_sharp));
      await _waitForFavoriteState(tester, firstViewModel, isFavorite: true);
      await tester.pump();

      expect(find.byIcon(Icons.star_sharp), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await resetDependencies(dispose: false);

      networkInfo.connected = false;
      _registerAppDependencies(
        networkInfo: networkInfo,
        remoteDataSource: const _FailingRemoteDataSource(),
      );
      final restartedViewModel = await _createLoadedViewModel(tester);
      addTearDown(restartedViewModel.close);
      await tester.pumpWidget(_TestMarketsApp(viewModel: restartedViewModel));
      await tester.pump();

      expect(restartedViewModel.state.isOffline, isTrue);
      expect(restartedViewModel.state.coins.single.isFavorite, isTrue);
      expect(find.textContaining('Showing cached data'), findsOneWidget);
      await _scrollUntilFound(tester, find.byIcon(Icons.star_sharp));
      expect(find.byIcon(Icons.star_sharp), findsOneWidget);
    },
  );
}

Future<CoinListViewModel> _createLoadedViewModel(WidgetTester tester) async {
  late CoinListViewModel viewModel;

  await tester.runAsync(() async {
    viewModel = sl<CoinListViewModel>();
    final loadedState = viewModel.stream.firstWhere(
      (state) =>
          state.status == CoinListStatus.success && state.coins.isNotEmpty,
    );
    viewModel.add(const CoinListStarted());
    await loadedState.timeout(const Duration(seconds: 3));
  });
  await tester.pump();

  final exception = tester.takeException();
  if (exception != null) {
    throw exception;
  }

  if (viewModel.state.status != CoinListStatus.success ||
      viewModel.state.coins.isEmpty) {
    fail(
      'Expected loaded coins, but state was '
      '${viewModel.state.status} with ${viewModel.state.coins.length} coins.',
    );
  }

  return viewModel;
}

Future<void> _waitForFavoriteState(
  WidgetTester tester,
  CoinListViewModel viewModel, {
  required bool isFavorite,
}) async {
  await tester.runAsync(() async {
    await viewModel.stream
        .firstWhere(
          (state) => state.coins.any((coin) => coin.isFavorite == isFavorite),
        )
        .timeout(const Duration(seconds: 3));
  });
}

Future<void> _scrollUntilFound(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    return;
  }

  await tester.scrollUntilVisible(
    finder,
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

class _TestMarketsApp extends StatelessWidget {
  const _TestMarketsApp({required this.viewModel});

  final CoinListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider.value(
        value: viewModel,
        child: const CoinListPage(),
      ),
    );
  }
}

void _registerAppDependencies({
  required NetworkInfo networkInfo,
  required CryptoRemoteDataSource remoteDataSource,
}) {
  sl
    ..registerLazySingleton<Box<CoinsCacheRecord>>(
      () => Hive.box<CoinsCacheRecord>(HiveBoxes.coins),
      instanceName: HiveBoxes.coins,
    )
    ..registerLazySingleton<Box<CoinDetailCacheRecord>>(
      () => Hive.box<CoinDetailCacheRecord>(HiveBoxes.coinDetails),
      instanceName: HiveBoxes.coinDetails,
    )
    ..registerLazySingleton<Box<TrendingCoinsCacheRecord>>(
      () => Hive.box<TrendingCoinsCacheRecord>(HiveBoxes.trending),
      instanceName: HiveBoxes.trending,
    )
    ..registerLazySingleton<Box<GlobalMarketCacheRecord>>(
      () => Hive.box<GlobalMarketCacheRecord>(HiveBoxes.globalMarket),
      instanceName: HiveBoxes.globalMarket,
    )
    ..registerLazySingleton<Box<bool>>(
      () => Hive.box<bool>(HiveBoxes.favorites),
      instanceName: HiveBoxes.favorites,
    )
    ..registerLazySingleton<CryptoRemoteDataSource>(() => remoteDataSource)
    ..registerLazySingleton<CryptoLocalDataSource>(
      () => CryptoLocalDataSourceImpl(
        coinsBox: sl(instanceName: HiveBoxes.coins),
        coinDetailsBox: sl(instanceName: HiveBoxes.coinDetails),
        trendingBox: sl(instanceName: HiveBoxes.trending),
        globalMarketBox: sl(instanceName: HiveBoxes.globalMarket),
        favoritesBox: sl(instanceName: HiveBoxes.favorites),
      ),
    )
    ..registerLazySingleton<NetworkInfo>(() => networkInfo)
    ..registerLazySingleton<CryptoRepository>(
      () => CryptoRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => GetCoinsUseCase(sl()))
    ..registerLazySingleton(() => GetCoinDetailUseCase(sl()))
    ..registerLazySingleton(() => GetCryptoOverviewUseCase(sl()))
    ..registerLazySingleton(() => SearchCoinsUseCase(sl()))
    ..registerLazySingleton(() => ToggleFavoriteUseCase(sl()))
    ..registerLazySingleton(() => GetFavoriteStatusUseCase(sl()))
    ..registerFactory(
      () => CoinListViewModel(
        getCoinsUseCase: sl(),
        getCryptoOverviewUseCase: sl(),
        getFavoriteStatusUseCase: sl(),
        searchCoinsUseCase: sl(),
        toggleFavoriteUseCase: sl(),
      ),
    )
    ..registerFactory(
      () => CoinDetailViewModel(
        getCoinDetailUseCase: sl(),
        getFavoriteStatusUseCase: sl(),
        toggleFavoriteUseCase: sl(),
      ),
    );
}

class _MutableNetworkInfo implements NetworkInfo {
  _MutableNetworkInfo({required bool isConnected}) : connected = isConnected;

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeRemoteDataSource implements CryptoRemoteDataSource {
  const _FakeRemoteDataSource();

  @override
  Future<List<CoinModel>> getCoins({
    required int page,
    required int perPage,
  }) async {
    if (page != AppConstants.firstPage) {
      return const [];
    }

    return const [
      CoinModel(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        currentPrice: 100000,
        marketCap: 2000000000000,
        priceChangePercentage24h: 1.5,
      ),
    ];
  }

  @override
  Future<GlobalMarketModel> getGlobalMarket() async {
    return const GlobalMarketModel(
      activeCryptocurrencies: 10000,
      markets: 1000,
      totalMarketCapUsd: 3000000000000,
      totalVolumeUsd: 90000000000,
      marketCapChangePercentage24hUsd: 1.2,
    );
  }

  @override
  Future<List<TrendingCoinModel>> getTrendingCoins() async {
    return const [
      TrendingCoinModel(id: 'bitcoin', name: 'Bitcoin', symbol: 'btc'),
    ];
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    return CoinDetailModel(id: coinId, symbol: 'btc', name: 'Bitcoin');
  }

  @override
  Future<List<CoinModel>> searchCoins(String query) async {
    return getCoins(
      page: AppConstants.firstPage,
      perPage: AppConstants.defaultPageSize,
    );
  }
}

class _FailingRemoteDataSource implements CryptoRemoteDataSource {
  const _FailingRemoteDataSource();

  @override
  Future<List<CoinModel>> getCoins({
    required int page,
    required int perPage,
  }) {
    throw const NetworkException('No internet connection');
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String coinId) {
    throw const NetworkException('No internet connection');
  }

  @override
  Future<GlobalMarketModel> getGlobalMarket() {
    throw const NetworkException('No internet connection');
  }

  @override
  Future<List<TrendingCoinModel>> getTrendingCoins() {
    throw const NetworkException('No internet connection');
  }

  @override
  Future<List<CoinModel>> searchCoins(String query) {
    throw const NetworkException('No internet connection');
  }
}
