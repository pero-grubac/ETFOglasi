import 'dart:async';
import 'dart:io';

import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/ui/widget/api_error_widget.dart';
import 'package:etf_oglasi/core/ui/widget/no_data_widget.dart';
import 'package:etf_oglasi/core/ui/widget/offline_banner.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:etf_oglasi/features/schedule/service/calendar_export.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_provider.dart';
import 'package:etf_oglasi/features/schedule/widget/class_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/schedule/widget/room_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/gen/app_localizations.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static const id = 'schedule_screen';
  const ScheduleScreen({super.key, required this.category});
  final Category category;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Class schedule URL picked with "Select" (shown without being saved).
  String? _selectedUrl;

  /// Room picked with "Select" (shown without being saved).
  String? _selectedRoomId;

  /// Monday of the displayed week (room schedule only).
  late DateTime _week;

  bool get _isClassSchedule =>
      widget.category.type == CategoryType.classSchedule;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _week = defaultScheduleWeek(now);
    _tabController = TabController(
      length: 5,
      vsync: this,
      // On weekends the next week is shown, starting with Monday.
      initialIndex: now.weekday <= DateTime.friday ? now.weekday - 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? _roomId(LocalSettings settings) =>
      _selectedRoomId ?? settings.roomScheduleId;

  String? _url(LocalSettings settings) {
    if (_isClassSchedule) return _selectedUrl ?? settings.classScheduleUrl;
    final roomId = _roomId(settings);
    if (roomId == null) return null;
    return getRoomScheduleUrl(roomId, formatDate(_week));
  }

  /// Whether the tab [dayIndex] (0 = Monday) shows today. Class schedules
  /// repeat every week; room schedules belong to [_week].
  bool _isToday(int dayIndex) {
    final now = DateTime.now();
    if (_isClassSchedule) return now.weekday - 1 == dayIndex;
    return isSameDay(
      DateTime(_week.year, _week.month, _week.day + dayIndex),
      now,
    );
  }

  Future<void> _refresh(String url) async {
    final success = await ref.read(scheduleProvider(url).notifier).refresh();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).refreshFailed)),
      );
    }
  }

  Future<void> _showSettingsDialog() async {
    final result = await showDialog<ScheduleResult>(
      context: context,
      builder: (context) => _isClassSchedule
          ? const ClassScheduleSettingsWidget()
          : const RoomScheduleSettingsWidget(),
    );
    if (result == null || !mounted) return;

    if (result.isSave) {
      final notifier = ref.read(localSettingsProvider.notifier);
      if (_isClassSchedule) {
        unawaited(notifier.updateClassScheduleURL(result.url));
      } else {
        notifier.updateRoomScheduleId(result.url);
      }
      setState(() {
        _selectedUrl = null;
        _selectedRoomId = null;
      });
    } else if (_isClassSchedule) {
      setState(() => _selectedUrl = result.url);
    } else {
      setState(() {
        _selectedRoomId = result.url;
        _week = result.week ?? _week;
      });
    }
  }

  /// Shares the class schedule as an .ics file with weekly repeating
  /// events, until a date the user picks (end of the semester by default).
  Future<void> _exportToCalendar(Schedule schedule) async {
    final locale = AppLocalizations.of(context);
    final now = DateTime.now();
    final until = await showDatePicker(
      context: context,
      initialDate: defaultSemesterEnd(now),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: locale.calendarRepeatUntil,
    );
    if (until == null || !mounted) return;

    try {
      final file = File(
        path.join((await getTemporaryDirectory()).path, 'raspored.ics'),
      );
      await file.writeAsString(
        buildScheduleCalendar(
          blocks: scheduleBlocks(schedule),
          from: now,
          until: until,
          now: now,
        ),
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/calendar')],
          subject: locale.calendarFileSubject,
        ),
      );
    } catch (e, stackTrace) {
      await errorLog.record(e, stackTrace, source: 'calendar export');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locale.calendarExportFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final settings = ref.watch(localSettingsProvider);
    final url = _url(settings);
    final showWeekBar = !_isClassSchedule && _roomId(settings) != null;
    final data = url != null ? ref.watch(scheduleProvider(url)) : null;
    final isLoading =
        (data?.isLoading ?? false) || (data?.value?.refreshing ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: url == null || isLoading ? null : () => _refresh(url),
            tooltip: locale.refresh,
          ),
          if (_isClassSchedule)
            _ClassScheduleMenu(
              onSelect: _showSettingsDialog,
              onExport: switch (data?.value?.schedule) {
                final schedule? when schedule.isNotEmpty =>
                  () => _exportToCalendar(schedule),
                _ => null,
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
              tooltip: locale.settings,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            for (final day in [
              locale.monday,
              locale.tuesday,
              locale.wednesday,
              locale.thursday,
              locale.friday,
            ])
              Tab(child: FittedBox(child: Text(day))),
          ],
        ),
      ),
      body: Column(
        children: [
          if (showWeekBar)
            _WeekBar(
              week: _week,
              onChanged: (week) => setState(() => _week = week),
            ),
          Expanded(child: _buildContent(url, data, isLoading, locale)),
        ],
      ),
    );
  }

  Widget _buildContent(
    String? url,
    AsyncValue<ScheduleData>? data,
    bool isLoading,
    AppLocalizations locale,
  ) {
    return url == null || data == null
        ? _NoScheduleSelected(onSelect: _showSettingsDialog)
        : data.when(
            skipLoadingOnRefresh: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                ApiErrorWidget(error: error, onRetry: () => _refresh(url)),
            data: (scheduleData) => Column(
              children: [
                if (isLoading) const LinearProgressIndicator(),
                if (scheduleData.offline) const OfflineBanner(),
                Expanded(
                  child: scheduleData.schedule.isEmpty
                      ? NoDataWidget(message: locale.noSchedule)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            for (var i = 0; i < 5; i++)
                              _DayScheduleList(
                                // New state (and scroll) per schedule.
                                key: ValueKey('$url#$i'),
                                entries: scheduleData.schedule.days[i],
                                isToday: _isToday(i),
                                onRefresh: () => _refresh(url),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          );
  }
}

/// Previous / next week selector for room schedules.
class _WeekBar extends StatelessWidget {
  const _WeekBar({required this.week, required this.onChanged});

  final DateTime week;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final defaultWeek = defaultScheduleWeek(DateTime.now());
    final isDefaultWeek = isSameDay(week, defaultWeek);

    return Material(
      color: colorScheme.primaryContainer,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: colorScheme.onPrimaryContainer,
            tooltip: locale.previousWeek,
            onPressed: () => onChanged(addWeeks(week, -1)),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onPrimaryContainer,
                disabledForegroundColor: colorScheme.onPrimaryContainer,
              ),
              // Tapping the range jumps back to the default week.
              onPressed: isDefaultWeek ? null : () => onChanged(defaultWeek),
              child: Text(
                formatWeekRange(week),
                style: TextStyle(
                  fontWeight: isDefaultWeek
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: colorScheme.onPrimaryContainer,
            tooltip: locale.nextWeek,
            onPressed: () => onChanged(addWeeks(week, 1)),
          ),
        ],
      ),
    );
  }
}

class _NoScheduleSelected extends StatelessWidget {
  const _NoScheduleSelected({required this.onSelect});
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NoDataWidget(message: locale.noScheduleSelected),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSelect,
            child: Text(locale.selectSchedule),
          ),
        ],
      ),
    );
  }
}

/// One day of the schedule; today's is scrolled to the current time slot.
class _DayScheduleList extends StatefulWidget {
  const _DayScheduleList({
    super.key,
    required this.entries,
    required this.isToday,
    required this.onRefresh,
  });

  final List<ScheduleEntry> entries;

  /// Only today's list highlights and scrolls to the current time slot.
  final bool isToday;
  final Future<void> Function() onRefresh;

  @override
  State<_DayScheduleList> createState() => _DayScheduleListState();
}

class _DayScheduleListState extends State<_DayScheduleList> {
  final GlobalKey _currentSlotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final slotContext = _currentSlotKey.currentContext;
      if (slotContext != null) {
        Scrollable.ensureVisible(slotContext, alignment: 0.1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentIndex = widget.isToday
        ? Schedule.currentSlotIndex(
            widget.entries,
            Duration(hours: now.hour, minutes: now.minute),
          )
        : null;

    // A plain ListView (not .builder) so every slot is laid out and the
    // current one can be scrolled into view; a day has only ~14 slots.
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          for (var index = 0; index < widget.entries.length; index++) ...[
            ListTile(
              key: index == currentIndex ? _currentSlotKey : null,
              title: Text(
                widget.entries[index].time,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line
                      in (widget.entries[index].subject ?? '').split('\n'))
                    Text(line.trim()),
                ],
              ),
              tileColor: index == currentIndex
                  ? colorScheme.primaryContainer
                  : null,
              textColor: index == currentIndex
                  ? colorScheme.onPrimaryContainer
                  : null,
            ),
            if (index < widget.entries.length - 1)
              Divider(
                color: colorScheme.outlineVariant,
                thickness: 1.0,
                height: 10.0,
              ),
          ],
        ],
      ),
    );
  }
}

enum _MenuAction { select, export }

/// "Pick a schedule" and "Add to calendar" for the class schedule. A menu
/// instead of two more icons, so the title still fits on small phones.
class _ClassScheduleMenu extends StatelessWidget {
  const _ClassScheduleMenu({required this.onSelect, required this.onExport});

  final VoidCallback onSelect;

  /// `null` while there's no schedule to export.
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return PopupMenuButton<_MenuAction>(
      tooltip: locale.moreOptions,
      onSelected: (action) => switch (action) {
        _MenuAction.select => onSelect(),
        _MenuAction.export => onExport?.call(),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.select,
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: Text(locale.selectSchedule),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.export,
          enabled: onExport != null,
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(locale.addToCalendar),
            contentPadding: EdgeInsets.zero,
            enabled: onExport != null,
          ),
        ),
      ],
    );
  }
}
