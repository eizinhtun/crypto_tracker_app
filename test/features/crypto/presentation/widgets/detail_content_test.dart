import 'package:crypto_tracker_app/core/theme/app_theme.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Given narrow detail layout, when stat cards render, then there is no overflow',
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
          home: const Scaffold(
            body: SizedBox.expand(
              child: DetailContent(
                detail: CoinDetail(
                  id: 'ethereum',
                  symbol: 'eth',
                  name: 'Ethereum',
                  currentPrice: 2095.85,
                  marketCap: 253150000000,
                  totalVolume: 9780000000,
                  allTimeHigh: 4878,
                  allTimeHighChangePercentage: -57.03,
                  allTimeLow: 0.43,
                  allTimeLowChangePercentage: 487306.98,
                  circulatingSupply: 120280000,
                ),
                descriptionText: 'Ethereum is a decentralized platform.',
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('MARKET STATS'), findsOneWidget);
    },
  );
}
