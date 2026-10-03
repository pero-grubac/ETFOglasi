import 'package:etf_oglasi/core/util/linkify.dart';
import 'package:etf_oglasi/core/util/open_link.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';

/// Text that collapses to [maxLines] with a "show more" toggle when it
/// doesn't fit. Web and e-mail addresses in it can be tapped.
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.style,
    required this.maxLines,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;
  List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers = [];
  }

  /// The text with links as tappable, underlined spans.
  TextSpan _buildSpan() {
    _disposeRecognizers();
    final text = widget.text;
    final links = findLinks(text);
    if (links.isEmpty) return TextSpan(text: text, style: widget.style);

    final children = <InlineSpan>[];
    var position = 0;
    for (final link in links) {
      if (link.start > position) {
        children.add(TextSpan(text: text.substring(position, link.start)));
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () => openLink(context, link.target);
      _recognizers.add(recognizer);
      children.add(
        TextSpan(
          text: text.substring(link.start, link.end),
          style: const TextStyle(decoration: TextDecoration.underline),
          recognizer: recognizer,
        ),
      );
      position = link.end;
    }
    if (position < text.length) {
      children.add(TextSpan(text: text.substring(position)));
    }
    return TextSpan(style: widget.style, children: children);
  }

  bool _overflows(TextSpan span, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [span],
      ),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final overflows = painter.didExceedMaxLines;
    painter.dispose();
    return overflows;
  }

  @override
  Widget build(BuildContext context) {
    final span = _buildSpan();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_overflows(span, constraints.maxWidth)) return Text.rich(span);

        final locale = AppLocalizations.of(context);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCrossFade(
                firstChild: Text.rich(
                  span,
                  maxLines: widget.maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text.rich(span),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              Text(
                _isExpanded ? locale.showLess : locale.showMore,
                style: widget.style?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
