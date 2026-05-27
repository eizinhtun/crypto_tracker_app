import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection_container.dart';
import '../features/crypto/presentation/pages/coin_detail_page.dart';
import '../features/crypto/presentation/pages/coin_list_page.dart';
import '../features/crypto/presentation/viewmodels/coin_detail/coin_detail_event.dart';
import '../features/crypto/presentation/viewmodels/coin_detail/coin_detail_view_model.dart';
import '../features/crypto/presentation/viewmodels/coin_list/coin_list_event.dart';
import '../features/crypto/presentation/viewmodels/coin_list/coin_list_view_model.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'coinList',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => sl<CoinListViewModel>()..add(const CoinListStarted()),
          child: const CoinListPage(),
        );
      },
    ),
    GoRoute(
      path: '/coins/:id',
      name: 'coinDetail',
      builder: (context, state) {
        final coinId = state.pathParameters['id'] ?? '';

        return BlocProvider(
          create: (_) =>
              sl<CoinDetailViewModel>()..add(CoinDetailRequested(coinId)),
          child: CoinDetailPage(coinId: coinId),
        );
      },
    ),
  ],
);
