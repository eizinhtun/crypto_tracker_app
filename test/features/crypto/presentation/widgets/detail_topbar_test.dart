import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:crypto_tracker_app/features/crypto/presentation/widgets/detail_topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'Given detail route is the first page, when back is tapped, then markets route is shown',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/coins/ethereum',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Markets')),
          ),
          GoRoute(
            path: '/coins/:id',
            builder: (_, __) {
              return Scaffold(
                body: SafeArea(
                  child: DetailTopBar(
                    detail: const CoinDetail(
                      id: 'ethereum',
                      symbol: 'eth',
                      name: 'Ethereum',
                      marketCapRank: 2,
                    ),
                    isFavorite: false,
                    onFavoritePressed: () {},
                  ),
                ),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Markets'), findsOneWidget);
    },
  );
}
