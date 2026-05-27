import 'package:equatable/equatable.dart';

class CoinDetail extends Equatable {
  const CoinDetail({
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
    this.totalVolume,
    this.allTimeHigh,
    this.allTimeHighChangePercentage,
    this.allTimeLow,
    this.allTimeLowChangePercentage,
    this.circulatingSupply,
    this.maxSupply,
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

  final double? totalVolume;
  final double? allTimeHigh;
  final double? allTimeHighChangePercentage;
  final double? allTimeLow;
  final double? allTimeLowChangePercentage;
  final double? circulatingSupply;
  final double? maxSupply;

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        image,
        description,
        homepage,
        currentPrice,
        marketCap,
        marketCapRank,
        priceChangePercentage24h,
        totalVolume,
        allTimeHigh,
        allTimeHighChangePercentage,
        allTimeLow,
        allTimeLowChangePercentage,
        circulatingSupply,
        maxSupply,
      ];
}
