abstract final class AppConstants {
  static const appName = 'Crypto Tracker';
  static const defaultCurrency = 'usd';
  static const firstPage = 1;
  static const defaultPageSize = 20;
  static const maxPageSize = 250;

  static const requestTimeout = Duration(seconds: 20);
  static const debounceDuration = Duration(milliseconds: 350);
  static const paginationScrollThreshold = 300.0;

  static const coinsCacheTtl = Duration(minutes: 5);
  static const trendingCacheTtl = Duration(minutes: 10);
  static const globalMarketCacheTtl = Duration(minutes: 10);
  static const coinDetailCacheTtl = Duration(hours: 1);
}
