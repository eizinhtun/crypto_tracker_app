abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'COINGECKO_BASE_URL',
    defaultValue: 'https://api.coingecko.com/api/v3',
  );
  static const apiKey = String.fromEnvironment('COINGECKO_API_KEY');
  static const apiKeyHeader = String.fromEnvironment(
    'COINGECKO_API_KEY_HEADER',
    defaultValue: 'x-cg-demo-api-key',
  );

  static const coinsMarkets = '/coins/markets';
  static const trending = '/search/trending';
  static const global = '/global';
  static const search = '/search';

  static String coinDetail(String coinId) {
    return '/coins/${Uri.encodeComponent(coinId)}';
  }
}
