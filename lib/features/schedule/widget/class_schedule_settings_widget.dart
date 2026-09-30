import 'package:etf_oglasi/core/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:etf_oglasi/core/ui/widget/future_dropdown.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:etf_oglasi/features/schedule/model/schedule_result.dart';
import 'package:etf_oglasi/features/schedule/widget/schedule_settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gen/app_localizations.dart';

/// Picks a class schedule by teacher, room or study program + year.
/// Pops with a [ScheduleResult] holding the schedule URL.
class ClassScheduleSettingsWidget extends ConsumerStatefulWidget {
  const ClassScheduleSettingsWidget({super.key, this.isSelect = true});

  final bool isSelect;

  @override
  ConsumerState<ClassScheduleSettingsWidget> createState() =>
      _ClassScheduleSettingsWidgetState();
}

class _ClassScheduleSettingsWidgetState
    extends ConsumerState<ClassScheduleSettingsWidget> {
  late final Future<List<Teacher>> _teachers;
  late final Future<List<Room>> _rooms;
  late final Future<List<StudyProgram>> _studyPrograms;
  Future<List<Major>>? _majors;
  String? _selectedTeacherId;
  String? _selectedRoomId;
  String? _selectedStudyProgramId;
  String? _selectedMajorId;
  String? _generatedUrl;

  @override
  void initState() {
    super.initState();
    final service = ref.read(scheduleOptionsServiceProvider);
    _teachers = service.fetchTeachers();
    _rooms = service.fetchRooms();
    _studyPrograms = service.fetchStudyPrograms();
  }

  void _select({
    String? teacherId,
    String? roomId,
    String? studyProgramId,
    String? majorId,
    String? url,
  }) {
    setState(() {
      _selectedTeacherId = teacherId;
      _selectedRoomId = roomId;
      _selectedStudyProgramId = studyProgramId;
      _selectedMajorId = majorId;
      _generatedUrl = url;
    });
  }

  void _pop(bool isSave) {
    Navigator.pop(context, ScheduleResult(url: _generatedUrl!, isSave: isSave));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final canPop = _generatedUrl != null;

    return ScheduleSettingsDialog(
      showSelect: widget.isSelect,
      onSelect: canPop ? () => _pop(false) : null,
      onSave: canPop ? () => _pop(true) : null,
      children: [
        FutureDropdown<Teacher>(
          future: _teachers,
          hint: locale.teacher,
          value: _selectedTeacherId,
          valueOf: (teacher) => teacher.id.toString(),
          labelOf: (teacher) => teacher.ime,
          onChanged: (value) => _select(
            teacherId: value,
            url: value != null ? getScheduleByTeacherUrl(value) : null,
          ),
        ),
        FutureDropdown<Room>(
          future: _rooms,
          hint: locale.room,
          value: _selectedRoomId,
          valueOf: (room) => room.id.toString(),
          labelOf: (room) => room.naziv,
          onChanged: (value) => _select(
            roomId: value,
            url: value != null ? getScheduleByRoomUrl(value) : null,
          ),
        ),
        FutureDropdown<StudyProgram>(
          future: _studyPrograms,
          hint: locale.studyProgram,
          value: _selectedStudyProgramId,
          valueOf: (program) => program.epgId.toString(),
          labelOf: (program) => program.name,
          onChanged: (value) {
            _majors = value != null
                ? ref.read(scheduleOptionsServiceProvider).fetchMajors(value)
                : null;
            _select(studyProgramId: value);
          },
        ),
        FutureDropdown<Major>(
          future: _majors,
          hint: locale.year,
          value: _selectedMajorId,
          valueOf: (major) => major.epId.toString(),
          labelOf: (major) => major.name,
          onChanged: (value) => _select(
            studyProgramId: _selectedStudyProgramId,
            majorId: value,
            url: value != null && _selectedStudyProgramId != null
                ? getScheduleUrl(_selectedStudyProgramId!, value)
                : null,
          ),
        ),
      ],
    );
  }
}
