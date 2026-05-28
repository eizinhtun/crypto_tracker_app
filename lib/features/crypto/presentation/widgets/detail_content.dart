import 'package:crypto_tracker_app/core/theme/app_colors.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/utils/currency_formatter.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:flutter/material.dart';

class DetailContent extends StatelessWidget {
  const DetailContent({
    required this.detail,
    required this.descriptionText,
    super.key,
  });

  final CoinDetail detail;
  final String descriptionText;

  @override
  Widget build(BuildContext context) {
    final change = detail.priceChangePercentage24h ?? 0;
    final isPositive = change >= 0;
    final changeColor = isPositive ? AppColors.positive : AppColors.negative;
    final colors = _DetailColors.from(context);
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CoinLogo(url: detail.image),
            const SizedBox(width: 16),
            Expanded(
              child: _PriceHeader(
                name: detail.name,
                price: CurrencyFormatter.marketPrice(detail.currentPrice),
                percentage: CurrencyFormatter.percentage(change),
                percentageColor: changeColor,
                changeLabel: l10n.hours24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _SectionTitle(l10n.marketStats),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 88,
          ),
          children: [
            _StatCard(
              label: l10n.marketCap,
              value: CurrencyFormatter.compactUsd(detail.marketCap),
            ),
            _StatCard(
              label: l10n.volume24h,
              value: CurrencyFormatter.compactUsd(detail.totalVolume),
            ),
            _StatCard(
              label: l10n.allTimeHigh,
              value: CurrencyFormatter.marketPrice(detail.allTimeHigh),
              subValue: CurrencyFormatter.percentage(
                  detail.allTimeHighChangePercentage),
              subValueColor: AppColors.negative,
            ),
            _StatCard(
              label: l10n.allTimeLow,
              value: CurrencyFormatter.marketPrice(detail.allTimeLow),
              subValue: CurrencyFormatter.percentage(
                  detail.allTimeLowChangePercentage),
              subValueColor: AppColors.positive,
            ),
            _StatCard(
              label: l10n.circulatingSupply,
              value: _formatSupply(
                detail.circulatingSupply,
                detail.symbol,
              ),
            ),
            _StatCard(
              label: l10n.maxSupply,
              value: detail.maxSupply == null
                  ? l10n.uncappedSupply
                  : _formatSupply(detail.maxSupply, detail.symbol),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionTitle(l10n.aboutCoin(detail.name)),
        const SizedBox(height: 12),
        Text(
          descriptionText.isNotEmpty ? descriptionText : l10n.noDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: colors.bodyText,
              ),
        ),
        if ((detail.homepage ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.sourceHost(_sourceHost(detail.homepage!)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: colors.secondaryText,
                ),
          ),
        ],
      ],
    );
  }

  String _formatSupply(num? value, String symbol) {
    if (value == null) return '-';

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B ${symbol.toUpperCase()}';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M ${symbol.toUpperCase()}';
    }

    return '${value.toStringAsFixed(2)} ${symbol.toUpperCase()}';
  }

  String _sourceHost(String homepage) {
    final host = Uri.tryParse(homepage)?.host;
    if (host == null || host.isEmpty) {
      return homepage;
    }

    return host.startsWith('www.') ? host.substring(4) : host;
  }
}

class _CoinLogo extends StatelessWidget {
  const _CoinLogo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Icon(Icons.currency_bitcoin, size: 36),
      );
    }

    return Image.network(
      url!,
      width: 44,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(Icons.currency_bitcoin, size: 40);
      },
    );
  }
}

class _PriceHeader extends StatelessWidget {
  const _PriceHeader({
    required this.name,
    required this.price,
    required this.percentage,
    required this.percentageColor,
    required this.changeLabel,
  });

  final String name;
  final String price;
  final String percentage;
  final Color percentageColor;
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    final isNegative = percentage.trim().startsWith('-');
    final colors = _DetailColors.from(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: colors.secondaryText,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 36,
                height: 1,
                letterSpacing: 0,
                color: colors.primaryText,
              ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: percentageColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isNegative ? '▼' : '▲'} $percentage',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: percentageColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              changeLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = _DetailColors.from(context);

    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
            color: colors.secondaryText,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.subValue,
    this.subValueColor,
  });

  final String label;
  final String value;
  final String? subValue;
  final Color? subValueColor;

  @override
  Widget build(BuildContext context) {
    final colors = _DetailColors.from(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 11),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.secondaryText,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 1),
            Text(
              subValue!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: subValueColor,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailColors {
  const _DetailColors({
    required this.card,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.bodyText,
  });

  final Color card;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color bodyText;

  static _DetailColors from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DetailColors(
      card: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      primaryText:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      secondaryText:
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      bodyText: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }
}
