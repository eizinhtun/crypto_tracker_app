import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_crypto_overview_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/search_coins_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_state.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('CoinListViewModel', () {
    late _MockCryptoRepository repository;

    setUp(() {
      repository = _MockCryptoRepository();
    });

    blocTest<CoinListViewModel, CoinListState>(
      'Given remote overview succeeds, when started, then emits online success state',
      build: () {
        _stubOverview(repository, source: ResultSource.remote);
        return _createViewModel(repository);
      },
      act: (viewModel) => viewModel.add(const CoinListStarted()),
      expect: () => [
        isA<CoinListState>()
            .having((state) => state.status, 'status', CoinListStatus.loading),
        isA<CoinListState>()
            .having((state) => state.status, 'status', CoinListStatus.success)
            .having((state) => state.coins.first.id, 'first coin id', 'bitcoin')
            .having((state) => state.isOffline, 'isOffline', isFalse),
      ],
      verify: (_) {
        verify(
          () => repository.getCoins(
            page: AppConstants.firstPage,
            perPage: AppConstants.defaultPageSize,
          ),
        ).called(1);
      },
    );

    blocTest<CoinListViewModel, CoinListState>(
      'Given cached overview succeeds, when started, then emits offline success state',
      build: () {
        _stubOverview(repository, source: ResultSource.cache);
        return _createViewModel(repository);
      },
      act: (viewModel) => viewModel.add(const CoinListStarted()),
      expect: () => [
        isA<CoinListState>()
            .having((state) => state.status, 'status', CoinListStatus.loading),
        isA<CoinListState>()
            .having((state) => state.status, 'status', CoinListStatus.success)
            .having((state) => state.coins.first.id, 'first coin id', 'bitcoin')
            .having((state) => state.isOffline, 'isOffline', isTrue),
      ],
    );

    blocTest<CoinListViewModel, CoinListState>(
      'Given rapid search input, when debounce completes, then only latest query is searched',
      build: () {
        when(() => repository.searchCoins('bitcoin')).thenAnswer(
          (_) async => const Result.success(DataResult.remote(_coins)),
        );
        return _createViewModel(repository);
      },
      act: (viewModel) {
        viewModel
          ..add(const CoinListSearchChanged('bit'))
          ..add(const CoinListSearchChanged('bitcoin'));
      },
      wait: AppConstants.debounceDuration + const Duration(milliseconds: 100),
      verify: (_) {
        verifyNever(() => repository.searchCoins('bit'));
        verify(() => repository.searchCoins('bitcoin')).called(1);
      },
    );

    blocTest<CoinListViewModel, CoinListState>(
      'Given a successful list, when favorite is toggled, then selected coin is updated',
      build: () {
        when(() => repository.toggleFavorite('bitcoin')).thenAnswer(
          (_) async => const Result.success(true, source: ResultSource.local),
        );
        return _createViewModel(repository);
      },
      seed: () => CoinListState.initial().copyWith(
        status: CoinListStatus.success,
        coins: _coins,
      ),
      act: (viewModel) =>
          viewModel.add(const CoinListFavoriteToggled('bitcoin')),
      expect: () => [
        isA<CoinListState>()
            .having((state) => state.coins.first.isFavorite, 'favorite', isTrue)
            .having((state) => state.status, 'status', CoinListStatus.success),
      ],
      verify: (_) {
        verify(() => repository.toggleFavorite('bitcoin')).called(1);
      },
    );

    blocTest<CoinListViewModel, CoinListState>(
      'Given scroll threshold is reached, when scroll changes, then next page is requested',
      build: () {
        when(
          () => repository.getCoins(
            page: 2,
            perPage: AppConstants.defaultPageSize,
          ),
        ).thenAnswer(
          (_) async => const Result.success(
            DataResult.remote([
              Coin(id: 'solana', symbol: 'sol', name: 'Solana'),
            ]),
          ),
        );
        return _createViewModel(repository);
      },
      seed: () => CoinListState.initial().copyWith(
        status: CoinListStatus.success,
        coins: _coins,
        page: 1,
      ),
      act: (viewModel) => viewModel.add(
        const CoinListScrollChanged(
          pixels: 700,
          maxScrollExtent: 1000,
        ),
      ),
      expect: () => [
        isA<CoinListState>().having(
          (state) => state.status,
          'status',
          CoinListStatus.loadingMore,
        ),
        isA<CoinListState>()
            .having((state) => state.status, 'status', CoinListStatus.success)
            .having((state) => state.coins.length, 'coin count', 2)
            .having((state) => state.page, 'page', 2),
      ],
      verify: (_) {
        verify(
          () => repository.getCoins(
            page: 2,
            perPage: AppConstants.defaultPageSize,
          ),
        ).called(1);
      },
    );
  });
}

CoinListViewModel _createViewModel(CryptoRepository repository) {
  return CoinListViewModel(
    getCoinsUseCase: GetCoinsUseCase(repository),
    getCryptoOverviewUseCase: GetCryptoOverviewUseCase(repository),
    searchCoinsUseCase: SearchCoinsUseCase(repository),
    toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
  );
}

void _stubOverview(
  _MockCryptoRepository repository, {
  required ResultSource source,
}) {
  when(
    () => repository.getCoins(
      page: AppConstants.firstPage,
      perPage: AppConstants.defaultPageSize,
    ),
  ).thenAnswer(
    (_) async => Result.success(
      DataResult(
        _coins,
        source: source,
      ),
    ),
  );
  when(() => repository.getTrendingCoins()).thenAnswer(
    (_) async => Result.success(
      DataResult(
        _trendingCoins,
        source: source,
      ),
    ),
  );
  when(() => repository.getGlobalMarket()).thenAnswer(
    (_) async => Result.success(
      DataResult(
        _globalMarket,
        source: source,
      ),
    ),
  );
}

const _coins = [
  Coin(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
];

const _trendingCoins = [
  TrendingCoin(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
];

const _globalMarket = GlobalMarket(
  activeCryptocurrencies: 10000,
  markets: 1000,
  totalMarketCapUsd: 2000000000000,
  totalVolumeUsd: 90000000000,
  marketCapChangePercentage24hUsd: -0.4,
);

class _MockCryptoRepository extends Mock implements CryptoRepository {}
