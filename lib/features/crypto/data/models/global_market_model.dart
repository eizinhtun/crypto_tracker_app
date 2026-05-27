import '../../domain/entities/global_market.dart';

class GlobalMarketModel {
  const GlobalMarketModel({
    required this.activeCryptocurrencies,
    required this.markets,
    required this.totalMarketCapUsd,
    required this.totalVolumeUsd,
    required this.marketCapChangePercentage24hUsd,
  });

  final int activeCryptocurrencies;
  final int markets;
  final double totalMarketCapUsd;
  final double totalVolumeUsd;
  final double marketCapChangePercentage24hUsd;

  factory GlobalMarketModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return GlobalMarketModel(
      activeCryptocurrencies: _toInt(data['active_cryptocurrencies']) ?? 0,
      markets: _toInt(data['markets']) ?? 0,
      totalMarketCapUsd: _nestedDouble(data['total_market_cap'], 'usd') ?? 0,
      totalVolumeUsd: _nestedDouble(data['total_volume'], 'usd') ?? 0,
      marketCapChangePercentage24hUsd:
          _toDouble(data['market_cap_change_percentage_24h_usd']) ?? 0,
    );
  }

  GlobalMarket toEntity() {
    return GlobalMarket(
      activeCryptocurrencies: activeCryptocurrencies,
      markets: markets,
      totalMarketCapUsd: totalMarketCapUsd,
      totalVolumeUsd: totalVolumeUsd,
      marketCapChangePercentage24hUsd: marketCapChangePercentage24hUsd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_cryptocurrencies': activeCryptocurrencies,
      'markets': markets,
      'total_market_cap': {'usd': totalMarketCapUsd},
      'total_volume': {'usd': totalVolumeUsd},
      'market_cap_change_percentage_24h_usd': marketCapChangePercentage24hUsd,
    };
  }
}

double? _nestedDouble(dynamic value, String key) {
  if (value is Map) {
    return _toDouble(value[key]);
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
