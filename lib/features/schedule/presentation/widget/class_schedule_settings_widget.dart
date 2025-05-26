import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:etf_oglasi/core/service/api/major_service.dart';
import 'package:etf_oglasi/core/service/api/room_service.dart';
import 'package:etf_oglasi/core/service/api/study_program_service.dart';
import 'package:etf_oglasi/core/service/api/teacher_service.dart';
import 'package:etf_oglasi/core/util/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassScheduleSettingsWidget extends ConsumerStatefulWidget {
  const ClassScheduleSettingsWidget({super.key});

  @override
  ConsumerState<ClassScheduleSettingsWidget> createState() =>
      _ClassScheduleSettingsWidgetState();
}

class _ClassScheduleSettingsWidgetState
    extends ConsumerState<ClassScheduleSettingsWidget> {
  late TeacherService _teacherService;
  late RoomService _roomService;
  late StudyProgramService _studyProgramService;
  late MajorService _majorService;

  late Future<List<Teacher>> _teachers;
  late Future<List<Room>> _rooms;
  late Future<List<StudyProgram>> _studyPrograms;
  late Future<List<Major>> _majors;
  String? _selectedTeacherId;
  String? _selectedRoomId;
  String? _selectedStudyProgramId;
  String? _selectedMajorId;
  String? _generatedUrl;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _roomService = ref.read(roomServiceProvider);
    _teacherService = ref.read(teacherServiceProvider);
    _studyProgramService = ref.read(studyProgramProvider);
    _majorService = ref.read(majorServiceProvider);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final teachersFuture = _teacherService.fetchTeachers();
      final roomsFuture = _roomService.fetchRooms();
      final studyProgramsFuture = _studyProgramService.fetchStudyPrograms();

      final studyProgramsList = await studyProgramsFuture;

      setState(() {
        _teachers = teachersFuture;
        _rooms = roomsFuture;
        _studyPrograms = studyProgramsFuture;
        _majors = studyProgramsList.isNotEmpty
            ? _majorService
                .fetchMajors(studyProgramsList.first.epgId.toString())
            : Future.value([]);
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data: $e';
        _teachers = Future.value([]);
        _rooms = Future.value([]);
        _studyPrograms = Future.value([]);
        _majors = Future.value([]);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMajors(String studyProgramId) async {
    try {
      _majors = _majorService.fetchMajors(studyProgramId);
      setState(() => _selectedMajorId = null);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load majors: $e';
        _majors = Future.value([]);
      });
    }
  }

  Widget _buildDropdown<T>(
    Future<List<T>> future,
    String hint,
    String? value,
    List<DropdownMenuItem<String>> Function(List<T>) itemBuilder,
    void Function(String?) onChanged,
  ) {
    final locale = AppLocalizations.of(context);

    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text(locale!.noData);
        }
        final items = itemBuilder(snapshot.data!);
        return DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          dropdownColor: colorScheme.primaryContainer,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
          focusColor: colorScheme.primaryContainer,
          items: items.isNotEmpty
              ? items
              : [DropdownMenuItem(child: Text(locale!.noData))],
          onChanged: onChanged,
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _buildTeacherItems(List<Teacher> teachers) {
    return teachers.map((teacher) {
      return DropdownMenuItem<String>(
        value: teacher.id.toString(),
        child: Text(teacher.ime),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildRoomItems(List<Room> rooms) {
    return rooms.map((room) {
      return DropdownMenuItem<String>(
        value: room.id.toString(),
        child: Text(room.naziv),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildStudyProgramItems(
      List<StudyProgram> studyPrograms) {
    return studyPrograms.map((studyProgram) {
      return DropdownMenuItem<String>(
        value: studyProgram.epgId.toString(),
        child: Text(studyProgram.name),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildMajorItems(List<Major> majors) {
    return majors.map((major) {
      return DropdownMenuItem<String>(
        value: major.epId.toString(),
        child: Text(major.name),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Card(
        elevation: 8.0,
        color: colorScheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      minWidth: 280,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale!.selectSchedule,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(_errorMessage!,
                                  style: const TextStyle(color: Colors.red)),
                            ],
                            const SizedBox(height: 16),
                            _buildDropdown<Teacher>(
                              _teachers,
                              locale.teacher,
                              _selectedTeacherId,
                              _buildTeacherItems,
                              (value) {
                                setDialogState(() {
                                  _selectedTeacherId = value;
                                  _selectedRoomId = null;
                                  _selectedStudyProgramId = null;
                                  _selectedMajorId = null;
                                  _generatedUrl = value != null
                                      ? getScheduleByTeacherUrl(value)
                                      : null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown<Room>(
                              _rooms,
                              locale.room,
                              _selectedRoomId,
                              _buildRoomItems,
                              (value) {
                                setDialogState(() {
                                  _selectedTeacherId = null;
                                  _selectedRoomId = value;
                                  _selectedStudyProgramId = null;
                                  _selectedMajorId = null;
                                  _generatedUrl = value != null
                                      ? getScheduleByRoomUrl(value)
                                      : null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown<StudyProgram>(
                              _studyPrograms,
                              locale.studyProgram,
                              _selectedStudyProgramId,
                              _buildStudyProgramItems,
                              (value) {
                                setDialogState(() {
                                  _selectedTeacherId = null;
                                  _selectedRoomId = null;
                                  _selectedStudyProgramId = value;
                                  _selectedMajorId = null;
                                  _generatedUrl = null;
                                  if (value != null) _loadMajors(value);
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown<Major>(
                              _majors,
                              locale.year,
                              _selectedMajorId,
                              _buildMajorItems,
                              (value) {
                                setDialogState(() {
                                  _selectedMajorId = value;
                                  _generatedUrl = (value != null &&
                                          _selectedStudyProgramId != null)
                                      ? getScheduleUrl(
                                          _selectedStudyProgramId!, value)
                                      : null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(locale.save),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(locale.cancel),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _generatedUrl != null
                                      ? () =>
                                          Navigator.pop(context, _generatedUrl)
                                      : null,
                                  child: Text(locale.select),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
