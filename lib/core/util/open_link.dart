import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../gen/app_localizations.dart';

/// Opens [url] in the browser (or the app that handles it) and shows a
/// snackbar when that isn't possible.
Future<void> openLink(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {}
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).linkOpenFailed)),
    );
  }
}
