// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fleet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) {
  return Group(
    const ShipTypeConverter().fromJson(json['shipType'] as String),
    json['size'] as int,
  );
}

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'size': instance.size,
      'shipType': const ShipTypeConverter().toJson(instance.shipType),
    };

Fleet _$FleetFromJson(Map<String, dynamic> json) {
  return Fleet(
    json['name'] as String,
    const FleetTypeConverter().fromJson(json['fleetType'] as String),
    json['fleetCP'] as int,
  )
    ..groups = (json['groups'] as List<dynamic>)
        .map((e) => Group.fromJson(e as Map<String, dynamic>))
        .toList()
    ..freeGroups = (json['freeGroups'] as List<dynamic>)
        .map((e) => Group.fromJson(e as Map<String, dynamic>))
        .toList()
    ..hadFirstCombat = json['hadFirstCombat'] as bool;
}

Map<String, dynamic> _$FleetToJson(Fleet instance) => <String, dynamic>{
      'fleetType': const FleetTypeConverter().toJson(instance.fleetType),
      'name': instance.name,
      'fleetCP': instance.fleetCP,
      'groups': instance.groups.map((e) => e.toJson()).toList(),
      'freeGroups': instance.freeGroups.map((e) => e.toJson()).toList(),
      'hadFirstCombat': instance.hadFirstCombat,
    };
