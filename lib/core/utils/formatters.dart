// ─── Formatters ─────────────────────────────────────────────────────
// Number, currency, and display formatters.

import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Format currency: "$1,234.56"
  static String currency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Format compact currency: "$1.2K"
  static String compactCurrency(double amount, {String symbol = '\$'}) {
    final formatter =
        NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 0);
    return formatter.format(amount);
  }

  /// Format number with commas: "1,234"
  static String number(num value) {
    return NumberFormat('#,##0').format(value);
  }

  /// Format percentage: "85%"
  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Format duration: "2h 30m"
  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  /// Format trip duration: "5 days / 4 nights"
  static String tripDuration(int days) {
    final nights = days - 1;
    return '$days day${days == 1 ? '' : 's'} / '
        '$nights night${nights == 1 ? '' : 's'}';
  }

  /// Map currency code to symbol
  static String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'ETB':
        return 'Br';
      case 'KES':
        return 'KSh';
      case 'JPY':
        return '¥';
      case 'AED':
        return 'د.إ';
      case 'INR':
        return '₹';
      default:
        return code;
    }
  }
}
