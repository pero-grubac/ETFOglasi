import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerWidget {
  static const id = 'notification_screen';
  static const _actions = [
    'first_year',
    'second_year',
    'third_year',
    'fourth_year'
  ];
  const NotificationScreen({super.key});
  Widget _buildTimeField(
    String label,
    int initialValue,
    void Function(int) onChanged, {
    required int max,
  }) {
    final controller = TextEditingController(text: initialValue.toString());
    return SizedBox(
      width: 70,
      child: TextField(
        controller: controller,
        maxLength: 3,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: 'max $max',
          counterText: '',
        ),
        onChanged: (value) {
          final parsed = int.tryParse(value) ?? 0;
          final clamped = parsed.clamp(0, max);
          onChanged(clamped);
        },
      ),
    );
  }

  void _updateTime(WidgetRef ref, String key,
      {int? days, int? hours, int? minutes}) {
    final notifier = ref.read(localSettingsProvider.notifier);
    final current = ref
            .read(localSettingsProvider)
            .notificationTimeSettings[key] ??
        NotificationTimeSetting(enabled: true, days: 0, hours: 0, minutes: 0);

    final updated = Map<String, NotificationTimeSetting>.from(
        ref.read(localSettingsProvider).notificationTimeSettings);

    int newDays = days ?? current.days;
    int newHours = hours ?? current.hours;
    int newMinutes = minutes ?? current.minutes;
    if (newDays == 0 && newHours == 0 && newMinutes == 0) {
      newDays = 1;
    }

    updated[key] = NotificationTimeSetting(
      enabled: current.enabled,
      days: newDays,
      hours: newHours,
      minutes: newMinutes,
    );
    notifier.updateNotificationsTimeSettings(updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(localSettingsProvider);
    final notifier = ref.read(localSettingsProvider.notifier);

    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(locale!.notifications),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _actions.length,
        itemBuilder: (context, index) {
          final key = _actions[index];
          final setting = settings.notificationTimeSettings[key];

          final isEnabled = setting?.enabled ?? false;
          final days = setting?.days ?? 0;
          final hours = setting?.hours ?? 0;
          final minutes = setting?.minutes ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(
                  switch (key) {
                    'first_year' => locale.firstYear,
                    'second_year' => locale.secondYear,
                    'third_year' => locale.thirdYear,
                    'fourth_year' => locale.fourthYear,
                    _ => key,
                  },
                ),
                value: isEnabled,
                onChanged: (value) {
                  final updated = Map<String, NotificationTimeSetting>.from(
                      settings.notificationTimeSettings);
                  int newDays = value ? days : 0;
                  int newHours = value ? hours : 0;
                  int newMinutes = value ? minutes : 0;
                  if (value &&
                      newDays == 0 &&
                      newHours == 0 &&
                      newMinutes == 0) {
                    newDays = 1; // default fallback
                  }

                  updated[key] = NotificationTimeSetting(
                    enabled: value,
                    days: newDays,
                    hours: newHours,
                    minutes: newMinutes,
                  );
                  notifier.updateNotificationsTimeSettings(updated);
                },
              ),
              if (isEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16),
                  child: Row(
                    children: [
                      _buildTimeField("d", days, (val) {
                        _updateTime(ref, key, days: val);
                      }, max: 99),
                      const SizedBox(width: 8),
                      _buildTimeField("h", hours, (val) {
                        _updateTime(ref, key, hours: val);
                      }, max: 23),
                      const SizedBox(width: 8),
                      _buildTimeField("min", minutes, (val) {
                        _updateTime(ref, key, minutes: val);
                      }, max: 59),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
