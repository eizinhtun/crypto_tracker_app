import 'package:crypto_tracker_app/core/constants/app_constants.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
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

void main() {
  group('CoinListViewModel', () {
    test('debounces search input and only searches for the latest query',
        () async {
      final repository = _FakeCryptoRepository();
      final viewModel = _createViewModel(repository);
      addTearDown(viewModel.close);

      viewModel
        ..add(const CoinListSearchChanged('bit'))
        ..add(const CoinListSearchChanged('bitcoin'));

      await Future<void>.delayed(
        AppConstants.debounceDuration + const Duration(milliseconds: 100),
      );

      expect(repository.searchQueries, ['bitcoin']);
      expect(viewModel.state.query, 'bitcoin');
    });

    test('decides when scroll position should request the next page', () async {
      final repository = _FakeCryptoRepository();
      final viewModel = _createViewModel(repository);
      addTearDown(viewModel.close);

      viewModel.add(
        const CoinListScrollChanged(
          pixels: 699,
          maxScrollExtent: 1000,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(repository.requestedCoinPages, isEmpty);

      viewModel.add(
        const CoinListScrollChanged(
          pixels: 700,
          maxScrollExtent: 1000,
        ),
      );

      await viewModel.stream.firstWhere(
        (state) => state.status == CoinListStatus.success,
      );

      expect(repository.requestedCoinPages, [2]);
    });
  });
}

CoinListViewModel _createViewModel(_FakeCryptoRepository repository) {
  return CoinListViewModel(
    getCoinsUseCase: GetCoinsUseCase(repository),
    getCryptoOverviewUseCase: GetCryptoOverviewUseCase(repository),
    searchCoinsUseCase: SearchCoinsUseCase(repository),
    toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
  );
}

class _FakeCryptoRepository implements CryptoRepository {
  final searchQueries = <String>[];
  final requestedCoinPages = <int>[];

  @override
  Future<Result<DataResult<List<Coin>>>> searchCoins(String query) async {
    searchQueries.add(query);
    return Result.success(
      DataResult.remote([
        Coin(
          id: query,
          symbol: query,
          name: query,
        ),
      ]),
    );
  }

  @override
  Future<Result<DataResult<List<Coin>>>> getCoins({
    required int page,
    required int perPage,
  }) async {
    requestedCoinPages.add(page);
    return Result.success(
      DataResult.remote(
        List.generate(
          perPage,
          (index) => Coin(
            id: 'coin-$page-$index',
            symbol: 'c$index',
            name: 'Coin $index',
          ),
        ),
      ),
    );
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
  Future<Result<DataResult<GlobalMarket>>> getGlobalMarket() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DataResult<List<TrendingCoin>>>> getTrendingCoins() {
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> isFavorite(String coinId) {
    throw UnimplementedError();
  }
}
