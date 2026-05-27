import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinModel', () {
    test('parses CoinGecko market JSON', () {
      final model = CoinModel.fromJson(const {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://example.com/btc.png',
        'current_price': 100000,
        'market_cap': 2000000000,
        'price_change_percentage_24h': 1.25,
      });

      expect(model.id, 'bitcoin');
      expect(model.symbol, 'btc');
      expect(model.name, 'Bitcoin');
      expect(model.currentPrice, 100000);
      expect(model.marketCap, 2000000000);
      expect(model.priceChangePercentage24h, 1.25);
    });

    test('is a data DTO and maps explicitly to a domain entity', () {
      const model = CoinModel(
        id: 'bitcoin',
        symbol: 'btc',
        name: 'Bitcoin',
        image: 'https://example.com/btc.png',
        currentPrice: 100000,
        marketCap: 2000000000,
        priceChangePercentage24h: 1.25,
      );

      expect(model, isNot(isA<Coin>()));

      final entity = model.toEntity(isFavorite: true);

      expect(entity, isA<Coin>());
      expect(entity.id, 'bitcoin');
      expect(entity.symbol, 'btc');
      expect(entity.name, 'Bitcoin');
      expect(entity.currentPrice, 100000);
      expect(entity.isFavorite, isTrue);
    });
  });
}
