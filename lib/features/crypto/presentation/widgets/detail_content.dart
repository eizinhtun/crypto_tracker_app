import 'package:crypto_tracker_app/core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CoinLogo(url: detail.image),
            const SizedBox(width: 16),
            Expanded(
              child: _PriceHeader(
                name: detail.name,
                price: CurrencyFormatter.usd(detail.currentPrice),
                percentage: CurrencyFormatter.percentage(change),
                percentageColor: changeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const _SectionTitle('MARKET STATS'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.15,
          children: [
            _StatCard(
              label: 'MARKET CAP',
              value: CurrencyFormatter.compactUsd(detail.marketCap),
            ),
            _StatCard(
              label: 'VOLUME 24H',
              value: CurrencyFormatter.compactUsd(detail.totalVolume),
            ),
            _StatCard(
              label: 'ALL-TIME HIGH',
              value: CurrencyFormatter.usd(detail.allTimeHigh),
              subValue: CurrencyFormatter.percentage(
                  detail.allTimeHighChangePercentage),
              subValueColor: AppColors.negative,
            ),
            _StatCard(
              label: 'ALL-TIME LOW',
              value: CurrencyFormatter.usd(detail.allTimeLow),
              subValue: CurrencyFormatter.percentage(
                  detail.allTimeLowChangePercentage),
              subValueColor: AppColors.positive,
            ),
            _StatCard(
              label: 'CIRCULATING SUPPLY',
              value: _formatSupply(
                detail.circulatingSupply,
                detail.symbol,
              ),
            ),
            _StatCard(
              label: 'MAX SUPPLY',
              value: detail.maxSupply == null
                  ? '∞ uncapped'
                  : _formatSupply(detail.maxSupply, detail.symbol),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionTitle('ABOUT ${detail.name.toUpperCase()}'),
        const SizedBox(height: 12),
        Text(
          descriptionText.isNotEmpty
              ? descriptionText
              : 'No description available for this coin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: primaryText,
              ),
        ),
        if ((detail.homepage ?? '').isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            '○  SOURCE  ·  ${detail.homepage}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: secondaryText,
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
  });

  final String name;
  final String price;
  final String percentage;
  final Color percentageColor;

  @override
  Widget build(BuildContext context) {
    final isNegative = percentage.trim().startsWith('-');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: secondaryText,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                color: primaryText,
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
              '24h',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: secondaryText,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 2.2,
            fontWeight: FontWeight.w800,
            color: secondaryText,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryText =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
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
                  color: secondaryText,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryText,
                  fontWeight: FontWeight.w900,
                ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: subValueColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
