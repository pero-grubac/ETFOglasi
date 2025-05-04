import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedCrossFade(
        firstChild: Text(
          widget.text,
          style: widget.style,
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        secondChild: Text(
          widget.text,
          style: widget.style,
        ),
        crossFadeState:
            _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}
