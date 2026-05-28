import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/trending_coin.dart';
import 'coin_network_image.dart';

class TrendingCoinSection extends StatelessWidget {
  const TrendingCoinSection({
    required this.coins,
    super.key,
  });

  final List<TrendingCoin> coins;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = _TrendingColors.from(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 14,
                color: colors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                l10n.trending24h,
                style: AppTextStyles.sectionLabel(colors.muted),
              ),
              const Spacer(),
              Text(
                l10n.coinCount(coins.length),
                style: AppTextStyles.statLabel(colors.muted),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: coins.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final coin = coins[index];

              return _TrendingCoinCard(coin: coin);
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TrendingCoinCard extends StatelessWidget {
  const _TrendingCoinCard({required this.coin});

  final TrendingCoin coin;

  @override
  Widget build(BuildContext context) {
    final colors = _TrendingColors.from(context);

    return Container(
      width: 172,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CoinNetworkImage(
                url: coin.smallImage,
                size: 32,
                iconSize: 18,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.symbol.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.coinMeta(colors.primaryText),
                    ),
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.coinMeta(colors.secondaryText),
                    ),
                  ],
                ),
              ),
              if (coin.marketCapRank != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.badgeBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${coin.marketCapRank}',
                    style: AppTextStyles.rank(colors.muted),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  coin.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.coinMeta(colors.primaryText),
                ),
              ),
              if (coin.score != null)
                _ScoreBadge(score: coin.score!, colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.score,
    required this.colors,
  });

  final int score;
  final _TrendingColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:
            AppColors.positive.withValues(alpha: colors.isDark ? 0.18 : 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$score',
        style: AppTextStyles.percentageBadge(AppColors.positive),
      ),
    );
  }
}

class _TrendingColors {
  const _TrendingColors({
    required this.isDark,
    required this.card,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.muted,
    required this.badgeBackground,
  });

  final bool isDark;
  final Color card;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color muted;
  final Color badgeBackground;

  static _TrendingColors from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _TrendingColors(
      isDark: isDark,
      card: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      primaryText:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      secondaryText:
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      muted: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
      badgeBackground: isDark
          ? AppColors.darkCardSoft
          : AppColors.lightBorder.withValues(alpha: 0.55),
    );
  }
}
