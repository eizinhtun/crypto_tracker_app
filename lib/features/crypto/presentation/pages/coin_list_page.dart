import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/coin_list/coin_list_bloc.dart';
import '../bloc/coin_list/coin_list_event.dart';
import '../bloc/coin_list/coin_list_state.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/coin_search_bar.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/global_market_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/offline_banner.dart';
import '../widgets/trending_coin_section.dart';

class CoinListPage extends StatefulWidget {
  const CoinListPage({super.key});

  @override
  State<CoinListPage> createState() => _CoinListPageState();
}

class _CoinListPageState extends State<CoinListPage> {
  late final CoinListBloc _bloc;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<CoinListBloc>()..add(const CoinListStarted());
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _bloc.add(const CoinListNextPageRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc.add(const CoinListRefreshRequested());
    await _bloc.stream.firstWhere(
      (state) => state.status != CoinListStatus.refreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
        ),
        body: BlocBuilder<CoinListBloc, CoinListState>(
          builder: (context, state) {
            if (state.status == CoinListStatus.loading && state.coins.isEmpty) {
              return const LoadingView();
            }

            if (state.status == CoinListStatus.failure && state.coins.isEmpty) {
              return ErrorView(
                message: state.errorMessage ?? 'Unable to load coins',
                onRetry: () => _bloc.add(const CoinListStarted()),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.isOffline)
                    const SliverToBoxAdapter(child: OfflineBanner()),
                  SliverToBoxAdapter(
                    child: CoinSearchBar(
                      initialValue: state.query,
                      onChanged: (query) {
                        _bloc.add(CoinListSearchChanged(query));
                      },
                    ),
                  ),
                  if (state.globalMarket != null)
                    SliverToBoxAdapter(
                      child: GlobalMarketCard(market: state.globalMarket!),
                    ),
                  SliverToBoxAdapter(
                    child: TrendingCoinSection(coins: state.trendingCoins),
                  ),
                  if (state.coins.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(message: 'No coins found'),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.coins.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final coin = state.coins[index];
                          return CoinListItem(
                            coin: coin,
                            onTap: () => context.go('/coins/${coin.id}'),
                            onFavoritePressed: () {
                              _bloc.add(CoinListFavoriteToggled(coin.id));
                            },
                          );
                        },
                        childCount: state.coins.length +
                            (state.status == CoinListStatus.loadingMore
                                ? 1
                                : 0),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
