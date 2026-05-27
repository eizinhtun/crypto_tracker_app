import 'package:crypto_tracker_app/core/theme/app_colors.dart';
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
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left,
            onPressed: () => _handleBack(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${detail.symbol.toUpperCase()}  ·  ${rank == null ? 'RANK -' : 'RANK #$rank'}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: secondaryText,
                    ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: isFavorite ? Icons.star : Icons.star_border,
            onPressed: onFavoritePressed,
          ),
        ],
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router?.canPop() ?? false) {
      router!.pop();
      return;
    }

    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return;
    }

    router?.go('/');
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
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
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}
