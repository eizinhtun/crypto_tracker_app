import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../viewmodels/coin_list/coin_list_view_model.dart';
import '../viewmodels/coin_list/coin_list_event.dart';
import '../viewmodels/coin_list/coin_list_state.dart';
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
  late final ScrollController _scrollController;

  CoinListViewModel get _viewModel => context.read<CoinListViewModel>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    _viewModel.add(
      CoinListScrollChanged(
        pixels: position.pixels,
        maxScrollExtent: position.maxScrollExtent,
      ),
    );
  }

  Future<void> _onRefresh() async {
    _viewModel.add(const CoinListRefreshRequested());
    await _viewModel.stream.firstWhere(
      (state) => state.status != CoinListStatus.refreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: BlocBuilder<CoinListViewModel, CoinListState>(
        builder: (context, state) {
          if (state.status == CoinListStatus.loading && state.coins.isEmpty) {
            return const LoadingView();
          }

          if (state.status == CoinListStatus.failure && state.coins.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? 'Unable to load coins',
              onRetry: () => _viewModel.add(const CoinListStarted()),
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
                      _viewModel.add(CoinListSearchChanged(query));
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
                            _viewModel.add(CoinListFavoriteToggled(coin.id));
                          },
                        );
                      },
                      childCount: state.coins.length +
                          (state.status == CoinListStatus.loadingMore ? 1 : 0),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
