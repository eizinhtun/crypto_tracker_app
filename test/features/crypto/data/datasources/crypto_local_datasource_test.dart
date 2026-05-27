import 'dart:io';

import 'package:crypto_tracker_app/core/constants/storage_keys.dart';
import 'package:crypto_tracker_app/features/crypto/data/cache/crypto_cache_records.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_local_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('crypto_local_test_');
    Hive.init(tempDir.path);
    CryptoCacheAdapters.register();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CryptoLocalDataSourceImpl', () {
    late Box<CoinsCacheRecord> coinsBox;
    late Box<CoinDetailCacheRecord> coinDetailsBox;
    late Box<TrendingCoinsCacheRecord> trendingBox;
    late Box<GlobalMarketCacheRecord> globalMarketBox;
    late Box<bool> favoritesBox;
    late CryptoLocalDataSourceImpl dataSource;
    late DateTime now;

    setUp(() async {
      final suffix = DateTime.now().microsecondsSinceEpoch;
      now = DateTime.utc(2026, 1, 1, 12);
      coinsBox = await Hive.openBox<CoinsCacheRecord>('coins_$suffix');
      coinDetailsBox =
          await Hive.openBox<CoinDetailCacheRecord>('details_$suffix');
      trendingBox =
          await Hive.openBox<TrendingCoinsCacheRecord>('trending_$suffix');
      globalMarketBox =
          await Hive.openBox<GlobalMarketCacheRecord>('global_$suffix');
      favoritesBox = await Hive.openBox<bool>('favorites_$suffix');

      dataSource = CryptoLocalDataSourceImpl(
        coinsBox: coinsBox,
        coinDetailsBox: coinDetailsBox,
        trendingBox: trendingBox,
        globalMarketBox: globalMarketBox,
        favoritesBox: favoritesBox,
        coinsTtl: const Duration(minutes: 5),
        trendingTtl: const Duration(minutes: 5),
        now: () => now,
      );
    });

    tearDown(() async {
      await Future.wait([
        coinsBox.deleteFromDisk(),
        coinDetailsBox.deleteFromDisk(),
        trendingBox.deleteFromDisk(),
        globalMarketBox.deleteFromDisk(),
        favoritesBox.deleteFromDisk(),
      ]);
    });

    test('Given paged coins, when cached, then typed cache record is stored',
        () async {
      await dataSource.cacheCoins(
        page: 1,
        coins: const [
          CoinModel(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
        ],
      );

      final cachedCoins = await dataSource.getCachedCoins(1);
      final record = coinsBox.get('${StorageKeys.coinsPagePrefix}1');

      expect(cachedCoins, hasLength(1));
      expect(cachedCoins.single.id, 'bitcoin');
      expect(record, isNotNull);
      final cacheRecord = record!;
      expect(cacheRecord.schemaVersion, CryptoCacheRecord.currentSchemaVersion);
      expect(cacheRecord.coins.single.id, 'bitcoin');
      expect(cacheRecord.cachedAt, now);
      expect(cacheRecord.ttl, const Duration(minutes: 5));
    });

    test('Given cached coins, when searched, then name and symbol are matched',
        () async {
      await dataSource.cacheCoins(
        page: 1,
        coins: const [
          CoinModel(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
          CoinModel(id: 'ethereum', symbol: 'eth', name: 'Ethereum'),
        ],
      );

      final cachedCoins = await dataSource.searchCachedCoins('eth');

      expect(cachedCoins.map((coin) => coin.id), ['ethereum']);
    });

    test('Given favorite coin id, when toggled, then Hive persistence updates',
        () async {
      expect(await dataSource.isFavorite('bitcoin'), isFalse);

      final firstToggle = await dataSource.toggleFavorite('bitcoin');
      final favoriteIdsAfterAdd = await dataSource.getFavoriteIds();

      expect(firstToggle, isTrue);
      expect(await dataSource.isFavorite('bitcoin'), isTrue);
      expect(favoriteIdsAfterAdd, {'bitcoin'});

      final secondToggle = await dataSource.toggleFavorite('bitcoin');

      expect(secondToggle, isFalse);
      expect(await dataSource.isFavorite('bitcoin'), isFalse);
    });

    test('Given expired cache record, when read, then record is invalidated',
        () async {
      await dataSource.cacheCoins(
        page: 1,
        coins: const [
          CoinModel(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
        ],
      );

      now = now.add(const Duration(minutes: 6));

      final cachedCoins = await dataSource.getCachedCoins(1);

      expect(cachedCoins, isEmpty);
      expect(coinsBox.get('${StorageKeys.coinsPagePrefix}1'), isNull);
    });

    test(
        'Given stale schema cache record, when read, then record is invalidated',
        () async {
      await coinsBox.put(
        '${StorageKeys.coinsPagePrefix}1',
        CoinsCacheRecord(
          coins: const [
            CoinCacheDto(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
          ],
          cachedAt: now,
          ttl: const Duration(minutes: 5),
          schemaVersion: CryptoCacheRecord.currentSchemaVersion - 1,
        ),
      );

      final cachedCoins = await dataSource.getCachedCoins(1);

      expect(cachedCoins, isEmpty);
      expect(coinsBox.get('${StorageKeys.coinsPagePrefix}1'), isNull);
    });

    test(
        'Given fresh and expired cache records, when cleanup runs, then only expired records are cleared',
        () async {
      await dataSource.cacheCoins(
        page: 1,
        coins: const [
          CoinModel(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin'),
        ],
      );

      now = now.add(const Duration(minutes: 6));
      await dataSource.cacheCoins(
        page: 2,
        coins: const [
          CoinModel(id: 'ethereum', symbol: 'eth', name: 'Ethereum'),
        ],
      );

      await dataSource.invalidateExpiredCache();

      expect(await dataSource.getCachedCoins(1), isEmpty);
      expect((await dataSource.getCachedCoins(2)).single.id, 'ethereum');
    });
  });
}
