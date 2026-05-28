import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
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
    final colors = _MarketsPageColors.from(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<CoinListViewModel, CoinListState>(
        builder: (context, state) {
          if (state.status == CoinListStatus.loading && state.coins.isEmpty) {
            return const LoadingView();
          }

          if (state.status == CoinListStatus.failure && state.coins.isEmpty) {
            return ErrorView(
              message: context.l10n.failureMessage(
                state.failureCategory,
                fallback: context.l10n.unableToLoadCoins,
              ),
              onRetry: () => _viewModel.add(const CoinListStarted()),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.isOffline)
                    SliverToBoxAdapter(
                      child: OfflineBanner(lastUpdated: state.lastUpdated),
                    ),
                  const SliverToBoxAdapter(child: _MarketsHeader()),
                  if (state.globalMarket != null)
                    SliverToBoxAdapter(
                      child: GlobalMarketCard(market: state.globalMarket!),
                    ),
                  SliverToBoxAdapter(
                    child: TrendingCoinSection(coins: state.trendingCoins),
                  ),
                  SliverToBoxAdapter(
                    child: CoinSearchBar(
                      initialValue: state.query,
                      onChanged: (query) {
                        _viewModel.add(CoinListSearchChanged(query));
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: _CoinTableHeader()),
                  if (state.coins.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        message: state.isOffline && state.query.isNotEmpty
                            ? context.l10n.emptyCachedCoins
                            : context.l10n.emptyCoins,
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.coins.length) {
                            return Container(
                              height: 72,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: colors.divider),
                                ),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ),
                            );
                          }

                          final coin = state.coins[index];
                          return CoinListItem(
                            coin: coin,
                            rank: index + 1,
                            onTap: () async {
                              await context.pushNamed(
                                AppRouteNames.coinDetail,
                                pathParameters: {'id': coin.id},
                              );
                              if (!mounted) {
                                return;
                              }
                              _viewModel.add(
                                CoinListFavoriteStatusRequested(coin.id),
                              );
                            },
                            onFavoritePressed: () {
                              _viewModel.add(CoinListFavoriteToggled(coin.id));
                            },
                          );
                        },
                        childCount: state.coins.length +
                            (state.status == CoinListStatus.loadingMore
                                ? 1
                                : 0),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MarketsHeader extends StatelessWidget {
  const _MarketsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = _MarketsPageColors.from(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ${l10n.liveCoinGecko}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.4,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.markets,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: colors.primaryText,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1.02,
                        letterSpacing: 0,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Tooltip(
            message: l10n.switchLanguage,
            child: Material(
              color: colors.card,
              shape: CircleBorder(
                side: BorderSide(color: colors.border),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  context.read<LocaleCubit>().toggle(
                        Localizations.localeOf(context),
                      );
                },
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.language,
                    color: colors.primaryText,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinTableHeader extends StatelessWidget {
  const _CoinTableHeader();

  @override
  Widget build(BuildContext context) {
    final colors = _MarketsPageColors.from(context);
    final l10n = context.l10n;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.1,
        );

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.divider),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#', style: labelStyle),
          ),
          Expanded(
            child: Text(l10n.asset, style: labelStyle),
          ),
          Text(l10n.price24h, style: labelStyle),
        ],
      ),
    );
  }
}

class _MarketsPageColors {
  const _MarketsPageColors({
    required this.background,
    required this.card,
    required this.border,
    required this.divider,
    required this.primaryText,
    required this.muted,
  });

  final Color background;
  final Color card;
  final Color border;
  final Color divider;
  final Color primaryText;
  final Color muted;

  static _MarketsPageColors from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _MarketsPageColors(
      background: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      card: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      divider: isDark
          ? AppColors.darkBorder.withValues(alpha: 0.62)
          : AppColors.lightBorder.withValues(alpha: 0.82),
      primaryText:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      muted: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
    );
  }
}
