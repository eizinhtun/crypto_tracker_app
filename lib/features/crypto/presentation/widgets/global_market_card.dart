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
    final colors = _MarketColors.from(context);
    final change = market.marketCapChangePercentage24hUsd;
    final changeColor = change >= 0 ? AppColors.positive : AppColors.negative;

    return Container(
      height: 82,
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: [
          if (!colors.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: _MarketMetric(
              label: 'TOP 20  ·  24H',
              value: CurrencyFormatter.compactUsd(market.totalMarketCapUsd),
              trailing: Text(
                CurrencyFormatter.percentage(change),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: colors.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            flex: 5,
            child: _MarketMetric(
              label: 'VOL 24H',
              value: CurrencyFormatter.compactUsd(market.totalVolumeUsd),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketMetric extends StatelessWidget {
  const _MarketMetric({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _MarketColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.muted,
                letterSpacing: 2.0,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      height: 1,
                    ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: trailing,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MarketColors {
  const _MarketColors({
    required this.isDark,
    required this.card,
    required this.border,
    required this.primaryText,
    required this.muted,
  });

  final bool isDark;
  final Color card;
  final Color border;
  final Color primaryText;
  final Color muted;

  static _MarketColors from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _MarketColors(
      isDark: isDark,
      card: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      primaryText:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      muted: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
    );
  }
}
