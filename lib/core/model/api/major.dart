import 'package:json_annotation/json_annotation.dart';
part 'major.g.dart';

@JsonSerializable()
class Major {
  final int epId;
  final String name;
  final String code;
  final String semester;
  final int extId;
  final int epgId;

  Major({
    required this.epId,
    required this.name,
    required this.code,
    required this.semester,
    required this.extId,
    required this.epgId,
  });

  factory Major.fromJson(Map<String, dynamic> json) => _$MajorFromJson(json);

  Map<String, dynamic> toJson() => _$MajorToJson(this);
}
