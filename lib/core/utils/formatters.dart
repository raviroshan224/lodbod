/// Display formatting used everywhere so currency, dates and units read the
/// same on every screen. Implemented by hand to avoid pulling in `intl` for
/// three small formats.
abstract final class Fmt {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// NPR with South Asian digit grouping: 18000 → "Rs. 18,000",
  /// 750000 → "Rs. 7,50,000".
  static String npr(num amount) => 'Rs. ${groupDigits(amount.round())}';

  /// Ends [text] with a full stop unless it already ends with punctuation,
  /// so names like "Gandaki Transport Co." don't get a double period.
  static String sentence(String text) =>
      RegExp(r'[.!?]$').hasMatch(text) ? text : '$text.';

  static String groupDigits(int value) {
    final negative = value < 0;
    final digits = value.abs().toString();
    if (digits.length <= 3) return negative ? '-$digits' : digits;

    final lastThree = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    final grouped = '${groups.join(',')},$lastThree';
    return negative ? '-$grouped' : grouped;
  }

  /// "14 Oct"
  static String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  /// "14 Oct 2026"
  static String date(DateTime d) => '${dayMonth(d)} ${d.year}';

  /// "07:00"
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// "14 Oct 2026, 07:00"
  static String dateTime(DateTime d) => '${date(d)}, ${time(d)}';

  /// "Sat, 14 Oct"
  static String weekdayDayMonth(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${dayMonth(d)}';
  }

  /// "Just now", "5 min ago", "3 h ago", "2 days ago", falling back to a date.
  static String relative(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.isNegative || diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    }
    return date(d);
  }

  /// Drops a trailing ".0" so 10.0 → "10" but 2.5 → "2.5".
  static String number(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(v * 10 == (v * 10).roundToDouble() ? 1 : 2);
  }

  static String days(int n) => n == 1 ? '1 day' : '$n days';

  /// "AS" for "Aarav Shrestha".
  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    return letters.join();
  }
}
