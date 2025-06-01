import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/category.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/core/util/format_date.dart';
import 'package:etf_oglasi/features/schedule/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:etf_oglasi/features/schedule/repository/schedule_repository.dart';
import 'package:etf_oglasi/features/schedule/service/schedule_service.dart';
import 'package:etf_oglasi/features/schedule/widget/class_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/schedule/widget/room_schedule_settings_widget.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  static const id = 'schedule_screen';
  const ScheduleScreen({
    super.key,
    required this.category,
    required this.settingsWidget,
  });
  final Category category;
  final Widget settingsWidget;
  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  Schedule _schedule = Schedule(
    monday: [],
    tuesday: [],
    wednesday: [],
    thursday: [],
    friday: [],
  );
  late TabController _tabController;
  late ScheduleService _service;
  final ScrollController _scrollController = ScrollController();
  late Future<void> _scheduleFuture;
  late ScheduleRepository _scheduleRepository;

  late String? _url;

  @override
  void initState() {
    super.initState();
    _service = ref.read(scheduleServiceProvider);
    _scheduleRepository = ref.read(scheduleRepositoryProvider);
    switch (widget.category.url) {
      case ClassScheduleSettingsWidget.classScheduleUrl:
        _url = ref.read(localSettingsProvider).classScheduleUrl;
        break;
      case RoomScheduleSettingsWidget.roomScheduleId:
        {
          final String? id = ref.read(localSettingsProvider).roomScheduleId;
          if (id != null) {
            _url = getRoomScheduleUrl(
              id,
              formatDate(getMondayOfWeek(DateTime.now())),
            );
          } else {
            _url = null;
          }
          break;
        }
      default:
        _url = widget.category.url;
    }
    _scheduleFuture = _loadData(_url);
    _tabController = TabController(length: 5, vsync: this);

    _setInitialTab();
  }

  Future<void> _fetchData(String url) async {
    try {
      final fetchedSchedule = await _service.fetchSchedule(url);
      setState(() {
        _schedule = fetchedSchedule;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentHour();
      });
    } catch (e) {
      setState(() {
        _schedule = Schedule(
          monday: [],
          tuesday: [],
          wednesday: [],
          thursday: [],
          friday: [],
        );
      });
    }
  }

  Future<void> _loadData(String? url) async {
    try {
      if (url != null) {
        final cachedSchedule = await _scheduleRepository.findScheduleById(url);
        if (cachedSchedule != null) {
          setState(() {
            _schedule = cachedSchedule;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentHour();
          });
        } else {
          await _fetchData(url);
          await _scheduleRepository.saveSchedule(url, _schedule);
        }
      }
    } catch (e) {
      setState(() {
        _schedule = Schedule(
          monday: [],
          tuesday: [],
          wednesday: [],
          thursday: [],
          friday: [],
        );
      });
    }
  }

  void _setInitialTab() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      _tabController.index = dayOfWeek - 1;
    }
  }

  List<ScheduleEntry> _getCurrentDaySchedule() {
    switch (_tabController.index) {
      case 0:
        return _schedule.monday;
      case 1:
        return _schedule.tuesday;
      case 2:
        return _schedule.wednesday;
      case 3:
        return _schedule.thursday;
      case 4:
        return _schedule.friday;
      default:
        return _schedule.monday;
    }
  }

  void _scrollToCurrentHour() {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentHour();
      });
      return;
    }

    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);
    final daySchedule = _getCurrentDaySchedule();

    if (daySchedule.isEmpty) {
      return;
    }

    // Find the earliest and latest times in the schedule
    Duration? earliestTime;
    Duration? latestTime;
    for (var entry in daySchedule) {
      final time = _schedule.parseTime(entry.time);
      if (earliestTime == null || time < earliestTime) {
        earliestTime = time;
      }
      if (latestTime == null || time > latestTime) {
        latestTime = time;
      }
    }

    // If current time is before the earliest time, scroll to the first entry
    if (earliestTime != null && currentTime < earliestTime) {
      _scrollController.jumpTo(0.0);
      return;
    }

    // If current time is after the latest time, scroll to the last entry
    if (latestTime != null && currentTime > latestTime) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent *
            ((daySchedule.length - 1) / daySchedule.length),
      );
      return;
    }

    // Scroll to the current hour within the schedule
    for (int i = 0; i < daySchedule.length; i++) {
      final time = _schedule.parseTime(daySchedule[i].time);
      if (time <= currentTime &&
          (i + 1 >= daySchedule.length ||
              _schedule.parseTime(daySchedule[i + 1].time) > currentTime)) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent * (i / daySchedule.length),
        );
        break;
      }
    }
  }

  Widget _buildScheduleList(List<ScheduleEntry> daySchedule) {
    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);
    final colorScheme = Theme.of(context).colorScheme;

    Duration? earliestTime;
    Duration? latestTime;
    for (var entry in daySchedule) {
      final time = _schedule.parseTime(entry.time);
      if (earliestTime == null || time < earliestTime) {
        earliestTime = time;
      }
      if (latestTime == null || time > latestTime) {
        latestTime = time;
      }
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: daySchedule.length,
      itemBuilder: (context, index) {
        final entry = daySchedule[index];
        final time = _schedule.parseTime(entry.time);
        bool isCurrentHour = false;

        if (earliestTime != null && currentTime < earliestTime && index == 0) {
          isCurrentHour = true;
        } else if (latestTime != null &&
            currentTime > latestTime &&
            index == daySchedule.length - 1) {
          isCurrentHour = true;
        } else if (time <= currentTime &&
            (index + 1 >= daySchedule.length ||
                _schedule.parseTime(daySchedule[index + 1].time) >
                    currentTime)) {
          isCurrentHour = true;
        }

        return Column(
          children: [
            ListTile(
              title: Text(
                entry.time,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: entry.subject != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entry.subject!
                          .split('\n')
                          .map((s) => Text(s.trim()))
                          .toList(),
                    )
                  : const Text(''),
              tileColor: isCurrentHour ? colorScheme.primaryContainer : null,
            ),
            if (index < daySchedule.length - 1)
              const Divider(
                color: Colors.grey,
                thickness: 1.0,
                height: 10.0,
              ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() async {
    final result = await showDialog<ScheduleResult>(
      context: context,
      builder: (context) => widget.settingsWidget,
    );
    if (result != null) {
      final selectedUrl = result.url;
      final isSave = result.isSave;
      setState(() {
        if (isSave) {
          switch (widget.category.url) {
            case ClassScheduleSettingsWidget.classScheduleUrl:
              _url = selectedUrl;
              ref
                  .read(localSettingsProvider.notifier)
                  .updateClassScheduleURL(selectedUrl);
              break;
            case RoomScheduleSettingsWidget.roomScheduleId:
              {
                _url = getRoomScheduleUrl(
                  selectedUrl,
                  formatDate(getMondayOfWeek(DateTime.now())),
                );
                ref
                    .read(localSettingsProvider.notifier)
                    .updateRoomScheduleId(selectedUrl);
                break;
              }
            default:
              _url = widget.category.url;
          }
          _scheduleFuture = _loadData(_url);
        } else {
          _fetchData(selectedUrl);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale!.schedule),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                if (_url != null) {
                  _scheduleFuture = _loadData(_url!);
                }
              });
            },
            tooltip: locale.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: locale.settings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onPrimary,
          labelStyle: const TextStyle(fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          labelPadding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          tabs: [
            Tab(child: FittedBox(child: Text(locale.monday))),
            Tab(child: FittedBox(child: Text(locale.tuesday))),
            Tab(child: FittedBox(child: Text(locale.wednesday))),
            Tab(child: FittedBox(child: Text(locale.thursday))),
            Tab(child: FittedBox(child: Text(locale.friday))),
          ],
        ),
      ),
      body: FutureBuilder<void>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _schedule.monday.isNotEmpty
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScheduleList(_schedule.monday),
                    _buildScheduleList(_schedule.tuesday),
                    _buildScheduleList(_schedule.wednesday),
                    _buildScheduleList(_schedule.thursday),
                    _buildScheduleList(_schedule.friday),
                  ],
                )
              : Center(child: Text(locale.noSchedule));
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
