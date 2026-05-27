import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static String usd(num? value) {
    if (value == null) {
      return '-';
    }

    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: value.abs() >= 1 ? 2 : 6,
    ).format(value);
  }

  static String compact(num? value) {
    if (value == null) {
      return '-';
    }

    return NumberFormat.compact(locale: 'en_US').format(value);
  }

  static String percentage(num? value) {
    if (value == null) {
      return '-';
    }

    return '${value.toStringAsFixed(2)}%';
  }
  static String compactUsd(num? value) {
  if (value == null) return '-';

  if (value >= 1000000000000) {
    return '\$${(value / 1000000000000).toStringAsFixed(2)}T';
  }

  if (value >= 1000000000) {
    return '\$${(value / 1000000000).toStringAsFixed(2)}B';
  }

  if (value >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(2)}M';
  }

  if (value >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(2)}K';
  }

  return '\$${value.toStringAsFixed(2)}';
}
}
