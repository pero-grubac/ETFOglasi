import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/local_settings.dart';

class SettingsScreen extends ConsumerWidget {
  static const id = 'settings_screen';

  const SettingsScreen({super.key});
  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    LocalSettings settings,
  ) {
    final locale = AppLocalizations.of(context);
    final isDarkMode = settings.themeMode == LocalSettings.darkMode;

    final languageOptions = [
      {'name': LocalSettings.srLatName, 'value': LocalSettings.srLatLang},
      {'name': LocalSettings.srCyrName, 'value': LocalSettings.srCyrLang},
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            SwitchListTile(
              title: Row(
                children: [
                  Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              value: isDarkMode,
              activeColor: Theme.of(context).colorScheme.secondary,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                final themeMode =
                    value ? LocalSettings.darkMode : LocalSettings.lightMode;
                ref.read(localSettingsProvider.notifier).updateTheme(themeMode);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            const SizedBox(height: 20),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: locale?.language,
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge!.color,
                ),
                value: settings.language,
                items: languageOptions.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang['value'],
                    child: Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(lang['name']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(localSettingsProvider.notifier)
                        .updateLanguage(value);
                  }
                },
                hint: Text(locale!.choseLanguage),
                isExpanded: true, // Makes dropdown take full width
                menuMaxHeight: 300, // Limits dropdown height
                borderRadius: BorderRadius.circular(8),
                dropdownColor: Theme.of(context).colorScheme.surface,
                icon: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(localSettingsProvider);
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(locale!.settings),
      ),
      body: _buildSettingsContent(context, ref, settings),
    );
  }
}
