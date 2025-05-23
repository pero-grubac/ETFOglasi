import 'package:etf_oglasi/core/util/service_locator.dart';
import 'package:etf_oglasi/features/home/data/model/category.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/data/service/schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScheduleScreen extends StatefulWidget {
  static const id = 'schedule_screen';
  const ScheduleScreen({
    super.key,
    required this.category,
    required this.settingsWidget,
  });
  final Category category;
  final Widget settingsWidget;
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late Schedule _schedule;
  late TabController _tabController;
  final ScheduleService _service = getIt<ScheduleService>();
  final ScrollController _scrollController = ScrollController();
  late Future<void> _assetsFuture;
  late String _url;
/*
* TODO
*  Schedule settings widget
* Load Data po tome
* Dugme persist data i persist url
* If persist data dont call api
* cached data valid?
*/

  @override
  void initState() {
    super.initState();
    // iz baze ucitaj url za raspored ako nema  ucitaj getScheduleUrl(widget.category.urlId, widget.category.urlId)
    _url = widget.category.url;
    _assetsFuture = _loadData(_url);
    _tabController = TabController(length: 5, vsync: this);
    _setInitialTab();
  }

  Future<void> _loadData(String url) async {
    try {
      _schedule = await _service.fetchSchedule(url);
      setState(() {});
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

  void _setInitialTab() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    if (dayOfWeek >= 1 && dayOfWeek <= 5) {
      _tabController.index = dayOfWeek - 1;
    }
  }

  void _scrollToCurrentHour() {
    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);
    for (int i = 0; i < _schedule.tuesday.length; i++) {
      final time = _schedule.parseTime(_schedule.tuesday[i].$1);
      if (time <= currentTime &&
          (i + 1 >= _schedule.tuesday.length ||
              _schedule.parseTime(_schedule.tuesday[i + 1].$1) > currentTime)) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent *
            (i / _schedule.tuesday.length));
        break;
      }
    }
  }

  Widget _buildScheduleList(List<(String, String?)> daySchedule) {
    final now = DateTime.now();
    final currentTime = Duration(hours: now.hour, minutes: now.minute);
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      controller: _scrollController,
      itemCount: daySchedule.length,
      itemBuilder: (context, index) {
        final (timeStr, subject) = daySchedule[index];
        final time = _schedule.parseTime(timeStr);
        final isCurrentHour = time <= currentTime &&
            (index + 1 >= daySchedule.length ||
                _schedule.parseTime(daySchedule[index + 1].$1) > currentTime);

        return Column(
          children: [
            ListTile(
              title: Text(
                timeStr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: subject != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: subject
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
    final selectedUrl = await showDialog<String>(
      context: context,
      builder: (context) => widget.settingsWidget,
    );

    if (selectedUrl != null) {
      setState(() {
        _url = selectedUrl;
        _assetsFuture = _loadData(_url);
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
                _assetsFuture = _loadData(_url);
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
        future: _assetsFuture,
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
}
