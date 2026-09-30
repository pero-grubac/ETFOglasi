import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/gen/app_localizations.dart';

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
    final locale = AppLocalizations.of(context);
    final format = DateFormat('dd.MM.yyyy HH:mm');
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 4,
      children: [
        Text(
          locale.createdAt(date: format.format(creationDate.toLocal())),
          style: style,
        ),
        Text(
          locale.expiresAt(date: format.format(expirationDate.toLocal())),
          style: style,
        ),
      ],
    );
  }
}
