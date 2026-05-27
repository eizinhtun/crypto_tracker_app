import '../../domain/entities/coin.dart';

class CoinModel extends Coin {
  const CoinModel({
    required super.id,
    required super.symbol,
    required super.name,
    super.image,
    super.currentPrice,
    super.marketCap,
    super.priceChangePercentage24h,
    super.isFavorite,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      currentPrice: _toDouble(json['current_price']),
      marketCap: _toDouble(json['market_cap']),
      priceChangePercentage24h: _toDouble(json['price_change_percentage_24h']),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  factory CoinModel.fromSearchJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['large'] as String? ?? json['thumb'] as String?,
    );
  }

  factory CoinModel.fromEntity(Coin coin) {
    return CoinModel(
      id: coin.id,
      symbol: coin.symbol,
      name: coin.name,
      image: coin.image,
      currentPrice: coin.currentPrice,
      marketCap: coin.marketCap,
      priceChangePercentage24h: coin.priceChangePercentage24h,
      isFavorite: coin.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'price_change_percentage_24h': priceChangePercentage24h,
      'is_favorite': isFavorite,
    };
  }
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
