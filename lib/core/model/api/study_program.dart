import 'package:json_annotation/json_annotation.dart';
part 'study_program.g.dart';

@JsonSerializable()
class StudyProgram {
  final int epgId;
  final String name;
  final int extId;

  StudyProgram({
    required this.epgId,
    required this.name,
    required this.extId,
  });

  factory StudyProgram.fromJson(Map<String, dynamic> json) =>
      _$StudyProgramFromJson(json);

  Map<String, dynamic> toJson() => _$StudyProgramToJson(this);
}
