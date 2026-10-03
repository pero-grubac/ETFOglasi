class TextLink {
  final int start;
  final int end;

  /// What to open: the URL (with `https://` added for `www.` links) or a
  /// `mailto:` address.
  final String target;

  const TextLink(this.start, this.end, this.target);

  @override
  bool operator ==(Object other) =>
      other is TextLink &&
      other.start == start &&
      other.end == end &&
      other.target == target;

  @override
  int get hashCode => Object.hash(start, end, target);

  @override
  String toString() => 'TextLink($start, $end, $target)';
}

final RegExp _linkPattern = RegExp(
  r'(?:https?://|www\.)[^\s<>"]+|[\w.+-]+@[\w-]+(?:\.[\w-]+)+',
  caseSensitive: false,
);

/// Punctuation that usually ends a sentence rather than the link.
final RegExp _trailingPunctuation = RegExp(r'[.,;:!?)\]}"»“”]+$');

/// Web addresses and e-mail addresses in [text], in order.
List<TextLink> findLinks(String text) {
  final links = <TextLink>[];
  for (final match in _linkPattern.allMatches(text)) {
    var value = match.group(0)!;
    // Keep a closing parenthesis that belongs to the URL, e.g. wiki links.
    final trimmed = value.replaceFirst(_trailingPunctuation, '');
    if (trimmed.length < value.length &&
        value.substring(trimmed.length).startsWith(')') &&
        trimmed.contains('(')) {
      value = '$trimmed)';
    } else {
      value = trimmed;
    }
    if (value.isEmpty) continue;

    final lower = value.toLowerCase();
    final String target;
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      if (lower == 'http://' || lower == 'https://') continue;
      target = value;
    } else if (lower.startsWith('www.')) {
      if (!value.substring(4).contains('.')) continue;
      target = 'https://$value';
    } else {
      target = 'mailto:$value';
    }
    links.add(TextLink(match.start, match.start + value.length, target));
  }
  return links;
}
