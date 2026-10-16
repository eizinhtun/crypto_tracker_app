import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/localization/app_localizations.dart';
import '../viewmodels/favorites/favorites_view_model.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/error_view.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final model = context.read<FavoritesViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorites)),
      body: BlocConsumer<FavoritesViewModel, FavoritesState>(
        listenWhen: (previous, current) =>
            current.failure != null &&
            previous.failure != current.failure &&
            current.coins.isNotEmpty,
        listener: (context, state) => ScaffoldMessenger.of(context)
            .showSnackBar(
                SnackBar(content: Text(l10n.failureMessage(state.failure)))),
        builder: (context, state) {
          if (state.loading && state.coins.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.failure != null && state.coins.isEmpty) {
            return ErrorView(
                message: l10n.failureMessage(state.failure),
                onRetry: model.load);
          }
          final coins = state.visibleCoins;
          return RefreshIndicator(
            onRefresh: model.load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _search,
                          onChanged: model.search,
                          decoration: InputDecoration(
                            hintText: l10n.searchFavorites,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: state.query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: l10n.clearSearch,
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _search.clear();
                                      model.search('');
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<FavoriteSort>(
                          initialValue: state.sort,
                          isExpanded: true,
                          decoration:
                              InputDecoration(labelText: l10n.sortFavorites),
                          items: [
                            for (final sort in FavoriteSort.values)
                              DropdownMenuItem(
                                  value: sort,
                                  child: Text(
                                      switch (sort) {
                                        FavoriteSort.name => l10n.sortName,
                                        FavoriteSort.marketCap =>
                                          l10n.sortMarketCap,
                                        FavoriteSort.price => l10n.sortPrice,
                                        FavoriteSort.change => l10n.sortChange,
                                      },
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (sort) {
                            if (sort != null) model.sortBy(sort);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (coins.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              state.coins.isEmpty
                                  ? Icons.star_border
                                  : Icons.search_off,
                              size: 56,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                              state.coins.isEmpty
                                  ? l10n.emptyFavorites
                                  : l10n.noFavoriteMatches,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          if (state.coins.isEmpty)
                            Text(l10n.emptyFavoritesHint,
                                textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              if (state.coins.isEmpty) {
                                context.goNamed(AppRouteNames.home);
                              } else {
                                _search.clear();
                                model.search('');
                              }
                            },
                            child: Text(state.coins.isEmpty
                                ? l10n.browseMarkets
                                : l10n.clearSearch),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: coins.length,
                    itemBuilder: (context, index) {
                      final coin = coins[index];
                      return CoinListItem(
                        key: ValueKey(coin.id),
                        coin: coin,
                        rank: index + 1,
                        onFavoritePressed:
                            state.removing.contains(coin.id) || state.loading
                                ? null
                                : () => model.remove(coin.id),
                        onTap: () async {
                          await context.pushNamed(AppRouteNames.coinDetail,
                              pathParameters: {'id': coin.id});
                          if (context.mounted) await model.load();
                        },
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
