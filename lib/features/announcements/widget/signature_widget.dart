import 'package:flutter/material.dart';

import '../../../core/gen/app_localizations.dart';

class SignatureWidget extends StatelessWidget {
  final String? signature;
  final TextStyle? style;

  const SignatureWidget({super.key, this.signature, this.style});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    if (signature == null) return const SizedBox.shrink();
    return Text(
      '${locale?.signature}: $signature',
      style: style,
    );
  }
}
