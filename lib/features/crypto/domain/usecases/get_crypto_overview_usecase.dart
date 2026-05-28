import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/result.dart';
import '../entities/crypto_overview.dart';
import '../repositories/crypto_repository.dart';

class GetCryptoOverviewUseCase {
  const GetCryptoOverviewUseCase(this.repository);

  final CryptoRepository repository;

  Future<Result<DataResult<CryptoOverview>>> call({
    int page = AppConstants.firstPage,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final safePage =
        page < AppConstants.firstPage ? AppConstants.firstPage : page;
    final safePerPage = perPage.clamp(1, AppConstants.maxPageSize).toInt();

    final coinsFuture = repository.getCoins(
      page: safePage,
      perPage: safePerPage,
    );
    final trendingFuture = repository.getTrendingCoins();
    final marketFuture = repository.getGlobalMarket();

    final coinsResult = await coinsFuture;
    final trendingResult = await trendingFuture;
    final marketResult = await marketFuture;

    switch (coinsResult) {
      case Success(value: final coinsDataResult):
        final trendingDataResult = switch (trendingResult) {
          Success(value: final value) => value,
          Error() => null,
        };
        final marketDataResult = switch (marketResult) {
          Success(value: final value) => value,
          Error() => null,
        };
        final isFromCache = coinsDataResult.isFromCache ||
            (trendingDataResult?.isFromCache ?? false) ||
            (marketDataResult?.isFromCache ?? false);
        final lastUpdated = _latestDate([
          coinsDataResult.lastUpdated,
          trendingDataResult?.lastUpdated,
          marketDataResult?.lastUpdated,
        ]);

        return Result.success(
          DataResult(
            CryptoOverview(
              coins: coinsDataResult.data,
              trendingCoins: trendingDataResult?.data ?? const [],
              globalMarket: marketDataResult?.data,
              page: safePage,
              perPage: safePerPage,
              warnings: [
                if (trendingResult case Error(failure: final failure))
                  failure.message,
                if (marketResult case Error(failure: final failure))
                  failure.message,
              ],
              warningCategories: [
                if (trendingResult case Error(failure: final failure))
                  failure.category,
                if (marketResult case Error(failure: final failure))
                  failure.category,
              ],
            ),
            source: isFromCache ? ResultSource.cache : ResultSource.remote,
            lastUpdated: isFromCache ? lastUpdated : null,
          ),
        );
      case Error(failure: final failure):
        return Result.failure(failure);
    }
  }

  DateTime? _latestDate(Iterable<DateTime?> dates) {
    DateTime? latest;

    for (final date in dates.whereType<DateTime>()) {
      if (latest == null || date.isAfter(latest)) {
        latest = date;
      }
    }

    return latest;
  }
}
