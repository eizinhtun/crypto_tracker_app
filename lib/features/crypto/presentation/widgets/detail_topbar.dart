import 'package:crypto_tracker_app/core/constants/route_names.dart';
import 'package:crypto_tracker_app/core/localization/app_localizations.dart';
import 'package:crypto_tracker_app/core/theme/app_colors.dart';
import 'package:crypto_tracker_app/core/theme/app_text_styles.dart';
import 'package:crypto_tracker_app/features/crypto/domain/entities/coin_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailTopBar extends StatelessWidget {
  const DetailTopBar({
    required this.detail,
    required this.isFavorite,
    required this.onFavoritePressed,
    super.key,
  });

  final CoinDetail detail;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final rank = detail.marketCapRank;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left,
            tooltip: l10n.back,
            onPressed: () => _handleBack(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${detail.symbol.toUpperCase()}  ·  ${l10n.rankLabel(rank)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.topMeta(secondaryText),
              ),
            ),
          ),
          _CircleIconButton(
            icon: isFavorite ? Icons.star_sharp : Icons.star_border_sharp,
            tooltip: isFavorite ? l10n.removeFavorite : l10n.addFavorite,
            onPressed: onFavoritePressed,
          ),
        ],
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.goNamed(AppRouteNames.home);
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? AppColors.darkCardSoft
            : AppColors.lightCard.withValues(alpha: 0.75),
        shape: CircleBorder(
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
