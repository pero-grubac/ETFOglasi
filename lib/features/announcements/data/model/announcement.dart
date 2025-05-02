import 'package:json_annotation/json_annotation.dart';
part 'announcement.g.dart';

@JsonSerializable()
class Announcement {
  final int id;
  final String naslov;
  final String? uvod;
  final String sadrzaj;
  final String? potpis;
  final DateTime vrijemeKreiranja;
  final DateTime vrijemeIsteka;
  final OglasnaPloca oglasnaPloca;
  final dynamic korisnickiNalog;
  final List<OglasPrilog> oglasPrilozi;

  Announcement({
    required this.id,
    required this.naslov,
    this.uvod,
    required this.sadrzaj,
    this.potpis,
    required this.vrijemeKreiranja,
    required this.vrijemeIsteka,
    required this.oglasnaPloca,
    this.korisnickiNalog,
    required this.oglasPrilozi,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);
}

@JsonSerializable()
class OglasnaPloca {
  final int id;
  final String? naziv;
  final String? opis;
  final String? napomena;

  OglasnaPloca({
    required this.id,
    this.naziv,
    this.opis,
    this.napomena,
  });

  factory OglasnaPloca.fromJson(Map<String, dynamic> json) =>
      _$OglasnaPlocaFromJson(json);

  Map<String, dynamic> toJson() => _$OglasnaPlocaToJson(this);
}

@JsonSerializable()
class OglasPrilog {
  final int id;
  final String naziv;
  final int velicina;
  final String originalniNaziv;
  final String ekstenzija;

  OglasPrilog({
    required this.id,
    required this.naziv,
    required this.velicina,
    required this.originalniNaziv,
    required this.ekstenzija,
  });

  factory OglasPrilog.fromJson(Map<String, dynamic> json) =>
      _$OglasPrilogFromJson(json);

  Map<String, dynamic> toJson() => _$OglasPrilogToJson(this);
}
