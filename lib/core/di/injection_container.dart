import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../features/crypto/data/datasources/crypto_local_datasource.dart';
import '../../features/crypto/data/datasources/crypto_remote_datasource.dart';
import '../../features/crypto/data/repositories/crypto_repository_impl.dart';
import '../../features/crypto/domain/repositories/crypto_repository.dart';
import '../../features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import '../../features/crypto/domain/usecases/get_coins_usecase.dart';
import '../../features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import '../../features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import '../../features/crypto/domain/usecases/get_global_market_usecase.dart';
import '../../features/crypto/domain/usecases/get_trending_coins_usecase.dart';
import '../../features/crypto/domain/usecases/search_coins_usecase.dart';
import '../../features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import '../../features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';
import '../../features/crypto/presentation/viewmodels/favorite/favorite_view_model.dart';
import '../database/cache_record.dart';
import '../database/hive_boxes.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<CryptoRepository>()) {
    return;
  }

  sl
    ..registerLazySingleton<Dio>(() => Dio())
    ..registerLazySingleton<DioClient>(() => DioClient(dio: sl()))
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(
      () => ConnectivityNetworkInfo(sl()),
    )
    ..registerLazySingleton<Box<CacheRecord>>(
      () => Hive.box<CacheRecord>(HiveBoxes.coins),
      instanceName: HiveBoxes.coins,
    )
    ..registerLazySingleton<Box<CacheRecord>>(
      () => Hive.box<CacheRecord>(HiveBoxes.coinDetails),
      instanceName: HiveBoxes.coinDetails,
    )
    ..registerLazySingleton<Box<CacheRecord>>(
      () => Hive.box<CacheRecord>(HiveBoxes.trending),
      instanceName: HiveBoxes.trending,
    )
    ..registerLazySingleton<Box<CacheRecord>>(
      () => Hive.box<CacheRecord>(HiveBoxes.globalMarket),
      instanceName: HiveBoxes.globalMarket,
    )
    ..registerLazySingleton<Box<bool>>(
      () => Hive.box<bool>(HiveBoxes.favorites),
      instanceName: HiveBoxes.favorites,
    )
    ..registerLazySingleton<CryptoRemoteDataSource>(
      () => CryptoRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CryptoLocalDataSource>(
      () => CryptoLocalDataSourceImpl(
        coinsBox: sl(instanceName: HiveBoxes.coins),
        coinDetailsBox: sl(instanceName: HiveBoxes.coinDetails),
        trendingBox: sl(instanceName: HiveBoxes.trending),
        globalMarketBox: sl(instanceName: HiveBoxes.globalMarket),
        favoritesBox: sl(instanceName: HiveBoxes.favorites),
      ),
    )
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
    ..registerLazySingleton(() => GetTrendingCoinsUseCase(sl()))
    ..registerLazySingleton(() => GetGlobalMarketUseCase(sl()))
    ..registerLazySingleton(() => SearchCoinsUseCase(sl()))
    ..registerLazySingleton(() => ToggleFavoriteUseCase(sl()))
    ..registerLazySingleton(() => GetFavoriteStatusUseCase(sl()))
    ..registerFactory(
      () => CoinListViewModel(
        getCoinsUseCase: sl(),
        getCryptoOverviewUseCase: sl(),
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
    )
    ..registerFactory(
      () => FavoriteViewModel(
        getFavoriteStatusUseCase: sl(),
        toggleFavoriteUseCase: sl(),
      ),
    );
}
