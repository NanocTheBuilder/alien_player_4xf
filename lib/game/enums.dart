/*
 *  Copyright (C) 2021 Balázs Péter
 *
 *  This file is part of Alien Player 4X.
 *
 *  Alien Player 4XF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Alien Player 4X is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Alien Player 4X.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class Difficulty {
  final String name;
  final int cpPerEcon;
  final int numberOfAlienPlayers;

  const Difficulty(this.name, this.cpPerEcon, this.numberOfAlienPlayers);
}

class DifficultyConverter implements JsonConverter<Difficulty, String>{
  const DifficultyConverter();

  @override
  Difficulty fromJson(String json) {
    var split = json.split("\.");
    var value = split[1];
    switch(split[0]){
      case "VpSoloDifficulty":
        return VpSoloDifficultyConverter().fromJson(value);
      case "Vp2pDifficulty":
        return Vp2pDifficultyConverter().fromJson(value);
      case "Vp3pDifficulty":
        return Vp3pDifficultyConverter().fromJson(value);
      case "BaseGameDifficulty":
        return BaseGameDifficultyConverter().fromJson(value);
      default:
        throw UnimplementedError();
    }
  }

  @override
  String toJson(Difficulty object) {
    return object.runtimeType.toString() + "." + object.name;
  }
}

class FleetType {
  static const FleetType REGULAR_FLEET =
      FleetType("REGULAR_FLEET", FleetNameSequence.BASIC);
  static const FleetType RAIDER_FLEET =
      FleetType("RAIDER_FLEET", FleetNameSequence.RAIDER);
  static const FleetType DEFENSE_FLEET =
      FleetType("DEFENSE_FLEET", FleetNameSequence.DEFENSE);
  static const FleetType EXPANSION_FLEET =
      FleetType("EXPANSION_FLEET", FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_GALACTIC_CAPITAL = FleetType(
      "EXTERMINATION_FLEET_GALACTIC_CAPITAL", FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_HOME_WORLD =
      FleetType("EXTERMINATION_FLEET_HOME_WORLD", FleetNameSequence.BASIC);

  final String name;
  final FleetNameSequence sequence;

  const FleetType(this.name, this.sequence);

  bool isSameNameSequence(FleetType other) => sequence == other.sequence;
}

class FleetTypeConverter implements JsonConverter<FleetType, String> {
  const FleetTypeConverter();

  static const List<FleetType> values = [
    FleetType.REGULAR_FLEET,
    FleetType.RAIDER_FLEET,
    FleetType.DEFENSE_FLEET,
    FleetType.EXPANSION_FLEET,
    FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL,
    FleetType.EXTERMINATION_FLEET_HOME_WORLD
  ];

  @override
  FleetType fromJson(String json) {
    return values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(FleetType object) {
    return object.name;
  }
}

enum FleetNameSequence { BASIC, DEFENSE, RAIDER }

enum PlayerColor { GREEN, YELLOW, RED, BLUE }

enum Seeable { FIGHTERS, MINES, BOARDING_SHIPS, VETERANS, SIZE_3_SHIPS }

enum Technology {
  MOVE,
  SHIP_SIZE,
  ATTACK,
  DEFENSE,
  TACTICS,
  CLOAKING,
  SCANNER,
  FIGHTERS,
  POINT_DEFENSE,
  MINE_SWEEPER,
  SECURITY_FORCES,
  MILITARY_ACADEMY,
  BOARDING,
  GROUND_COMBAT
}

enum FleetBuildOption { COMBAT_IS_ABOVE_PLANET, HOME_DEFENSE, COMBAT_WITH_NPAS }

class ShipType {
  static const ShipType RAIDER = ShipType("RAIDER", 12, 2, 99);
  static const ShipType CARRIER = ShipType("CARRIER", 12, 1, 99);
  static const ShipType FIGHTER = ShipType("FIGHTER", 5, 1, 99);
  static const ShipType BASE = ShipType("BASE", 12, 3, 99);
  static const ShipType MINE = ShipType("MINE", 5, 1, 99);
  static const ShipType SCOUT = ShipType("SCOUT", 6, 1, 1);
  static const ShipType DESTROYER = ShipType("DESTROYER", 9, 1, 2);
  static const ShipType CRUISER = ShipType("CRUISER", 12, 2, 3);
  static const ShipType BATTLECRUISER = ShipType("BATTLECRUISER", 15, 2, 4);
  static const ShipType BATTLESHIP = ShipType("BATTLESHIP", 20, 3, 5);
  static const ShipType DREADNAUGHT = ShipType("DREADNAUGHT", 24, 3, 6);
  static const ShipType TITAN = ShipType("TITAN", 32, 5, 7);

  static const ShipType TRANSPORT = ShipType("TRANSPORT", 6, 1, 99);
  static const ShipType INFANTRY = ShipType("INFANTRY", 2, 1, 99);
  static const ShipType MARINE = ShipType("MARINE", 3, 2, 99);
  static const ShipType HEAVY_INFANTRY = ShipType("HEAVY_INFANTRY", 3, 2, 99);
  static const ShipType GRAV_ARMOR = ShipType("GRAV_ARMOR", 4, 2, 99);
  static const ShipType BOARDING_SHIP = ShipType("BOARDING_SHIP", 12, 2, 99);

  static const List<ShipType> cheapToExpensive = [
    SCOUT,
    DESTROYER,
    CRUISER,
    BATTLECRUISER,
    BATTLESHIP,
    DREADNAUGHT,
    TITAN
  ];

  final String name;
  final int cost;
  final int hullSize;
  final int requiredShipSize;

  const ShipType(this.name, this.cost, this.hullSize, this.requiredShipSize);

  @override
  String toString() {
    return name;
  }

  bool canBeBuilt(int availableCP, int shipSizeLevel) =>
      availableCP >= cost && shipSizeLevel >= requiredShipSize;

  static ShipType findCheapest(int minHullSize) {
    return cheapToExpensive.firstWhere((type) => type.hullSize >= minHullSize,
        orElse: () => null as ShipType);
  }

  static Iterable<ShipType> getBiggerTypesInReverse(ShipType type) {
    return cheapToExpensive.reversed.where((t) => t.cost > type.cost);
  }

  static ShipType findBiggest(int availableCP, int shipSizeLevel) {
    return cheapToExpensive.reversed.firstWhere(
        (type) => type.canBeBuilt(availableCP, shipSizeLevel),
        orElse: () => null as ShipType);
  }
}

class ShipTypeConverter implements JsonConverter<ShipType, String> {
  const ShipTypeConverter();

  static const List<ShipType> values = [
    ShipType.RAIDER,
    ShipType.CARRIER,
    ShipType.FIGHTER,
    ShipType.BASE,
    ShipType.MINE,
    ShipType.SCOUT,
    ShipType.DESTROYER,
    ShipType.CRUISER,
    ShipType.BATTLECRUISER,
    ShipType.BATTLESHIP,
    ShipType.DREADNAUGHT,
    ShipType.TITAN,
    ShipType.TRANSPORT,
    ShipType.INFANTRY,
    ShipType.MARINE,
    ShipType.HEAVY_INFANTRY,
    ShipType.GRAV_ARMOR,
    ShipType.BOARDING_SHIP,
  ];

  @override
  ShipType fromJson(String json) {
    return values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(ShipType object) {
    return object.name;
  }
}
