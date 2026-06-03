// ─── String Extensions ──────────────────────────────────────────────
// Utility methods on String.

extension StringExtensions on String {
  /// Capitalize first letter.
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Title case — capitalize first letter of each word.
  String get titleCase =>
      split(' ').map((w) => w.capitalize).join(' ');

  /// Truncate to max length with ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Check if string is a valid email.
  bool get isEmail {
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return regex.hasMatch(this);
  }

  /// Get initials from a name (e.g., "John Doe" → "JD").
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
