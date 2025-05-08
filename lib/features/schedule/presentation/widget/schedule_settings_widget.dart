import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:flutter/material.dart';

class ScheduleSettingsWidget extends StatefulWidget {
  const ScheduleSettingsWidget({super.key});

  @override
  State<ScheduleSettingsWidget> createState() => _ScheduleSettingsWidgetState();
}

class _ScheduleSettingsWidgetState extends State<ScheduleSettingsWidget> {
  late List<Teacher> teachers;
  late List<Room> rooms;
  late List<StudyProgram> studyPrograms;
  late List<Major> majors;

  @override
  void initState() {
    super.initState();
    /*
    * TODO
    *  loadTeachers
    * loadRooms
    * loadStuyPrograms
    * loadMajors
    * vrati url za load
    * */
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
