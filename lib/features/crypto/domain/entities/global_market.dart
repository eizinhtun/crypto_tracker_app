import 'package:equatable/equatable.dart';

class GlobalMarket extends Equatable {
  const GlobalMarket({
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

  @override
  List<Object?> get props => [
        activeCryptocurrencies,
        markets,
        totalMarketCapUsd,
        totalVolumeUsd,
        marketCapChangePercentage24hUsd,
      ];
}
