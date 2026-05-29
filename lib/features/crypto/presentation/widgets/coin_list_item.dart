import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/coin.dart';
import 'coin_network_image.dart';

class CoinListItem extends StatelessWidget {
  const CoinListItem({
    required this.coin,
    required this.rank,
    this.onTap,
    this.onFavoritePressed,
    super.key,
  });

  final Coin coin;
  final int rank;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final colors = _CoinRowColors.from(context);
    final priceChange = coin.priceChangePercentage24h;
    final isPositive = (priceChange ?? 0) >= 0;
    final l10n = context.l10n;
    final priceChangeColor =
        isPositive ? AppColors.positive : AppColors.negative;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.divider),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$rank',
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.rank(colors.muted),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CoinNetworkImage(
                url: coin.image,
                size: 38,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CoinIdentity(coin: coin, colors: colors),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip:
                      coin.isFavorite ? l10n.removeFavorite : l10n.addFavorite,
                  onPressed: onFavoritePressed,
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  color: coin.isFavorite ? AppColors.positive : colors.muted,
                  icon: Icon(
                    coin.isFavorite
                        ? Icons.star_sharp
                        : Icons.star_border_sharp,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 98,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.marketPrice(coin.currentPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.listPrice(colors.primaryText),
                    ),
                    const SizedBox(height: 5),
                    _ChangeBadge(
                      value: CurrencyFormatter.percentage(priceChange),
                      color: priceChangeColor,
                      isDark: colors.isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinIdentity extends StatelessWidget {
  const _CoinIdentity({
    required this.coin,
    required this.colors,
  });

  final Coin coin;
  final _CoinRowColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          coin.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.coinName(colors.primaryText),
        ),
        const SizedBox(height: 3),
        Text(
          '${coin.symbol.toUpperCase()}  ·  ${CurrencyFormatter.compactUsd(coin.marketCap)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.coinMeta(colors.secondaryText),
        ),
      ],
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 52),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.14),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        value,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.percentageBadge(color),
      ),
    );
  }
}

class _CoinRowColors {
  const _CoinRowColors({
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.muted,
    required this.divider,
  });

  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color muted;
  final Color divider;

  static _CoinRowColors from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _CoinRowColors(
      isDark: isDark,
      primaryText:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      secondaryText:
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      muted: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
      divider: isDark
          ? AppColors.darkBorder.withValues(alpha: 0.62)
          : AppColors.lightBorder.withValues(alpha: 0.82),
    );
  }
}
