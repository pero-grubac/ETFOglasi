import 'dart:convert';

import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_block.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/gen/app_localizations.dart';

/// The native widgets (android/app/src/main/java/org/unibl/etf/etf_oglasi/):
/// today's classes, and the small one with the current and next class.
const _widgetProviders = [
  'org.unibl.etf.etf_oglasi.ScheduleWidgetProvider',
  'org.unibl.etf.etf_oglasi.NextClassWidgetProvider',
];

/// URI the widget opens the app with.
const scheduleWidgetUri = 'etfoglasi://class_schedule';

/// One line per class: `9:15–11:00  Mjerenja (svi) · 1103`. Several groups
/// in one slot are joined with ` / `.
String widgetDayText(List<ScheduleBlock> blocks) => blocks
    .map((block) {
      final time =
          '${formatDuration(block.start)}–${formatDuration(block.end)}';
      final title = block.title.replaceAll('\n', ' / ');
      final room = block.room;
      return room == null ? '$time  $title' : '$time  $title · $room';
    })
    .join('\n');

/// One day's classes for the "next class" widget, which works out the
/// current and next class itself: `[{"s":555,"e":660,"t":"…","r":"1103"}]`
/// (times in minutes after midnight).
String widgetDayJson(List<ScheduleBlock> blocks) => jsonEncode([
  for (final block in blocks)
    {
      's': block.start.inMinutes,
      'e': block.end.inMinutes,
      't': block.title.replaceAll('\n', ' / '),
      'r': block.room,
    },
]);

/// Stores every weekday's classes and the labels for the widgets and redraws
/// them. The widgets pick today's day themselves. [schedule] is `null` when
/// no class schedule is saved.
Future<void> updateScheduleWidget(
  Schedule? schedule,
  AppLocalizations locale,
) async {
  final dayNames = [
    locale.monday,
    locale.tuesday,
    locale.wednesday,
    locale.thursday,
    locale.friday,
  ];
  await HomeWidget.saveWidgetData('widget_has_schedule', schedule != null);
  await HomeWidget.saveWidgetData(
    'widget_no_schedule',
    locale.widgetNoSchedule,
  );
  await HomeWidget.saveWidgetData('widget_no_classes', locale.widgetNoClasses);
  for (final (key, value) in [
    ('widget_now', locale.widgetNow),
    ('widget_until', locale.widgetUntil),
    ('widget_next', locale.widgetNext),
    ('widget_tomorrow', locale.widgetTomorrow),
    ('widget_free', locale.widgetFree),
    ('widget_no_more_today', locale.widgetNoMoreToday),
    ('widget_no_classes_today', locale.widgetNoClassesToday),
  ]) {
    await HomeWidget.saveWidgetData(key, value);
  }
  for (var day = 0; day < dayNames.length; day++) {
    final blocks = schedule == null
        ? const <ScheduleBlock>[]
        : dayBlocks(day, schedule.days[day]);
    await HomeWidget.saveWidgetData('widget_title_${day + 1}', dayNames[day]);
    await HomeWidget.saveWidgetData(
      'widget_body_${day + 1}',
      widgetDayText(blocks),
    );
    await HomeWidget.saveWidgetData(
      'widget_classes_${day + 1}',
      widgetDayJson(blocks),
    );
  }
  for (final provider in _widgetProviders) {
    await HomeWidget.updateWidget(qualifiedAndroidName: provider);
  }
}
