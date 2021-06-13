// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario_4.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scenario4Player _$Scenario4PlayerFromJson(Map<String, dynamic> json) {
  return Scenario4Player(
    AlienEconomicSheet.fromJson(json['economicSheet'] as Map<String, dynamic>),
    _$enumDecode(_$PlayerColorEnumMap, json['color']),
  )
    ..fleets = (json['fleets'] as List<dynamic>)
        .map((e) => Fleet.fromJson(e as Map<String, dynamic>))
        .toList()
    ..technologyLevels = (json['technologyLevels'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(_$enumDecode(_$TechnologyEnumMap, k), e as int),
    )
    ..purchasedCloakThisTurn = json['purchasedCloakThisTurn'] as bool
    ..isEliminated = json['isEliminated'] as bool;
}

Map<String, dynamic> _$Scenario4PlayerToJson(Scenario4Player instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color],
      'economicSheet': instance.economicSheet.toJson(),
      'fleets': instance.fleets.map((e) => e.toJson()).toList(),
      'technologyLevels': instance.technologyLevels
          .map((k, e) => MapEntry(_$TechnologyEnumMap[k], e)),
      'purchasedCloakThisTurn': instance.purchasedCloakThisTurn,
      'isEliminated': instance.isEliminated,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$PlayerColorEnumMap = {
  PlayerColor.GREEN: 'GREEN',
  PlayerColor.YELLOW: 'YELLOW',
  PlayerColor.RED: 'RED',
  PlayerColor.BLUE: 'BLUE',
};

const _$TechnologyEnumMap = {
  Technology.MOVE: 'MOVE',
  Technology.SHIP_SIZE: 'SHIP_SIZE',
  Technology.ATTACK: 'ATTACK',
  Technology.DEFENSE: 'DEFENSE',
  Technology.TACTICS: 'TACTICS',
  Technology.CLOAKING: 'CLOAKING',
  Technology.SCANNER: 'SCANNER',
  Technology.FIGHTERS: 'FIGHTERS',
  Technology.POINT_DEFENSE: 'POINT_DEFENSE',
  Technology.MINE_SWEEPER: 'MINE_SWEEPER',
  Technology.SECURITY_FORCES: 'SECURITY_FORCES',
  Technology.MILITARY_ACADEMY: 'MILITARY_ACADEMY',
  Technology.BOARDING: 'BOARDING',
  Technology.GROUND_COMBAT: 'GROUND_COMBAT',
};
