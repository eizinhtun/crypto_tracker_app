import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Large page title: "Markets"
  static TextStyle pageTitle(Color color) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 34,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: -1.2,
      color: color,
    );
  }

  // Detail price: "$2,095.85"
  static TextStyle heroPrice(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 1.0,
      letterSpacing: -1.5,
      color: color,
    );
  }

  // List item price: "$76,764.00"
  static TextStyle listPrice(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.3,
      color: color,
    );
  }

  // Coin name: "Bitcoin", "Ethereum"
  static TextStyle coinName(Color color) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Small coin metadata: "BTC · $1.54T"
  static TextStyle coinMeta(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: color,
    );
  }

  // Uppercase section labels: "MARKET STATS", "ABOUT ETHEREUM"
  static TextStyle sectionLabel(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: 2.4,
      color: color,
    );
  }

  // Small card label: "MARKET CAP", "VOLUME 24H"
  static TextStyle statLabel(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: 1.8,
      color: color,
    );
  }

  // Stat value: "$253.15B", "120.28M ETH"
  static TextStyle statValue(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Percentage badge: "-0.13%"
  static TextStyle percentageBadge(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      height: 1.0,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Header small text: "ETH · RANK #2", "LIVE / COINGECKO"
  static TextStyle topMeta(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 1.6,
      color: color,
    );
  }

  // Body paragraph: About Ethereum
  static TextStyle body(Color color) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: -0.1,
      color: color,
    );
  }

  // Search hint: "Search coins"
  static TextStyle searchHint(Color color) {
    return GoogleFonts.spaceGrotesk(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: -0.2,
      color: color,
    );
  }

  // Table header: "#", "ASSET", "PRICE · 24H"
  static TextStyle tableHeader(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 2.2,
      color: color,
    );
  }

  // Rank number: "1", "2", "3"
  static TextStyle rank(Color color) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.0,
      color: color,
    );
  }
}
