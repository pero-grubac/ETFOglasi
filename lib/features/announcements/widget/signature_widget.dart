import 'package:flutter/material.dart';

import '../../../core/gen/app_localizations.dart';

class SignatureWidget extends StatelessWidget {
  final String signature;
  final TextStyle? style;

  const SignatureWidget({super.key, required this.signature, this.style});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Text('${locale.signature}: $signature', style: style);
  }
}
