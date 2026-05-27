import '../../domain/entities/trending_coin.dart';

class TrendingCoinModel extends TrendingCoin {
  const TrendingCoinModel({
    required super.id,
    required super.name,
    required super.symbol,
    super.smallImage,
    super.marketCapRank,
    super.score,
  });

  factory TrendingCoinModel.fromJson(Map<String, dynamic> json) {
    final item = json['item'] is Map
        ? Map<String, dynamic>.from(json['item'] as Map)
        : json;

    return TrendingCoinModel(
      id: item['id'] as String? ?? '',
      name: item['name'] as String? ?? '',
      symbol: item['symbol'] as String? ?? '',
      smallImage: item['small'] as String? ?? item['thumb'] as String?,
      marketCapRank: _toInt(item['market_cap_rank']),
      score: _toInt(item['score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'small': smallImage,
      'market_cap_rank': marketCapRank,
      'score': score,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString());
}
