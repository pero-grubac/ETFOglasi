import 'package:etf_oglasi/features/home/data/model/category.dart';
import 'package:etf_oglasi/features/schedule/data/model/schedule.dart';
import 'package:etf_oglasi/features/schedule/data/service/schedule_service.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.category});
  final Category category;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Schedule schedule;
  final ScheduleService service = ScheduleService();
/*
* TODO
*  Load smjer
* Load usmjerenje
* Load Data po tome
* Dugme persist data
* Jump to top
* If persist data dont call api
*/

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    schedule = await service.fetchSchedule('TODO');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
