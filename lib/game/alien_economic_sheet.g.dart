// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alien_economic_sheet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlienEconomicSheet _$AlienEconomicSheetFromJson(Map<String, dynamic> json) {
  return AlienEconomicSheet(
    const DifficultyConverter().fromJson(json['difficulty'] as String),
    extraEcon: List<int>.from(json['extraEcon']),
  )
    ..fleetCP = json['fleetCP'] as int
    ..techCP = json['techCP'] as int
    ..defCP = json['defCP'] as int;
}

Map<String, dynamic> _$AlienEconomicSheetToJson(AlienEconomicSheet instance) =>
    <String, dynamic>{
      'difficulty': const DifficultyConverter().toJson(instance.difficulty),
      'fleetCP': instance.fleetCP,
      'techCP': instance.techCP,
      'defCP': instance.defCP,
      'extraEcon': instance.extraEcon,
    };
