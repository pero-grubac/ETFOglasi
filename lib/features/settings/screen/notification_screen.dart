import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  static const id = 'notification_screen';
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  static const _actions = [
    'first_year',
    'second_year',
    'third_year',
    'fourth_year'
  ];
  static const int _minMinutes = 15;

  late Map<String, NotificationTimeSetting> _tempSettings;

  @override
  void initState() {
    super.initState();
    _tempSettings = Map<String, NotificationTimeSetting>.from(
      ref.read(localSettingsProvider).notificationTimeSettings,
    );
  }

  Widget _buildTimeField(
    String label,
    int initialValue,
    void Function(int) onChanged, {
    required int max,
    bool hasError = false,
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
          hintText: 'max $max', // Show max as hint instead of helperText
          counterText: '',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  hasError ? Colors.red : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        onChanged: (value) {
          final parsed = int.tryParse(value) ?? 0;
          final clamped = parsed.clamp(0, max);
          onChanged(clamped);
        },
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final notifier = ref.read(localSettingsProvider.notifier);
    final updated = Map<String, NotificationTimeSetting>.from(_tempSettings);

    bool hasInvalidDuration = false;
    for (final entry in updated.entries) {
      final key = entry.key;
      final setting = entry.value;
      if (setting.enabled) {
        final totalMinutes =
            setting.days * 24 * 60 + setting.hours * 60 + setting.minutes;
        if (totalMinutes < _minMinutes) {
          updated[key] = NotificationTimeSetting(
            enabled: setting.enabled,
            days: 0,
            hours: 0,
            minutes: _minMinutes,
          );
          hasInvalidDuration = true;
        }
      }
    }

    notifier.updateNotificationsTimeSettings(updated);

    if (hasInvalidDuration) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale.minDurationSet(minutes: _minMinutes)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateTempTime(String key, {int? days, int? hours, int? minutes}) {
    final current = _tempSettings[key] ??
        NotificationTimeSetting(enabled: false, days: 0, hours: 0, minutes: 0);

    setState(() {
      _tempSettings[key] = NotificationTimeSetting(
        enabled: current.enabled,
        days: days ?? current.days,
        hours: hours ?? current.hours,
        minutes: minutes ?? current.minutes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(locale.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(context),
            tooltip: locale.save,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _actions.length,
        itemBuilder: (context, index) {
          final key = _actions[index];
          final setting = _tempSettings[key] ??
              NotificationTimeSetting(
                enabled: false,
                days: 0,
                hours: 0,
                minutes: 0,
              );

          final isEnabled = setting.enabled;
          final days = setting.days;
          final hours = setting.hours;
          final minutes = setting.minutes;

          final totalMinutes = days * 24 * 60 + hours * 60 + minutes;
          final hasError = isEnabled && totalMinutes < _minMinutes;

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
                  setState(() {
                    int newDays = value ? days : 0;
                    int newHours = value ? hours : 0;
                    int newMinutes = value ? minutes : 0;
                    if (value &&
                        newDays == 0 &&
                        newHours == 0 &&
                        newMinutes == 0) {
                      newMinutes = _minMinutes;
                    }
                    _tempSettings[key] = NotificationTimeSetting(
                      enabled: value,
                      days: newDays,
                      hours: newHours,
                      minutes: newMinutes,
                    );
                  });
                },
              ),
              if (isEnabled) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      _buildTimeField(
                        "d",
                        days,
                        (val) => _updateTempTime(key, days: val),
                        max: 99,
                        hasError: hasError,
                      ),
                      const SizedBox(width: 8),
                      _buildTimeField(
                        "h",
                        hours,
                        (val) => _updateTempTime(key, hours: val),
                        max: 23,
                        hasError: hasError,
                      ),
                      const SizedBox(width: 8),
                      _buildTimeField(
                        "min",
                        minutes,
                        (val) => _updateTempTime(key, minutes: val),
                        max: 59,
                        hasError: hasError,
                      ),
                    ],
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 4.0, bottom: 16.0),
                    child: Text(
                      locale.minDurationError(minutes: _minMinutes),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
