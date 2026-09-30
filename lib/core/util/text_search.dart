const Map<String, String> _cyrillicToLatin = {
  'а': 'a',
  'б': 'b',
  'в': 'v',
  'г': 'g',
  'д': 'd',
  'ђ': 'dj',
  'е': 'e',
  'ж': 'z',
  'з': 'z',
  'и': 'i',
  'ј': 'j',
  'к': 'k',
  'л': 'l',
  'љ': 'lj',
  'м': 'm',
  'н': 'n',
  'њ': 'nj',
  'о': 'o',
  'п': 'p',
  'р': 'r',
  'с': 's',
  'т': 't',
  'ћ': 'c',
  'у': 'u',
  'ф': 'f',
  'х': 'h',
  'ц': 'c',
  'ч': 'c',
  'џ': 'dz',
  'ш': 's',
};

const Map<String, String> _latinDiacritics = {
  'č': 'c',
  'ć': 'c',
  'š': 's',
  'ž': 'z',
  'đ': 'dj',
};

/// Lower-cases [text], transliterates Serbian Cyrillic to Latin and removes
/// diacritics, so "Čas", "čas", "cas" and "Час" compare equal.
String normalizeForSearch(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    buffer.write(_cyrillicToLatin[char] ?? _latinDiacritics[char] ?? char);
  }
  return buffer.toString();
}

/// Whether every word of [query] occurs in one of [fields].
bool matchesSearch(String query, Iterable<String?> fields) {
  final words = normalizeForSearch(
    query,
  ).split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  if (words.isEmpty) return true;
  final haystack = normalizeForSearch(fields.whereType<String>().join('\n'));
  return words.every(haystack.contains);
}
