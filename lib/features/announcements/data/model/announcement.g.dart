// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
      id: (json['id'] as num).toInt(),
      naslov: json['naslov'] as String,
      uvod: json['uvod'] as String?,
      sadrzaj: json['sadrzaj'] as String,
      potpis: json['potpis'] as String?,
      vrijemeKreiranja: DateTime.parse(json['vrijemeKreiranja'] as String),
      vrijemeIsteka: DateTime.parse(json['vrijemeIsteka'] as String),
      oglasnaPloca:
          OglasnaPloca.fromJson(json['oglasnaPloca'] as Map<String, dynamic>),
      korisnickiNalog: json['korisnickiNalog'],
      oglasPrilozi: (json['oglasPrilozi'] as List<dynamic>)
          .map((e) => OglasPrilog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naslov': instance.naslov,
      'uvod': instance.uvod,
      'sadrzaj': instance.sadrzaj,
      'potpis': instance.potpis,
      'vrijemeKreiranja': instance.vrijemeKreiranja.toIso8601String(),
      'vrijemeIsteka': instance.vrijemeIsteka.toIso8601String(),
      'oglasnaPloca': instance.oglasnaPloca,
      'korisnickiNalog': instance.korisnickiNalog,
      'oglasPrilozi': instance.oglasPrilozi,
    };

OglasnaPloca _$OglasnaPlocaFromJson(Map<String, dynamic> json) => OglasnaPloca(
      id: (json['id'] as num).toInt(),
      naziv: json['naziv'] as String?,
      opis: json['opis'] as String?,
      napomena: json['napomena'] as String?,
    );

Map<String, dynamic> _$OglasnaPlocaToJson(OglasnaPloca instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'opis': instance.opis,
      'napomena': instance.napomena,
    };

OglasPrilog _$OglasPrilogFromJson(Map<String, dynamic> json) => OglasPrilog(
      id: (json['id'] as num).toInt(),
      naziv: json['naziv'] as String,
      velicina: (json['velicina'] as num).toInt(),
      originalniNaziv: json['originalniNaziv'] as String,
      ekstenzija: json['ekstenzija'] as String,
    );

Map<String, dynamic> _$OglasPrilogToJson(OglasPrilog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'naziv': instance.naziv,
      'velicina': instance.velicina,
      'originalniNaziv': instance.originalniNaziv,
      'ekstenzija': instance.ekstenzija,
    };
