import 'package:flutter/material.dart';

import '../../../core/gen/app_localizations.dart';

/// Common layout of the schedule picker dialogs.
class ScheduleSettingsDialog extends StatelessWidget {
  const ScheduleSettingsDialog({
    super.key,
    required this.children,
    required this.onSelect,
    required this.onSave,
    required this.showSelect,
  });

  final List<Widget> children;
  final VoidCallback? onSelect;
  final VoidCallback? onSave;
  final bool showSelect;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  locale.selectSchedule,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...children,
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(locale.cancel),
                    ),
                    if (showSelect)
                      ElevatedButton(
                        onPressed: onSelect,
                        child: Text(locale.select),
                      ),
                    ElevatedButton(onPressed: onSave, child: Text(locale.save)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
