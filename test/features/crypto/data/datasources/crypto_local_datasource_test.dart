import 'dart:io';

import 'package:crypto_tracker_app/core/constants/storage_keys.dart';
import 'package:crypto_tracker_app/core/database/cache_record.dart';
import 'package:crypto_tracker_app/features/crypto/data/datasources/crypto_local_datasource.dart';
import 'package:crypto_tracker_app/features/crypto/data/models/coin_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('crypto_local_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(CacheRecordAdapter.adapterTypeId)) {
      Hive.registerAdapter(CacheRecordAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CryptoLocalDataSourceImpl', () {
    late Box<CacheRecord> coinsBox;
    late Box<CacheRecord> coinDetailsBox;
    late Box<CacheRecord> trendingBox;
    late Box<CacheRecord> globalMarketBox;
    late Box<bool> favoritesBox;
    late CryptoLocalDataSourceImpl dataSource;
    late DateTime now;

    setUp(() async {
      final suffix = DateTime.now().microsecondsSinceEpoch;
      now = DateTime.utc(2026, 1, 1, 12);
      coinsBox = await Hive.openBox<CacheRecord>('coins_$suffix');
      coinDetailsBox = await Hive.openBox<CacheRecord>('details_$suffix');
      trendingBox = await Hive.openBox<CacheRecord>('trending_$suffix');
      globalMarketBox = await Hive.openBox<CacheRecord>('global_$suffix');
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

    test('caches and reads paged coins', () async {
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
      expect(record!.cachedAt, now);
      expect(record.ttl, const Duration(minutes: 5));
    });

    test('searches cached coins by name or symbol', () async {
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

    test('toggles favorite state using local persistence', () async {
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

    test('invalidates expired cached records on read', () async {
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

    test('explicitly invalidates expired cache without clearing fresh records',
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
