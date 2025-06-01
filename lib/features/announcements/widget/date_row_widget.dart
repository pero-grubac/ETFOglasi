import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRowWidget extends StatelessWidget {
  final DateTime creationDate;
  final DateTime expirationDate;
  final TextStyle? style;

  const DateRowWidget({
    super.key,
    required this.creationDate,
    required this.expirationDate,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Kreirano: ${DateFormat('dd.MM.yyyy HH:mm').format(creationDate)}',
          style: style,
        ),
        Text(
          'Istek: ${DateFormat('dd.MM.yyyy HH:mm').format(expirationDate)}',
          style: style,
        ),
      ],
    );
  }
}
