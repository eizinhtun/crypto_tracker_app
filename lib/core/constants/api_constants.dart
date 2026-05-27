abstract final class ApiConstants {
  static const baseUrl = 'https://api.coingecko.com/api/v3';

  static const coinsMarkets = '/coins/markets';
  static const trending = '/search/trending';
  static const global = '/global';
  static const search = '/search';

  static String coinDetail(String coinId) {
    return '/coins/${Uri.encodeComponent(coinId)}';
  }
}
