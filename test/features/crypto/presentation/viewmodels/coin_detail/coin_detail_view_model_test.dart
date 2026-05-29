import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_tracker_app/core/error/result.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/domain/repositories/crypto_repository.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/get_favorite_status_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/domain/usecases/toggle_favorite_usecase.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_event.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_state.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('CoinDetailViewModel', () {
    late _MockCryptoRepository repository;

    setUp(() {
      repository = _MockCryptoRepository();
    });

    blocTest<CoinDetailViewModel, CoinDetailState>(
      'Given remote detail succeeds, when requested, then emits renderable detail state',
      build: () {
        _stubDetail(repository, source: ResultSource.remote);
        _stubFavorite(repository, isFavorite: false);
        return _createViewModel(repository);
      },
      act: (viewModel) => viewModel.add(const CoinDetailRequested('bitcoin')),
      expect: () => [
        isA<CoinDetailState>().having(
          (state) => state.status,
          'status',
          CoinDetailStatus.loading,
        ),
        isA<CoinDetailState>()
            .having((state) => state.status, 'status', CoinDetailStatus.success)
            .having((state) => state.detail?.id, 'detail id', 'bitcoin')
            .having(
              (state) => state.descriptionText,
              'descriptionText',
              'Bitcoin & Ethereum',
            )
            .having((state) => state.isOffline, 'isOffline', isFalse)
            .having((state) => state.hasCachedData, 'hasCachedData', isFalse),
      ],
    );

    blocTest<CoinDetailViewModel, CoinDetailState>(
      'Given cached detail succeeds, when requested, then emits offline detail state',
      build: () {
        _stubDetail(repository, source: ResultSource.cache);
        _stubFavorite(repository, isFavorite: true);
        return _createViewModel(repository);
      },
      act: (viewModel) => viewModel.add(const CoinDetailRequested('bitcoin')),
      expect: () => [
        isA<CoinDetailState>().having(
          (state) => state.status,
          'status',
          CoinDetailStatus.loading,
        ),
        isA<CoinDetailState>()
            .having((state) => state.status, 'status', CoinDetailStatus.success)
            .having((state) => state.isOffline, 'isOffline', isTrue)
            .having((state) => state.hasCachedData, 'hasCachedData', isTrue)
            .having((state) => state.isFavorite, 'isFavorite', isTrue)
            .having((state) => state.lastUpdated, 'lastUpdated', _cachedAt),
      ],
    );

    blocTest<CoinDetailViewModel, CoinDetailState>(
      'Given detail already loaded, when same coin is requested again, then repository is not called twice',
      build: () {
        _stubDetail(repository, source: ResultSource.remote);
        _stubFavorite(repository, isFavorite: false);
        return _createViewModel(repository);
      },
      act: (viewModel) {
        viewModel
          ..add(const CoinDetailRequested('bitcoin'))
          ..add(const CoinDetailRequested('bitcoin'));
      },
      expect: () => [
        isA<CoinDetailState>().having(
          (state) => state.status,
          'status',
          CoinDetailStatus.loading,
        ),
        isA<CoinDetailState>()
            .having((state) => state.status, 'status', CoinDetailStatus.success)
            .having((state) => state.detail?.id, 'detail id', 'bitcoin'),
      ],
      verify: (_) {
        verify(() => repository.getCoinDetail('bitcoin')).called(1);
        verify(() => repository.isFavorite('bitcoin')).called(1);
      },
    );
  });
}

CoinDetailViewModel _createViewModel(CryptoRepository repository) {
  return CoinDetailViewModel(
    getCoinDetailUseCase: GetCoinDetailUseCase(repository),
    getFavoriteStatusUseCase: GetFavoriteStatusUseCase(repository),
    toggleFavoriteUseCase: ToggleFavoriteUseCase(repository),
  );
}

void _stubDetail(
  _MockCryptoRepository repository, {
  required ResultSource source,
}) {
  when(() => repository.getCoinDetail('bitcoin')).thenAnswer(
    (_) async => Result.success(
      DataResult(
        const CoinDetail(
          id: 'bitcoin',
          symbol: 'btc',
          name: 'Bitcoin',
          description: '<p>Bitcoin &amp; <strong>Ethereum</strong></p>',
        ),
        source: source,
        lastUpdated: source == ResultSource.cache ? _cachedAt : null,
      ),
    ),
  );
}

final _cachedAt = DateTime.utc(2026, 1, 1, 12);

void _stubFavorite(
  _MockCryptoRepository repository, {
  required bool isFavorite,
}) {
  when(() => repository.isFavorite('bitcoin')).thenAnswer(
    (_) async => Result.success(isFavorite, source: ResultSource.local),
  );
}

class _MockCryptoRepository extends Mock implements CryptoRepository {}
