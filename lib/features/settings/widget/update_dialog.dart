import 'package:etf_oglasi/core/service/update_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/core/util/open_link.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

Future<void> showUpdateDialog(BuildContext context, AppRelease release) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final locale = AppLocalizations.of(dialogContext);
      return AlertDialog(
        title: Text(locale.updateAvailableTitle),
        content: Text(locale.updateAvailableMessage(version: release.version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(locale.later),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // The screen's context: the dialog's is gone after pop.
              openLink(context, release.url);
            },
            child: Text(locale.download),
          ),
        ],
      );
    },
  );
}

/// Checks GitHub for a new release at most once a week, when enabled in the
/// settings. A failed check (e.g. no internet) is ignored and tried again on
/// the next start.
Future<void> checkForUpdateOnStart(BuildContext context, WidgetRef ref) async {
  if (!ref.read(localSettingsProvider).checkForUpdates) return;
  try {
    if (!await UpdateService.isAutomaticCheckDue()) return;
    final version = await ref.read(appVersionProvider.future);
    final release = await ref.read(updateServiceProvider).findUpdate(version);
    // Also when the user picks "Later": ask again in a week.
    await UpdateService.markChecked();
    if (release != null && context.mounted) {
      await showUpdateDialog(context, release);
    }
  } catch (e) {
    debugPrint('Update check failed: $e');
  }
}

/// Checks right away and reports the result, also when there's no update.
Future<void> checkForUpdateNow(BuildContext context, WidgetRef ref) async {
  final locale = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final version = await ref.read(appVersionProvider.future);
    final release = await ref.read(updateServiceProvider).findUpdate(version);
    if (!context.mounted) return;
    if (release != null) {
      await showUpdateDialog(context, release);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(locale.upToDate)));
    }
  } catch (e) {
    debugPrint('Update check failed: $e');
    messenger.showSnackBar(SnackBar(content: Text(locale.updateCheckFailed)));
  }
}
