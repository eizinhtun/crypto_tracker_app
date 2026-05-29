import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static bool isMyanmar(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'my';
  }

  // Large page title: "Markets" / Myanmar title
  static TextStyle pageTitle(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );
    }

    return _spaceGrotesk(
      fontSize: 34,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: -1.2,
      color: color,
    );
  }

  // Detail price: "$2,095.85"
  // Keep mono font for numbers in both English and Myanmar mode.
  static TextStyle heroPrice(Color color) {
    return _jetBrainsMono(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 1.0,
      letterSpacing: -1.5,
      color: color,
    );
  }

  // List item price: "$76,764.00"
  static TextStyle listPrice(Color color) {
    return _jetBrainsMono(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.3,
      color: color,
    );
  }

  // Coin name: "Bitcoin", "Ethereum"
  // Coin names are usually Latin, so keep Space Grotesk.
  static TextStyle coinName(Color color) {
    return _spaceGrotesk(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Small coin metadata: "BTC · $1.54T"
  // Keep mono because it contains symbol/numbers.
  static TextStyle coinMeta(Color color) {
    return _jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: color,
    );
  }

  // Uppercase section labels: "MARKET STATS", "ABOUT ETHEREUM"
  // If this text is localized into Myanmar, pass context.
  static TextStyle sectionLabel(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.45,
        color: color,
      );
    }

    return _jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 2.4,
      color: color,
    );
  }

  // Small card label: "MARKET CAP", "VOLUME 24H"
  // If translated to Myanmar, pass context.
  static TextStyle statLabel(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        color: color,
      );
    }

    return _jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: 1.8,
      color: color,
    );
  }

  // Stat value: "$253.15B", "120.28M ETH"
  // Keep mono for numbers.
  static TextStyle statValue(Color color) {
    return _jetBrainsMono(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Percentage badge: "-0.13%"
  static TextStyle percentageBadge(Color color) {
    return _jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Header small text: "ETH · RANK #2", "LIVE / COINGECKO"
  // Usually not localized, keep mono.
  static TextStyle topMeta(Color color, {BuildContext? context}) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
      );
    }

    return _jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 1.6,
      color: color,
    );
  }

  // Body paragraph / error / empty / offline messages
  static TextStyle body(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.65,
        color: color,
      );
    }

    return _spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: -0.1,
      color: color,
    );
  }

  // Search hint: "Search coins" / Myanmar search hint
  static TextStyle searchHint(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );
    }

    return _spaceGrotesk(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Table header: "#", "ASSET", "PRICE · 24H"
  // If table labels are localized, pass context.
  static TextStyle tableHeader(
    Color color, {
    BuildContext? context,
  }) {
    if (context != null && isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: color,
      );
    }

    return _jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 2.2,
      color: color,
    );
  }

  // Rank number: "1", "2", "3"
  static TextStyle rank(Color color) {
    return _jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.0,
      color: color,
    );
  }

  // General localized UI label
  // Use this for buttons, banners, helper texts.
  static TextStyle localizedUi(
    BuildContext context,
    Color color, {
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    if (isMyanmar(context)) {
      return _notoSansMyanmar(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.55,
        color: color,
      );
    }

    return _spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.3,
      letterSpacing: -0.1,
      color: color,
    );
  }

  static TextStyle _spaceGrotesk({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _jetBrainsMono({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _notoSansMyanmar({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double? letterSpacing,
  }) {
    if (!GoogleFonts.config.allowRuntimeFetching) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );
    }

    return GoogleFonts.notoSansMyanmar(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
