import 'package:etf_oglasi/features/announcements/service/announcement_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    _tempSettings = Map<String, NotificationTimeSetting>.from(
      ref.read(localSettingsProvider).notificationTimeSettings,
    );
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

    if (updated.values.any((s) => s.enabled)) {
      await _ensureNotificationPermission();
    }
    await ref
        .read(localSettingsProvider.notifier)
        .updateNotificationsTimeSettings(updated);
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
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
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
