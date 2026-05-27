import 'package:go_router/go_router.dart';

import '../features/crypto/presentation/pages/coin_detail_page.dart';
import '../features/crypto/presentation/pages/coin_list_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'coinList',
      builder: (context, state) => const CoinListPage(),
    ),
    GoRoute(
      path: '/coins/:id',
      name: 'coinDetail',
      builder: (context, state) {
        return CoinDetailPage(
          coinId: state.pathParameters['id'] ?? '',
        );
      },
    ),
  ],
);
