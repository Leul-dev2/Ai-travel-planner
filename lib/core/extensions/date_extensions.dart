// ─── Date Extensions ────────────────────────────────────────────────
// Formatting and calculation helpers for DateTime.

import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  /// Format as "Jun 15, 2025"
  String get formatted => DateFormat('MMM dd, yyyy').format(this);

  /// Format as "Jun 15"
  String get shortFormatted => DateFormat('MMM dd').format(this);

  /// Format as "09:30"
  String get timeFormatted => DateFormat('HH:mm').format(this);

  /// Format as "Jun 15, 2025 • 09:30"
  String get dateTimeFormatted =>
      DateFormat('MMM dd, yyyy • HH:mm').format(this);

  /// Format as "3 days ago", "in 2 weeks", etc.
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.isNegative) {
      // Future
      final absDiff = diff.abs();
      if (absDiff.inDays > 30) return 'in ${absDiff.inDays ~/ 30} months';
      if (absDiff.inDays > 7) return 'in ${absDiff.inDays ~/ 7} weeks';
      if (absDiff.inDays > 0) return 'in ${absDiff.inDays} days';
      if (absDiff.inHours > 0) return 'in ${absDiff.inHours} hours';
      return 'soon';
    } else {
      // Past
      if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
      if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
      if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'just now';
    }
  }

  /// Days between this date and another.
  int daysUntil(DateTime other) => other.difference(this).inDays;

  /// Is today?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Is in the past?
  bool get isPast => isBefore(DateTime.now());

  /// Is in the future?
  bool get isFuture => isAfter(DateTime.now());
}
