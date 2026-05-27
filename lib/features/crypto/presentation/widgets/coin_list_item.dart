import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/coin.dart';
import 'favorite_button.dart';

class CoinListItem extends StatelessWidget {
  const CoinListItem({
    required this.coin,
    this.onTap,
    this.onFavoritePressed,
    super.key,
  });

  final Coin coin;
  final VoidCallback? onTap;
  final VoidCallback? onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final priceChange = coin.priceChangePercentage24h;
    final priceChangeColor =
        (priceChange ?? 0) >= 0 ? AppColors.positive : AppColors.negative;

    return ListTile(
      onTap: onTap,
      leading: _CoinImage(url: coin.image),
      title: Text(
        coin.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${coin.symbol.toUpperCase()} • MCap ${CurrencyFormatter.usd(coin.marketCap)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 148,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.usd(coin.currentPrice),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.percentage(priceChange),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: priceChangeColor,
                        ),
                  ),
                ],
              ),
            ),
            FavoriteButton(
              isFavorite: coin.isFavorite,
              onPressed: onFavoritePressed,
            ),
          ],
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
      return const CircleAvatar(child: Icon(Icons.currency_bitcoin));
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(url!),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }
}
