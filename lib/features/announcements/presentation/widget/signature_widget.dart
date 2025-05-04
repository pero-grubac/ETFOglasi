import 'package:etf_oglasi/features/announcements/constants/strings.dart';
import 'package:flutter/material.dart';

class SignatureWidget extends StatelessWidget {
  final String? signature;
  final TextStyle? style;

  const SignatureWidget({super.key, this.signature, this.style});

  @override
  Widget build(BuildContext context) {
    if (signature == null) return const SizedBox.shrink();
    return Text(
      '${AnnouncementStrings.signature}: $signature',
      style: style,
    );
  }
}
