import '../../domain/entities/coin_detail.dart';

class CoinDetailModel {
  const CoinDetailModel({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    this.description,
    this.homepage,
    this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.priceChangePercentage24h,
  });

  final String id;
  final String symbol;
  final String name;
  final String? image;
  final String? description;
  final String? homepage;
  final double? currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? priceChangePercentage24h;

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    final description = _asMap(json['description']);
    final image = _asMap(json['image']);
    final links = _asMap(json['links']);
    final marketData = _asMap(json['market_data']);
    final currentPrice = _asMap(marketData['current_price']);
    final marketCap = _asMap(marketData['market_cap']);

    return CoinDetailModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: image['large'] as String? ?? image['small'] as String?,
      description: description['en'] as String?,
      homepage: _firstNonEmptyString(links['homepage']),
      currentPrice: _toDouble(currentPrice['usd']),
      marketCap: _toDouble(marketCap['usd']),
      marketCapRank: _toInt(json['market_cap_rank']),
      priceChangePercentage24h:
          _toDouble(marketData['price_change_percentage_24h']),
    );
  }

  CoinDetail toEntity() {
    return CoinDetail(
      id: id,
      symbol: symbol,
      name: name,
      image: image,
      description: description,
      homepage: homepage,
      currentPrice: currentPrice,
      marketCap: marketCap,
      marketCapRank: marketCapRank,
      priceChangePercentage24h: priceChangePercentage24h,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': {'large': image},
      'description': {'en': description},
      'links': {
        'homepage': [homepage],
      },
      'market_data': {
        'current_price': {'usd': currentPrice},
        'market_cap': {'usd': marketCap},
        'price_change_percentage_24h': priceChangePercentage24h,
      },
      'market_cap_rank': marketCapRank,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}

String? _firstNonEmptyString(dynamic value) {
  if (value is Iterable) {
    for (final item in value) {
      if (item is String && item.isNotEmpty) {
        return item;
      }
    }
  }

  return null;
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
