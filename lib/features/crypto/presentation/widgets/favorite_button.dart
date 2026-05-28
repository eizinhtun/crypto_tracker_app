import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.isFavorite,
    this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip:
          isFavorite ? context.l10n.removeFavorite : context.l10n.addFavorite,
      onPressed: onPressed,
      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
      color: isFavorite ? AppColors.warning : null,
    );
  }
}
