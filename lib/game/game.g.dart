// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
    const ScenarioConverter().fromJson(json['scenario'] as String),
    const DifficultyConverter().fromJson(json['difficulty'] as String),
    (json['aliens'] as List<dynamic>)
        .map((e) => AlienPlayer.fromJson(e as Map<String, dynamic>))
        .toList(),
  )
    ..seenLevels = (json['seenLevels'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(_$enumDecode(_$TechnologyEnumMap, k), e as int),
    )
    ..seenThings = (json['seenThings'] as List<dynamic>)
        .map((e) => _$enumDecode(_$SeeableEnumMap, e))
        .toSet()
    ..currentTurn = json['currentTurn'] as int;
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'scenario': const ScenarioConverter().toJson(instance.scenario),
      'aliens': instance.aliens.map((e) => e.toJson()).toList(),
      'seenLevels': instance.seenLevels
          .map((k, e) => MapEntry(_$TechnologyEnumMap[k], e)),
      'seenThings':
          instance.seenThings.map((e) => _$SeeableEnumMap[e]).toList(),
      'currentTurn': instance.currentTurn,
      'difficulty': const DifficultyConverter().toJson(instance.difficulty),
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

const _$SeeableEnumMap = {
  Seeable.FIGHTERS: 'FIGHTERS',
  Seeable.MINES: 'MINES',
  Seeable.BOARDING_SHIPS: 'BOARDING_SHIPS',
  Seeable.VETERANS: 'VETERANS',
  Seeable.SIZE_3_SHIPS: 'SIZE_3_SHIPS',
};
