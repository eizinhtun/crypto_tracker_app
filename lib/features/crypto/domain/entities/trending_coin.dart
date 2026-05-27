import 'package:equatable/equatable.dart';

class TrendingCoin extends Equatable {
  const TrendingCoin({
    required this.id,
    required this.name,
    required this.symbol,
    this.smallImage,
    this.marketCapRank,
    this.score,
  });

  final String id;
  final String name;
  final String symbol;
  final String? smallImage;
  final int? marketCapRank;
  final int? score;

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        smallImage,
        marketCapRank,
        score,
      ];
}
