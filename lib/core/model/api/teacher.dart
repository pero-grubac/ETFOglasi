import 'package:json_annotation/json_annotation.dart';
part 'teacher.g.dart';

@JsonSerializable()
class Teacher {
  final int id;
  final String ime;
  final String uloga;

  Teacher({
    required this.id,
    required this.ime,
    required this.uloga,
  });
  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}
