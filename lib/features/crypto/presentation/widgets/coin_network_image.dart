import 'package:flutter/material.dart';

class CoinNetworkImage extends StatelessWidget {
  const CoinNetworkImage({
    required this.url,
    required this.size,
    this.iconSize,
    this.circular = true,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? url;
  final double size;
  final double? iconSize;
  final bool circular;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final safeUrl = url?.trim();
    if (safeUrl == null || safeUrl.isEmpty) {
      return _fallback();
    }

    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final image = Image.network(
      safeUrl,
      width: size,
      height: size,
      fit: fit,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }

        return _fallback();
      },
      errorBuilder: (_, __, ___) => _fallback(),
    );

    return circular ? ClipOval(child: image) : image;
  }

  Widget _fallback() {
    final icon = Icon(
      Icons.currency_bitcoin,
      size: iconSize ?? size * 0.58,
    );

    return SizedBox(
      width: size,
      height: size,
      child: circular ? CircleAvatar(child: icon) : icon,
    );
  }
}
