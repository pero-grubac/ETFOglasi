import 'package:etf_oglasi/config/api_constants.dart';
import 'package:etf_oglasi/core/model/api/major.dart';
import 'package:etf_oglasi/core/model/api/room.dart';
import 'package:etf_oglasi/core/model/api/study_program.dart';
import 'package:etf_oglasi/core/model/api/teacher.dart';
import 'package:etf_oglasi/core/service/major_service.dart';
import 'package:etf_oglasi/core/service/room_service.dart';
import 'package:etf_oglasi/core/service/study_program_service.dart';
import 'package:etf_oglasi/core/service/teacher_service.dart';
import 'package:etf_oglasi/core/util/service_locator.dart';
import 'package:flutter/material.dart';

class ClassScheduleSettingsWidget extends StatefulWidget {
  const ClassScheduleSettingsWidget({super.key});

  @override
  State<ClassScheduleSettingsWidget> createState() =>
      _ClassScheduleSettingsWidget();
}

class _ClassScheduleSettingsWidget extends State<ClassScheduleSettingsWidget> {
  final TeacherService _teacherService = getIt<TeacherService>();
  final RoomService _roomService = getIt<RoomService>();
  final StudyProgramService _studyProgramService = getIt<StudyProgramService>();
  final MajorService _majorService = getIt<MajorService>();
  Future<List<Teacher>> _teachers = Future.value([]);
  Future<List<Room>> _rooms = Future.value([]);
  Future<List<StudyProgram>> _studyPrograms = Future.value([]);
  Future<List<Major>> _majors = Future.value([]);
  String? _selectedTeacherId;
  String? _selectedRoomId;
  String? _selectedStudyProgramId;
  String? _selectedMajorId;
  String? _generatedUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _teachers = _teacherService.fetchTeachers();
      _rooms = _roomService.fetchRooms();
      _studyPrograms = _studyProgramService.fetchStudyPrograms();

      final studyProgramsList = await _studyProgramService.fetchStudyPrograms();
      if (studyProgramsList.isNotEmpty) {
        final firstId = studyProgramsList.first.epgId.toString();
        _majors = _majorService.fetchMajors(firstId);
      } else {
        _majors = Future.value([]);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data: $e';
        _teachers = Future.value([]);
        _rooms = Future.value([]);
        _studyPrograms = Future.value([]);
        _majors = Future.value([]);
      });
    }
  }

  Future<void> _loadMajors(String studyProgramId) async {
    try {
      _majors = _majorService.fetchMajors(studyProgramId);
      setState(() {
        _selectedMajorId = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load majors: $e';
        _majors = Future.value([]);
      });
    }
  }

  Widget _buildTeacherDropdown(StateSetter setDialogState) {
    return FutureBuilder<List<Teacher>>(
      future: _teachers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading teachers');
        }
        final teachers = snapshot.data ?? [];
        return DropdownButton<String>(
          hint: const Text('Select Teacher'),
          value: _selectedTeacherId,
          isExpanded: true,
          items: teachers.map((teacher) {
            return DropdownMenuItem<String>(
              value: teacher.id.toString(),
              child: Text(teacher.ime),
            );
          }).toList(),
          onChanged: (value) {
            setDialogState(() {
              _selectedTeacherId = value;
              _selectedRoomId = null;
              _selectedStudyProgramId = null;
              _selectedMajorId = null;
              _generatedUrl =
                  value != null ? getScheduleByTeacherUrl(value) : null;
            });
          },
        );
      },
    );
  }

  Widget _buildRoomDropdown(StateSetter setDialogState) {
    return FutureBuilder<List<Room>>(
      future: _rooms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading rooms');
        }
        final rooms = snapshot.data ?? [];
        return DropdownButton<String>(
          hint: const Text('Select Room'),
          value: _selectedRoomId,
          isExpanded: true,
          items: rooms.map((room) {
            return DropdownMenuItem<String>(
              value: room.id.toString(),
              child: Text(room.naziv),
            );
          }).toList(),
          onChanged: (value) {
            setDialogState(() {
              _selectedTeacherId = null;
              _selectedRoomId = value;
              _selectedStudyProgramId = null;
              _selectedMajorId = null;
              _generatedUrl =
                  value != null ? getScheduleByRoomUrl(value) : null;
            });
          },
        );
      },
    );
  }

  Widget _buildStudyProgramDropdown(StateSetter setDialogState) {
    return FutureBuilder<List<StudyProgram>>(
      future: _studyPrograms,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading study programs');
        }
        final studyPrograms = snapshot.data ?? [];
        return DropdownButton<String>(
          hint: const Text('Select Study Program'),
          value: _selectedStudyProgramId,
          isExpanded: true,
          items: studyPrograms.map((studyProgram) {
            return DropdownMenuItem<String>(
              value: studyProgram.epgId.toString(),
              child: Text(studyProgram.name),
            );
          }).toList(),
          onChanged: (value) {
            setDialogState(() {
              _selectedTeacherId = null;
              _selectedRoomId = null;
              _selectedStudyProgramId = value;
              _selectedMajorId = null;
              _generatedUrl = null;
              if (value != null) {
                _loadMajors(value);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildMajorDropdown(StateSetter setDialogState) {
    return FutureBuilder<List<Major>>(
      future: _majors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading majors');
        }
        final majors = snapshot.data ?? [];
        return DropdownButton<String>(
          hint: const Text('Select Major'),
          value: _selectedMajorId,
          isExpanded: true,
          items: majors.map((major) {
            return DropdownMenuItem<String>(
              value: major.epgId.toString(),
              child: Text(major.name),
            );
          }).toList(),
          onChanged: (value) {
            setDialogState(() {
              _selectedMajorId = value;
              _generatedUrl = (value != null && _selectedStudyProgramId != null)
                  ? getScheduleUrl(_selectedStudyProgramId!, value)
                  : null;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, // Limit width for card-like appearance
              minWidth: 280,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Schedule Parameters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTeacherDropdown(setDialogState),
                    const SizedBox(height: 16),
                    _buildRoomDropdown(setDialogState),
                    const SizedBox(height: 16),
                    _buildStudyProgramDropdown(setDialogState),
                    const SizedBox(height: 16),
                    _buildMajorDropdown(setDialogState),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Set as default'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _generatedUrl != null
                              ? () => Navigator.pop(context, _generatedUrl)
                              : null,
                          child: const Text('Select'),
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
    );
  }
}
