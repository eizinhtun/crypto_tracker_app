import 'package:hive/hive.dart';

import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';
import '../models/global_market_model.dart';
import '../models/trending_coin_model.dart';

abstract class CryptoCacheRecord {
  const CryptoCacheRecord({
    required this.schemaVersion,
    required this.cachedAt,
    required this.ttl,
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime cachedAt;
  final Duration ttl;

  DateTime get expiresAt => cachedAt.add(ttl);
  bool get isCurrentSchema => schemaVersion == currentSchemaVersion;

  bool isExpired(DateTime now) {
    return !expiresAt.isAfter(now.toUtc());
  }
}

final class CoinsCacheRecord extends CryptoCacheRecord {
  const CoinsCacheRecord({
    required this.coins,
    required super.cachedAt,
    required super.ttl,
    super.schemaVersion = CryptoCacheRecord.currentSchemaVersion,
  });

  final List<CoinCacheDto> coins;
}

final class CoinDetailCacheRecord extends CryptoCacheRecord {
  const CoinDetailCacheRecord({
    required this.detail,
    required super.cachedAt,
    required super.ttl,
    super.schemaVersion = CryptoCacheRecord.currentSchemaVersion,
  });

  final CoinDetailCacheDto detail;
}

final class TrendingCoinsCacheRecord extends CryptoCacheRecord {
  const TrendingCoinsCacheRecord({
    required this.coins,
    required super.cachedAt,
    required super.ttl,
    super.schemaVersion = CryptoCacheRecord.currentSchemaVersion,
  });

  final List<TrendingCoinCacheDto> coins;
}

final class GlobalMarketCacheRecord extends CryptoCacheRecord {
  const GlobalMarketCacheRecord({
    required this.market,
    required super.cachedAt,
    required super.ttl,
    super.schemaVersion = CryptoCacheRecord.currentSchemaVersion,
  });

  final GlobalMarketCacheDto market;
}

final class CoinCacheDto {
  const CoinCacheDto({
    required this.id,
    required this.symbol,
    required this.name,
    this.image,
    this.currentPrice,
    this.marketCap,
    this.priceChangePercentage24h,
    this.isFavorite = false,
  });

  factory CoinCacheDto.fromModel(CoinModel model) {
    return CoinCacheDto(
      id: model.id,
      symbol: model.symbol,
      name: model.name,
      image: model.image,
      currentPrice: model.currentPrice,
      marketCap: model.marketCap,
      priceChangePercentage24h: model.priceChangePercentage24h,
      isFavorite: model.isFavorite,
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String? image;
  final double? currentPrice;
  final double? marketCap;
  final double? priceChangePercentage24h;
  final bool isFavorite;

  CoinModel toModel() {
    return CoinModel(
      id: id,
      symbol: symbol,
      name: name,
      image: image,
      currentPrice: currentPrice,
      marketCap: marketCap,
      priceChangePercentage24h: priceChangePercentage24h,
      isFavorite: isFavorite,
    );
  }
}

final class CoinDetailCacheDto {
  const CoinDetailCacheDto({
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

  factory CoinDetailCacheDto.fromModel(CoinDetailModel model) {
    return CoinDetailCacheDto(
      id: model.id,
      symbol: model.symbol,
      name: model.name,
      image: model.image,
      description: model.description,
      homepage: model.homepage,
      currentPrice: model.currentPrice,
      marketCap: model.marketCap,
      marketCapRank: model.marketCapRank,
      priceChangePercentage24h: model.priceChangePercentage24h,
      totalVolume: model.totalVolume,
      allTimeHigh: model.allTimeHigh,
      allTimeHighChangePercentage: model.allTimeHighChangePercentage,
      allTimeLow: model.allTimeLow,
      allTimeLowChangePercentage: model.allTimeLowChangePercentage,
      circulatingSupply: model.circulatingSupply,
      maxSupply: model.maxSupply,
    );
  }

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

  CoinDetailModel toModel() {
    return CoinDetailModel(
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
      totalVolume: totalVolume,
      allTimeHigh: allTimeHigh,
      allTimeHighChangePercentage: allTimeHighChangePercentage,
      allTimeLow: allTimeLow,
      allTimeLowChangePercentage: allTimeLowChangePercentage,
      circulatingSupply: circulatingSupply,
      maxSupply: maxSupply,
    );
  }
}

final class TrendingCoinCacheDto {
  const TrendingCoinCacheDto({
    required this.id,
    required this.name,
    required this.symbol,
    this.smallImage,
    this.marketCapRank,
    this.score,
  });

  factory TrendingCoinCacheDto.fromModel(TrendingCoinModel model) {
    return TrendingCoinCacheDto(
      id: model.id,
      name: model.name,
      symbol: model.symbol,
      smallImage: model.smallImage,
      marketCapRank: model.marketCapRank,
      score: model.score,
    );
  }

  final String id;
  final String name;
  final String symbol;
  final String? smallImage;
  final int? marketCapRank;
  final int? score;

  TrendingCoinModel toModel() {
    return TrendingCoinModel(
      id: id,
      name: name,
      symbol: symbol,
      smallImage: smallImage,
      marketCapRank: marketCapRank,
      score: score,
    );
  }
}

final class GlobalMarketCacheDto {
  const GlobalMarketCacheDto({
    required this.activeCryptocurrencies,
    required this.markets,
    required this.totalMarketCapUsd,
    required this.totalVolumeUsd,
    required this.marketCapChangePercentage24hUsd,
  });

  factory GlobalMarketCacheDto.fromModel(GlobalMarketModel model) {
    return GlobalMarketCacheDto(
      activeCryptocurrencies: model.activeCryptocurrencies,
      markets: model.markets,
      totalMarketCapUsd: model.totalMarketCapUsd,
      totalVolumeUsd: model.totalVolumeUsd,
      marketCapChangePercentage24hUsd: model.marketCapChangePercentage24hUsd,
    );
  }

  final int activeCryptocurrencies;
  final int markets;
  final double totalMarketCapUsd;
  final double totalVolumeUsd;
  final double marketCapChangePercentage24hUsd;

  GlobalMarketModel toModel() {
    return GlobalMarketModel(
      activeCryptocurrencies: activeCryptocurrencies,
      markets: markets,
      totalMarketCapUsd: totalMarketCapUsd,
      totalVolumeUsd: totalVolumeUsd,
      marketCapChangePercentage24hUsd: marketCapChangePercentage24hUsd,
    );
  }
}

abstract final class CryptoCacheAdapters {
  static const coinTypeId = 43;
  static const coinDetailTypeId = 44;
  static const trendingCoinTypeId = 45;
  static const globalMarketTypeId = 46;
  static const coinsRecordTypeId = 47;
  static const coinDetailRecordTypeId = 48;
  static const trendingCoinsRecordTypeId = 49;
  static const globalMarketRecordTypeId = 50;

  static void register() {
    _register(coinTypeId, CoinCacheDtoAdapter());
    _register(coinDetailTypeId, CoinDetailCacheDtoAdapter());
    _register(trendingCoinTypeId, TrendingCoinCacheDtoAdapter());
    _register(globalMarketTypeId, GlobalMarketCacheDtoAdapter());
    _register(coinsRecordTypeId, CoinsCacheRecordAdapter());
    _register(coinDetailRecordTypeId, CoinDetailCacheRecordAdapter());
    _register(trendingCoinsRecordTypeId, TrendingCoinsCacheRecordAdapter());
    _register(globalMarketRecordTypeId, GlobalMarketCacheRecordAdapter());
  }

  static void _register<T>(int typeId, TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}

class CoinCacheDtoAdapter extends TypeAdapter<CoinCacheDto> {
  @override
  int get typeId => CryptoCacheAdapters.coinTypeId;

  @override
  CoinCacheDto read(BinaryReader reader) {
    final values = reader.readList();
    return CoinCacheDto(
      id: values[0] as String? ?? '',
      symbol: values[1] as String? ?? '',
      name: values[2] as String? ?? '',
      image: values[3] as String?,
      currentPrice: _toDouble(values[4]),
      marketCap: _toDouble(values[5]),
      priceChangePercentage24h: _toDouble(values[6]),
      isFavorite: values[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CoinCacheDto obj) {
    writer.writeList([
      obj.id,
      obj.symbol,
      obj.name,
      obj.image,
      obj.currentPrice,
      obj.marketCap,
      obj.priceChangePercentage24h,
      obj.isFavorite,
    ]);
  }
}

class CoinDetailCacheDtoAdapter extends TypeAdapter<CoinDetailCacheDto> {
  @override
  int get typeId => CryptoCacheAdapters.coinDetailTypeId;

  @override
  CoinDetailCacheDto read(BinaryReader reader) {
    final values = reader.readList();
    return CoinDetailCacheDto(
      id: values[0] as String? ?? '',
      symbol: values[1] as String? ?? '',
      name: values[2] as String? ?? '',
      image: values[3] as String?,
      description: values[4] as String?,
      homepage: values[5] as String?,
      currentPrice: _toDouble(values[6]),
      marketCap: _toDouble(values[7]),
      marketCapRank: _toInt(values[8]),
      priceChangePercentage24h: _toDouble(values[9]),
      totalVolume: _toDouble(values[10]),
      allTimeHigh: _toDouble(values[11]),
      allTimeHighChangePercentage: _toDouble(values[12]),
      allTimeLow: _toDouble(values[13]),
      allTimeLowChangePercentage: _toDouble(values[14]),
      circulatingSupply: _toDouble(values[15]),
      maxSupply: _toDouble(values[16]),
    );
  }

  @override
  void write(BinaryWriter writer, CoinDetailCacheDto obj) {
    writer.writeList([
      obj.id,
      obj.symbol,
      obj.name,
      obj.image,
      obj.description,
      obj.homepage,
      obj.currentPrice,
      obj.marketCap,
      obj.marketCapRank,
      obj.priceChangePercentage24h,
      obj.totalVolume,
      obj.allTimeHigh,
      obj.allTimeHighChangePercentage,
      obj.allTimeLow,
      obj.allTimeLowChangePercentage,
      obj.circulatingSupply,
      obj.maxSupply,
    ]);
  }
}

class TrendingCoinCacheDtoAdapter extends TypeAdapter<TrendingCoinCacheDto> {
  @override
  int get typeId => CryptoCacheAdapters.trendingCoinTypeId;

  @override
  TrendingCoinCacheDto read(BinaryReader reader) {
    final values = reader.readList();
    return TrendingCoinCacheDto(
      id: values[0] as String? ?? '',
      name: values[1] as String? ?? '',
      symbol: values[2] as String? ?? '',
      smallImage: values[3] as String?,
      marketCapRank: _toInt(values[4]),
      score: _toInt(values[5]),
    );
  }

  @override
  void write(BinaryWriter writer, TrendingCoinCacheDto obj) {
    writer.writeList([
      obj.id,
      obj.name,
      obj.symbol,
      obj.smallImage,
      obj.marketCapRank,
      obj.score,
    ]);
  }
}

class GlobalMarketCacheDtoAdapter extends TypeAdapter<GlobalMarketCacheDto> {
  @override
  int get typeId => CryptoCacheAdapters.globalMarketTypeId;

  @override
  GlobalMarketCacheDto read(BinaryReader reader) {
    final values = reader.readList();
    return GlobalMarketCacheDto(
      activeCryptocurrencies: _toInt(values[0]) ?? 0,
      markets: _toInt(values[1]) ?? 0,
      totalMarketCapUsd: _toDouble(values[2]) ?? 0,
      totalVolumeUsd: _toDouble(values[3]) ?? 0,
      marketCapChangePercentage24hUsd: _toDouble(values[4]) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GlobalMarketCacheDto obj) {
    writer.writeList([
      obj.activeCryptocurrencies,
      obj.markets,
      obj.totalMarketCapUsd,
      obj.totalVolumeUsd,
      obj.marketCapChangePercentage24hUsd,
    ]);
  }
}

class CoinsCacheRecordAdapter extends TypeAdapter<CoinsCacheRecord> {
  @override
  int get typeId => CryptoCacheAdapters.coinsRecordTypeId;

  @override
  CoinsCacheRecord read(BinaryReader reader) {
    final values = reader.readList();
    return CoinsCacheRecord(
      schemaVersion: _toInt(values[0]) ?? -1,
      cachedAt: _toUtcDate(values[1]),
      ttl: _toDuration(values[2]),
      coins: _typedList<CoinCacheDto>(values[3]),
    );
  }

  @override
  void write(BinaryWriter writer, CoinsCacheRecord obj) {
    writer.writeList([
      obj.schemaVersion,
      obj.cachedAt.toUtc().toIso8601String(),
      obj.ttl.inMilliseconds,
      obj.coins,
    ]);
  }
}

class CoinDetailCacheRecordAdapter extends TypeAdapter<CoinDetailCacheRecord> {
  @override
  int get typeId => CryptoCacheAdapters.coinDetailRecordTypeId;

  @override
  CoinDetailCacheRecord read(BinaryReader reader) {
    final values = reader.readList();
    return CoinDetailCacheRecord(
      schemaVersion: _toInt(values[0]) ?? -1,
      cachedAt: _toUtcDate(values[1]),
      ttl: _toDuration(values[2]),
      detail: values[3] is CoinDetailCacheDto
          ? values[3] as CoinDetailCacheDto
          : const CoinDetailCacheDto(id: '', symbol: '', name: ''),
    );
  }

  @override
  void write(BinaryWriter writer, CoinDetailCacheRecord obj) {
    writer.writeList([
      obj.schemaVersion,
      obj.cachedAt.toUtc().toIso8601String(),
      obj.ttl.inMilliseconds,
      obj.detail,
    ]);
  }
}

class TrendingCoinsCacheRecordAdapter
    extends TypeAdapter<TrendingCoinsCacheRecord> {
  @override
  int get typeId => CryptoCacheAdapters.trendingCoinsRecordTypeId;

  @override
  TrendingCoinsCacheRecord read(BinaryReader reader) {
    final values = reader.readList();
    return TrendingCoinsCacheRecord(
      schemaVersion: _toInt(values[0]) ?? -1,
      cachedAt: _toUtcDate(values[1]),
      ttl: _toDuration(values[2]),
      coins: _typedList<TrendingCoinCacheDto>(values[3]),
    );
  }

  @override
  void write(BinaryWriter writer, TrendingCoinsCacheRecord obj) {
    writer.writeList([
      obj.schemaVersion,
      obj.cachedAt.toUtc().toIso8601String(),
      obj.ttl.inMilliseconds,
      obj.coins,
    ]);
  }
}

class GlobalMarketCacheRecordAdapter
    extends TypeAdapter<GlobalMarketCacheRecord> {
  @override
  int get typeId => CryptoCacheAdapters.globalMarketRecordTypeId;

  @override
  GlobalMarketCacheRecord read(BinaryReader reader) {
    final values = reader.readList();
    return GlobalMarketCacheRecord(
      schemaVersion: _toInt(values[0]) ?? -1,
      cachedAt: _toUtcDate(values[1]),
      ttl: _toDuration(values[2]),
      market: values[3] is GlobalMarketCacheDto
          ? values[3] as GlobalMarketCacheDto
          : const GlobalMarketCacheDto(
              activeCryptocurrencies: 0,
              markets: 0,
              totalMarketCapUsd: 0,
              totalVolumeUsd: 0,
              marketCapChangePercentage24hUsd: 0,
            ),
    );
  }

  @override
  void write(BinaryWriter writer, GlobalMarketCacheRecord obj) {
    writer.writeList([
      obj.schemaVersion,
      obj.cachedAt.toUtc().toIso8601String(),
      obj.ttl.inMilliseconds,
      obj.market,
    ]);
  }
}

List<T> _typedList<T>(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<T>().toList(growable: false);
}

DateTime _toUtcDate(dynamic value) {
  return DateTime.tryParse(value.toString())?.toUtc() ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

Duration _toDuration(dynamic value) {
  final milliseconds = _toInt(value) ?? 0;
  return Duration(milliseconds: milliseconds);
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
