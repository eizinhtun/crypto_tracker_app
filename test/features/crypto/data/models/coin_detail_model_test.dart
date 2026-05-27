import 'package:crypto_tracker_app/features/crypto/data/models/coin_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoinDetailModel', () {
    test(
        'Given CoinGecko detail JSON, when parsed, then market data fields are mapped',
        () {
      final model = CoinDetailModel.fromJson(const {
        'id': 'ethereum',
        'symbol': 'eth',
        'name': 'Ethereum',
        'market_cap_rank': '2',
        'image': {
          'small': 'https://example.com/eth-small.png',
          'large': 'https://example.com/eth-large.png',
        },
        'description': {
          'en': '<p>Programmable money</p>',
        },
        'links': {
          'homepage': ['', 'https://ethereum.org/'],
        },
        'market_data': {
          'current_price': {'usd': 2095.85},
          'market_cap': {'usd': 253150000000},
          'total_volume': {'usd': '9780000000'},
          'price_change_percentage_24h': -0.13,
          'ath': {'usd': 4878},
          'ath_change_percentage': {'usd': -57.03},
          'atl': {'usd': 0.43},
          'atl_change_percentage': {'usd': 487306.98},
          'circulating_supply': 120280000,
          'max_supply': null,
        },
      });

      expect(model.id, 'ethereum');
      expect(model.symbol, 'eth');
      expect(model.name, 'Ethereum');
      expect(model.marketCapRank, 2);
      expect(model.image, 'https://example.com/eth-large.png');
      expect(model.description, '<p>Programmable money</p>');
      expect(model.homepage, 'https://ethereum.org/');
      expect(model.currentPrice, 2095.85);
      expect(model.marketCap, 253150000000);
      expect(model.totalVolume, 9780000000);
      expect(model.priceChangePercentage24h, -0.13);
      expect(model.allTimeHigh, 4878);
      expect(model.allTimeHighChangePercentage, -57.03);
      expect(model.allTimeLow, 0.43);
      expect(model.allTimeLowChangePercentage, 487306.98);
      expect(model.circulatingSupply, 120280000);
      expect(model.maxSupply, isNull);
    });

    test(
        'Given parsed detail model, when mapped, then domain entity is explicit',
        () {
      const model = CoinDetailModel(
        id: 'ethereum',
        symbol: 'eth',
        name: 'Ethereum',
        currentPrice: 2095.85,
        marketCapRank: 2,
      );

      final entity = model.toEntity();

      expect(entity.id, 'ethereum');
      expect(entity.symbol, 'eth');
      expect(entity.name, 'Ethereum');
      expect(entity.currentPrice, 2095.85);
      expect(entity.marketCapRank, 2);
    });
  });
}
