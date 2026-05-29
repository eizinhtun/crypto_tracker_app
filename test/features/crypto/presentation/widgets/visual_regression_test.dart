import 'dart:io';
import 'dart:typed_data';

import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/coin_list_item.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  late GoldenFileComparator previousGoldenFileComparator;

  setUpAll(() {
    previousGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.file(
        '${Directory.current.path}/test/features/crypto/presentation/widgets/visual_regression_test.dart',
      ),
      precisionTolerance: 0.05,
    );
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDownAll(() {
    goldenFileComparator = previousGoldenFileComparator;
    GoogleFonts.config.allowRuntimeFetching = true;
  });

  testWidgets('Given dark theme, when coin row renders, then it matches golden',
      (tester) async {
    tester.view.physicalSize = const Size(390, 90);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: Center(
            child: CoinListItem(
              rank: 128,
              coin: Coin(
                id: 'ethereum',
                symbol: 'eth',
                name: 'Ethereum',
                currentPrice: 2495.42,
                marketCap: 301000000000,
                priceChangePercentage24h: -2.34,
                isFavorite: true,
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CoinListItem),
      matchesGoldenFile('goldens/coin_list_item_dark.png'),
    );
  });

  testWidgets(
    'Given long detail content on a narrow screen, when rendered, then it does not overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(
            body: SizedBox.expand(
              child: DetailContent(
                detail: CoinDetail(
                  id: 'very-long-market-asset-name',
                  symbol: 'superlongsymbol',
                  name:
                      'Extremely Long Cryptocurrency Name That Should Never Overflow',
                  currentPrice: 0.00000012345678,
                  marketCap: 123456789012345,
                  priceChangePercentage24h: 12345.67,
                  totalVolume: 98765432109876,
                  allTimeHigh: 999999999,
                  allTimeHighChangePercentage: -99.99,
                  allTimeLow: 0.00000001,
                  allTimeLowChangePercentage: 987654.32,
                  circulatingSupply: 123456789012345,
                  maxSupply: null,
                ),
                descriptionText:
                    'This is a deliberately long description used to verify that paragraph text wraps naturally on compact screens without pushing stat cards or headers outside their available layout.',
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(DetailContent), findsOneWidget);
      expect(
          find.textContaining('EXTREMELY LONG CRYPTOCURRENCY'), findsWidgets);
      expect(find.text('MARKET STATS'), findsOneWidget);
      expect(find.text('MARKET CAP'), findsOneWidget);
      expect(find.text('MAX SUPPLY'), findsOneWidget);
      expect(
          find.textContaining('deliberately long description'), findsOneWidget);
    },
  );
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  })  : assert(
          precisionTolerance >= 0 && precisionTolerance <= 1,
          'precisionTolerance must be between 0 and 1.',
        ),
        _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;

    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    final diffPercent = (result.diffPercent * 100).toStringAsFixed(2);
    final tolerancePercent = (_precisionTolerance * 100).toStringAsFixed(2);
    result.dispose();
    throw FlutterError(
      '$error\nDiff was $diffPercent%, above tolerance $tolerancePercent%.',
    );
  }
}
