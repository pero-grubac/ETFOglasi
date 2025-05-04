import 'package:flutter/material.dart';

class SpacedColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const SpacedColumn({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final widget = entry.value;
        return index < children.length - 1
            ? Column(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  widget,
                  SizedBox(height: spacing),
                ],
              )
            : widget;
      }).toList(),
    );
  }
}
