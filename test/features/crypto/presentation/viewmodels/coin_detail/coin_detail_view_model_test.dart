import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/global_market.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/trending_coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_state.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinDetailViewModel', () {
    test('maps HTML description into renderable state text', () async {
      final repository = _FakeCryptoRepository();
      final viewModel = CoinDetailViewModel(
        getCoinDetailUseCase: GetCoinDetailUseCase(repository),
        getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
        toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
      );
      addTearDown(viewModel.close);

      viewModel.add(const CoinDetailRequested('bitcoin'));

      final state = await viewModel.stream.firstWhere(
        (state) => state.status == CoinDetailStatus.success,
      );

      expect(state.detail?.id, 'bitcoin');
      expect(state.descriptionText, 'Bitcoin & Ethereum');
    });
  });
}

class _FakeCryptoRepository implements CryptoRepository {
  @override
  Future<Result<DataResult<CoinDetail>>> getCoinDetail(String coinId) async {
    return Result.success(
      DataResult.remote(
        CoinDetail(
          id: coinId,
          symbol: 'btc',
          name: 'Bitcoin',
          description: '<p>Bitcoin &amp; <strong>Ethereum</strong></p>',
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
