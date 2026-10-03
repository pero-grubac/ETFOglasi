import 'dart:async';

import 'package:etf_oglasi/core/service/update_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/core/util/open_link.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:etf_oglasi/features/schedule/widget/class_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/schedule/widget/room_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/screen/error_log_screen.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:etf_oglasi/features/settings/widget/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  static const id = 'settings_screen';

  const SettingsScreen({super.key});

  static const _newIssueUrl =
      'https://github.com/pero-grubac/ETFOglasi/issues/new';

  static const _languageOptions = [
    (name: LocalSettings.srLatName, value: LocalSettings.srLatLang),
    (name: LocalSettings.srCyrName, value: LocalSettings.srCyrLang),
    (name: LocalSettings.enName, value: LocalSettings.enLang),
  ];

  Future<void> _showScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    bool isClassSchedule,
  ) async {
    final result = await showDialog<ScheduleResult>(
      context: context,
      builder: (context) => isClassSchedule
          ? const ClassScheduleSettingsWidget(isSelect: false)
          : const RoomScheduleSettingsWidget(isSelect: false),
    );
    if (result == null || !context.mounted) return;

    final settingsNotifier = ref.read(localSettingsProvider.notifier);
    if (isClassSchedule) {
      unawaited(settingsNotifier.updateClassScheduleURL(result.url));
    } else {
      settingsNotifier.updateRoomScheduleId(result.url);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).settingsSaved)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(localSettingsProvider);
    final locale = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(locale.settings)),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              spacing: 20,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        locale.theme,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.wb_sunny),
                              label: Text(locale.themeLight),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.nightlight_round),
                              label: Text(locale.themeDark),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: const Icon(Icons.brightness_auto),
                              label: Text(locale.themeSystem),
                            ),
                          ],
                          selected: {settings.themeMode},
                          showSelectedIcon: false,
                          onSelectionChanged: (selection) => ref
                              .read(localSettingsProvider.notifier)
                              .updateTheme(selection.single),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: locale.language,
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                    ),
                    initialValue: settings.language,
                    items: [
                      for (final lang in _languageOptions)
                        DropdownMenuItem<String>(
                          value: lang.value,
                          child: Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(lang.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        unawaited(
                          ref
                              .read(localSettingsProvider.notifier)
                              .updateLanguage(value),
                        );
                      }
                    },
                    hint: Text(locale.choseLanguage),
                    isExpanded: true,
                    menuMaxHeight: 300,
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: colorScheme.surface,
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                TextButton(
                  onPressed: () => _showScheduleDialog(context, ref, true),
                  child: Text(locale.classSchedule),
                ),
                TextButton(
                  onPressed: () => _showScheduleDialog(context, ref, false),
                  child: Text(locale.hallSchedule),
                ),
                _AboutSection(
                  checkForUpdates: settings.checkForUpdates,
                  newIssueUrl: _newIssueUrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection({
    required this.checkForUpdates,
    required this.newIssueUrl,
  });

  final bool checkForUpdates;
  final String newIssueUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(locale.about, style: theme.textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(locale.appVersion(version: version ?? '…')),
            onTap: () => openLink(context, UpdateService.releasesPageUrl),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.system_update),
            title: Text(locale.checkForUpdates),
            subtitle: Text(locale.checkForUpdatesDescription),
            value: checkForUpdates,
            onChanged: (value) => ref
                .read(localSettingsProvider.notifier)
                .updateCheckForUpdates(value),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(locale.checkNow),
            onTap: () => checkForUpdateNow(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(locale.errorLog),
            onTap: () => Navigator.of(context).pushNamed(ErrorLogScreen.id),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(locale.reportProblem),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openLink(context, newIssueUrl),
          ),
        ],
      ),
    );
  }
}
