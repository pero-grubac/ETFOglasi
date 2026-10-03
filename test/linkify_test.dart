import 'package:etf_oglasi/core/util/linkify.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _targets(String text) =>
    findLinks(text).map((l) => l.target).toList();

List<String> _texts(String text) =>
    findLinks(text).map((l) => text.substring(l.start, l.end)).toList();

void main() {
  test('finds a URL and leaves out the full stop after it', () {
    const text = 'Raspored je na https://efee.etf.unibl.org/raspored/.';

    expect(_texts(text), ['https://efee.etf.unibl.org/raspored/']);
    expect(_targets(text), ['https://efee.etf.unibl.org/raspored/']);
  });

  test('adds https to www links', () {
    expect(_targets('Vidi www.etf.unibl.org, hvala'), [
      'https://www.etf.unibl.org',
    ]);
  });

  test('finds e-mail addresses', () {
    const text = 'Pišite na ime.prezime@etf.unibl.org.';

    expect(_texts(text), ['ime.prezime@etf.unibl.org']);
    expect(_targets(text), ['mailto:ime.prezime@etf.unibl.org']);
  });

  test('handles several links and parentheses', () {
    const text =
        '(link: https://example.com/a) i https://en.wikipedia.org/wiki/X_(Y).';

    expect(_texts(text), [
      'https://example.com/a',
      'https://en.wikipedia.org/wiki/X_(Y)',
    ]);
  });

  test('ignores plain text, dates and times', () {
    expect(findLinks('Ispit 12.10.2026. u 10:15, sala 105.'), isEmpty);
    expect(findLinks('https:// nije link'), isEmpty);
    expect(findLinks('www.'), isEmpty);
  });
}
