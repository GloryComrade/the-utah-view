const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

final _isoDate = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})');

/// Parses the leading `YYYY-MM-DD` of [raw]. Returns null if it isn't a
/// real calendar date.
DateTime? parseStoryDate(String raw) {
  final match = _isoDate.firstMatch(raw.trim());
  if (match == null) return null;
  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  if (month < 1 || month > 12 || day < 1) return null;
  final date = DateTime(year, month, day);
  // DateTime rolls Feb 31 over into March; reject that.
  if (date.month != month || date.day != day) return null;
  return date;
}

/// `2026-05-25` → `May 25, 2026`, matching the website.
///
/// Anything that isn't a valid date is returned as-is (trimmed), so the
/// reader still sees whatever the editor typed.
String formatStoryDate(String raw) {
  final date = parseStoryDate(raw);
  if (date == null) return raw.trim();
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

/// `Tuesday, October 6, 2026`, used under the masthead.
String formatMastheadDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} '
    '${date.day}, ${date.year}';

/// `2026-05` → `May 2026`. Used to label a monthly issue.
String formatIssueMonth(String raw) {
  final date = parseStoryDate(raw);
  if (date == null) return '';
  return '${_months[date.month - 1]} ${date.year}';
}

final _digits = RegExp(r'\d');
final _bareNumber = RegExp(r'^\d+$');

/// Normalises the free-text `read_time` field into a label like
/// `3 min read`.
///
/// Returns null when the field is empty or clearly isn't a duration (the
/// field is hand-typed in the CMS; one live story has an author's name in
/// it), so the byline drops the segment instead of printing nonsense.
String? formatReadTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value.length > 24 || !_digits.hasMatch(value)) {
    return null;
  }
  if (_bareNumber.hasMatch(value)) return '$value min read';
  if (value.toLowerCase().endsWith('read')) return value;
  return '$value read';
}

/// Two-digit list index: 0 → `01`.
String formatListIndex(int index) => (index + 1).toString().padLeft(2, '0');
