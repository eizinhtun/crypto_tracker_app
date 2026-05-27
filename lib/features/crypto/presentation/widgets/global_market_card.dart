import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/global_market.dart';

class GlobalMarketCard extends StatelessWidget {
  const GlobalMarketCard({
    required this.market,
    super.key,
  });

  final GlobalMarket market;

  @override
  Widget build(BuildContext context) {
    final change = market.marketCapChangePercentage24hUsd;
    final changeColor = change >= 0 ? AppColors.positive : AppColors.negative;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Market',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _Metric(
                  label: 'Market Cap',
                  value: CurrencyFormatter.usd(market.totalMarketCapUsd),
                ),
                _Metric(
                  label: '24h Volume',
                  value: CurrencyFormatter.usd(market.totalVolumeUsd),
                ),
                _Metric(
                  label: 'Coins',
                  value: CurrencyFormatter.compact(
                    market.activeCryptocurrencies,
                  ),
                ),
                _Metric(
                  label: '24h Change',
                  value: CurrencyFormatter.percentage(change),
                  valueColor: changeColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
