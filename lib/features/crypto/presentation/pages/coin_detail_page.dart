import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/coin_detail.dart';
import '../bloc/coin_detail/coin_detail_bloc.dart';
import '../bloc/coin_detail/coin_detail_event.dart';
import '../bloc/coin_detail/coin_detail_state.dart';
import '../widgets/error_view.dart';
import '../widgets/favorite_button.dart';
import '../widgets/loading_view.dart';

class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({
    required this.coinId,
    super.key,
  });

  final String coinId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoinDetailBloc>()..add(CoinDetailRequested(coinId)),
      child: const _CoinDetailView(),
    );
  }
}

class _CoinDetailView extends StatelessWidget {
  const _CoinDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinDetailBloc, CoinDetailState>(
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
                        .read<CoinDetailBloc>()
                        .add(const CoinDetailFavoriteToggled());
                  },
                ),
            ],
          ),
          body: switch (state.status) {
            CoinDetailStatus.loading => const LoadingView(),
            CoinDetailStatus.failure => ErrorView(
                message: state.errorMessage ?? 'Unable to load coin detail',
                onRetry: detail == null
                    ? null
                    : () {
                        context
                            .read<CoinDetailBloc>()
                            .add(CoinDetailRequested(detail.id));
                      },
              ),
            CoinDetailStatus.initial => const LoadingView(),
            CoinDetailStatus.success => detail == null
                ? const ErrorView(message: 'Coin detail is unavailable')
                : _DetailContent(detail: detail),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final CoinDetail detail;

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
        if ((detail.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            _stripHtml(detail.description!),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ],
    );
  }

  String _stripHtml(String value) {
    return value.replaceAll(RegExp('<[^>]*>'), '').trim();
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
