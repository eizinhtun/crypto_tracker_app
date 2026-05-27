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
}
