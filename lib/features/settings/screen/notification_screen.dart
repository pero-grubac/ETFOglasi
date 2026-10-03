import 'package:etf_oglasi/core/util/open_link.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
import 'package:etf_oglasi/features/schedule/service/class_reminders.dart';
import 'package:etf_oglasi/features/settings/model/notification_time_setting.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/gen/app_localizations.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  static const id = 'notification_screen';
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  static const int _minMinutes = NotificationTimeSetting.minMinutes;

  late Map<String, NotificationTimeSetting> _tempSettings;

  /// Minutes before class for reminders; 0 = off. Saved with the rest.
  late int _tempReminderMinutes;

  /// Whether the app is exempt from battery optimisation. `null` until
  /// checked; then the hint is shown only when it isn't.
  bool? _batteryUnrestricted;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(localSettingsProvider);
    _tempSettings = Map<String, NotificationTimeSetting>.from(
      settings.notificationTimeSettings,
    );
    _tempReminderMinutes = settings.classReminderMinutes;
    _checkBatteryOptimization();
  }

  Future<void> _checkBatteryOptimization() async {
    bool unrestricted;
    try {
      unrestricted = await Permission.ignoreBatteryOptimizations.isGranted;
    } catch (_) {
      unrestricted = true; // Can't tell, so don't nag.
    }
    if (mounted) setState(() => _batteryUnrestricted = unrestricted);
  }

  Future<void> _allowBackground() async {
    try {
      await Permission.ignoreBatteryOptimizations.request();
    } catch (_) {
      await openAppSettings();
    }
    await _checkBatteryOptimization();
  }

  /// Requests the notification permission when needed. Returns whether
  /// notifications can be shown.
  Future<bool> _ensureNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (!status.isPermanentlyDenied) {
      status = await Permission.notification.request();
      if (status.isGranted) return true;
    }
    if (mounted) {
      final locale = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale.notAllowedNotification),
          action: SnackBarAction(
            label: locale.openSettings,
            onPressed: openAppSettings,
          ),
        ),
      );
    }
    return false;
  }

  Future<void> _saveSettings() async {
    final locale = AppLocalizations.of(context);
    final updated = <String, NotificationTimeSetting>{};

    var hasInvalidDuration = false;
    for (final entry in _tempSettings.entries) {
      final setting = entry.value;
      if (setting.enabled && setting.totalMinutes < _minMinutes) {
        updated[entry.key] = setting.copyWith(
          days: 0,
          hours: 0,
          minutes: _minMinutes,
        );
        hasInvalidDuration = true;
      } else {
        updated[entry.key] = setting;
      }
    }

    if (updated.values.any((s) => s.enabled) || _tempReminderMinutes > 0) {
      await _ensureNotificationPermission();
    }
    final notifier = ref.read(localSettingsProvider.notifier);
    await notifier.updateNotificationsTimeSettings(updated);
    if (_tempReminderMinutes !=
        ref.read(localSettingsProvider).classReminderMinutes) {
      await notifier.updateClassReminderMinutes(_tempReminderMinutes);
    }
    if (!mounted) return;

    setState(() => _tempSettings = Map.of(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasInvalidDuration
              ? locale.minDurationSet(minutes: _minMinutes)
              : locale.settingsSaved,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateSetting(String key, NotificationTimeSetting setting) {
    setState(() => _tempSettings[key] = setting);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final keys = notificationBoardIds.keys.toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(locale.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: locale.save,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: keys.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _batteryUnrestricted == false
                ? _BatteryHint(onAllow: _allowBackground)
                : const SizedBox.shrink();
          }
          if (index == keys.length + 1) {
            return _ClassReminderSetting(
              minutes: _tempReminderMinutes,
              hasSchedule:
                  ref.watch(localSettingsProvider).classScheduleUrl != null,
              onChanged: (minutes) {
                setState(() => _tempReminderMinutes = minutes);
                if (minutes > 0) _ensureNotificationPermission();
              },
            );
          }
          final key = keys[index - 1];
          final setting =
              _tempSettings[key] ?? NotificationTimeSetting.disabled;
          final hasError =
              setting.enabled && setting.totalMinutes < _minMinutes;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(notificationBoardTitle(locale, key)),
                value: setting.enabled,
                onChanged: (value) {
                  _updateSetting(
                    key,
                    value
                        ? setting.copyWith(
                            enabled: true,
                            minutes: setting.totalMinutes == 0
                                ? _minMinutes
                                : setting.minutes,
                          )
                        : NotificationTimeSetting.disabled,
                  );
                  if (value) _ensureNotificationPermission();
                },
              ),
              if (setting.enabled) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    spacing: 8,
                    children: [
                      _TimeField(
                        label: locale.daysShort,
                        value: setting.days,
                        max: 99,
                        hasError: hasError,
                        onChanged: (val) =>
                            _updateSetting(key, setting.copyWith(days: val)),
                      ),
                      _TimeField(
                        label: locale.hoursShort,
                        value: setting.hours,
                        max: 23,
                        hasError: hasError,
                        onChanged: (val) =>
                            _updateSetting(key, setting.copyWith(hours: val)),
                      ),
                      _TimeField(
                        label: locale.minutesShort,
                        value: setting.minutes,
                        max: 59,
                        hasError: hasError,
                        onChanged: (val) =>
                            _updateSetting(key, setting.copyWith(minutes: val)),
                      ),
                    ],
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 4.0,
                      bottom: 16.0,
                    ),
                    child: Text(
                      locale.minDurationError(minutes: _minMinutes),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
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

/// Reminder before each class of the saved class schedule.
class _ClassReminderSetting extends StatelessWidget {
  const _ClassReminderSetting({
    required this.minutes,
    required this.hasSchedule,
    required this.onChanged,
  });

  /// 0 = off.
  final int minutes;
  final bool hasSchedule;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final enabled = minutes > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        SwitchListTile(
          secondary: const Icon(Icons.alarm),
          title: Text(locale.classReminder),
          subtitle: Text(
            hasSchedule
                ? locale.classReminderDescription
                : locale.classReminderNoSchedule,
          ),
          value: enabled,
          onChanged: (value) => onChanged(value ? classReminderOptions[1] : 0),
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in classReminderOptions)
                  ChoiceChip(
                    label: Text(
                      locale.classReminderMinutesBefore(minutes: option),
                    ),
                    selected: minutes == option,
                    onSelected: (_) => onChanged(option),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Explains that some phones stop background work, with a button that asks
/// Android to exempt the app from battery optimisation.
class _BatteryHint extends StatelessWidget {
  const _BatteryHint({required this.onAllow});

  static const _moreInfoUrl = 'https://dontkillmyapp.com';

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(Icons.battery_alert, color: theme.colorScheme.primary),
                Expanded(
                  child: Text(
                    locale.batteryTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            Text(locale.batteryMessage),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => openLink(context, _moreInfoUrl),
                    child: Text(locale.moreInfo),
                  ),
                  FilledButton(
                    onPressed: onAllow,
                    child: Text(locale.batteryAllow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Numeric input that keeps its own controller, so the cursor isn't reset
/// when the parent rebuilds.
class _TimeField extends StatefulWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.hasError = false,
  });

  final String label;
  final int value;
  final int max;
  final bool hasError;
  final ValueChanged<int> onChanged;

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value.toString(),
  );

  @override
  void didUpdateWidget(covariant _TimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync when the value was changed from outside (e.g. clamped or reset),
    // but not while the text already represents it (e.g. an empty field).
    if ((int.tryParse(_controller.text) ?? 0) != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = widget.hasError
        ? colorScheme.error
        : colorScheme.outline;
    return SizedBox(
      width: 70,
      child: TextField(
        controller: _controller,
        maxLength: 3,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: 'max ${widget.max}',
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.hasError ? colorScheme.error : colorScheme.primary,
            ),
          ),
        ),
        onChanged: (value) {
          final parsed = int.tryParse(value) ?? 0;
          widget.onChanged(parsed.clamp(0, widget.max));
        },
      ),
    );
  }
}
