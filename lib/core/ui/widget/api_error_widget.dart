import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';

class ApiErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  /// Picks a more specific message for an [ApiException].
  final Object? error;

  const ApiErrorWidget({super.key, required this.onRetry, this.error});

  static String message(AppLocalizations locale, Object? error) {
    if (error is! ApiException) return locale.loadingError;
    return switch (error.kind) {
      ApiErrorKind.network => locale.errorOffline,
      ApiErrorKind.certificate => locale.errorCertificate,
      ApiErrorKind.server => locale.errorServer,
      ApiErrorKind.other => locale.loadingError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 8),
          Text(
            message(locale, error),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(locale.tryAgain)),
        ],
      ),
    );
  }
}
