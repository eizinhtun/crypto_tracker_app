import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/coin_detail.dart';
import '../viewmodels/coin_detail/coin_detail_view_model.dart';
import '../viewmodels/coin_detail/coin_detail_event.dart';
import '../viewmodels/coin_detail/coin_detail_state.dart';
import '../widgets/error_view.dart';
import '../widgets/favorite_button.dart';
import '../widgets/loading_view.dart';
import '../widgets/offline_banner.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({
    required this.coinId,
    super.key,
  });

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return _CoinDetailView(coinId: coinId);
  }
}

class _CoinDetailView extends StatelessWidget {
  const _CoinDetailView({required this.coinId});

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinDetailViewModel, CoinDetailState>(
      builder: (context, state) {
        final detail = state.detail;

        return Scaffold(
          appBar: AppBar(
            title: Text(detail?.name ?? 'Coin Detail'),
            actions: [
              if (detail != null)
                FavoriteButton(
                  isFavorite: state.isFavorite,
                  onPressed: () {
                    context
                        .read<CoinDetailViewModel>()
                        .add(const CoinDetailFavoriteToggled());
                  },
                ),
            ],
          ),
          body: switch (state.status) {
            CoinDetailStatus.loading => const LoadingView(),
            CoinDetailStatus.failure => ErrorView(
                message: state.errorMessage ?? 'Unable to load coin detail',
                onRetry: () {
                  context
                      .read<CoinDetailViewModel>()
                      .add(CoinDetailRequested(coinId));
                },
              ),
            CoinDetailStatus.initial => const LoadingView(),
            CoinDetailStatus.success => detail == null
                ? const ErrorView(message: 'Coin detail is unavailable')
                : Column(
                    children: [
                      if (state.isOffline) const OfflineBanner(),
                      Expanded(
                        child: _DetailContent(
                          detail: detail,
                          descriptionText: state.descriptionText,
                        ),
                      ),
                    ],
                  ),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.descriptionText,
  });

  final CoinDetail detail;
  final String descriptionText;

  @override
  Widget build(BuildContext context) {
    final change = detail.priceChangePercentage24h;
    final changeColor =
        (change ?? 0) >= 0 ? AppColors.positive : AppColors.negative;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CoinImage(url: detail.image),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(detail.symbol.toUpperCase()),
                  if (detail.marketCapRank != null)
                    Text('Market rank #${detail.marketCapRank}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(
              label: 'Price',
              value: CurrencyFormatter.usd(detail.currentPrice),
            ),
            _MetricTile(
              label: 'Market Cap',
              value: CurrencyFormatter.usd(detail.marketCap),
            ),
            _MetricTile(
              label: '24h Change',
              value: CurrencyFormatter.percentage(change),
              valueColor: changeColor,
            ),
          ],
        ),
        if ((detail.homepage ?? '').isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            detail.homepage!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        if (descriptionText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            descriptionText,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinImage extends StatelessWidget {
  const _CoinImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CircleAvatar(
        radius: 32,
        child: Icon(Icons.currency_bitcoin),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundImage: NetworkImage(url!),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }
}
