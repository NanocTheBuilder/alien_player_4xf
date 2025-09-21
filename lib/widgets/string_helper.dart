/*
 *  Copyright (C) 2021 Balázs Péter
 *
 *  This file is part of Alien Player 4XF.
 *
 *  Alien Player 4XF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Alien Player 4XF is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Alien Player 4XF.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:core';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';

class Strings {
  static const Map<PlayerColor, String> players = {
    PlayerColor.GREEN: "Green",
    PlayerColor.YELLOW: "Yellow",
    PlayerColor.RED: "Red",
    PlayerColor.BLUE: "Blue",
  };

  static const Map<String, String> shipTypes = {
    "RAIDER": "R",
    "CARRIER": "CV",
    "FIGHTER": "F",
    "BASE": "Base",
    "MINE": "Mine",
    "SCOUT": "SC",
    "DESTROYER": "DD",
    "CRUISER": "CA",
    "BATTLECRUISER": "BC",
    "BATTLESHIP": "BB",
    "DREADNAUGHT": "DN",
    "TITAN": "Titan",
    "TRANSPORT": "T",
    "INFANTRY": "Inf",
    "MARINE": "Mar",
    "HEAVY_INFANTRY": "HI",
    "GRAV_ARMOR": "Grav",
    "BOARDING_SHIP": "BD",
  };

  static const Map<String, String> fleetTypes = {
    "REGULAR_FLEET": "Regular Fleet",
    "RAIDER_FLEET": "Raider Fleet",
    "DEFENSE_FLEET": "Defense Fleet",
    "EXPANSION_FLEET": "Expansion Fleet",
    "EXTERMINATION_FLEET": "Extermination Fleet",
    "EXTERMINATION_FLEET_GALACTIC_CAPITAL":
        "Extermination Fleet (Galactic Capital)",
    "EXTERMINATION_FLEET_HOME_WORLD": "Extermination Fleet (Player Home World)",
  };

  static const Map<Technology, String> technologies = {
    Technology.MOVE: "Move",
    Technology.SHIP_SIZE: "Ship Size",
    Technology.ATTACK: "Attack",
    Technology.DEFENSE: "Defense",
    Technology.TACTICS: "Tactics",
    Technology.CLOAKING: "Cloaking",
    Technology.SCANNER: "Scanner",
    Technology.FIGHTERS: "Fighters",
    Technology.POINT_DEFENSE: "Point Defense",
    Technology.MINE_SWEEPER: "Mine Sweep",
    Technology.SECURITY_FORCES: "Security",
    Technology.MILITARY_ACADEMY: "Military Academy",
    Technology.BOARDING: "Boarding",
    Technology.GROUND_COMBAT: "Ground",
  };

  static const Map<Seeable, String> seeables = {
    Seeable.FIGHTERS: "Fighters",
    Seeable.MINES: "Mines",
    Seeable.BOARDING_SHIPS: "Boarding Ships",
    Seeable.VETERANS: "Veterans",
    Seeable.SIZE_3_SHIPS: "Size 3 Ships"
  };

  static String groups(Fleet fleet) {
    StringBuffer sb = StringBuffer();
    fleet.groups.forEach((element) {
      sb.write("[${element.size}\u00A0${shipTypes[element.shipType.name]}] ");
    });
    return sb.toString().trimRight();
  }

  static Map<Type, ScenarioBuildData> scenarioBuildData = {
    BaseGameScenario: ScenarioBuildData(
        "1 Player Alien Empire",
        BaseGameScenario.difficulties(),
        BaseGameDifficulty.NORMAL,
        () => BaseGameScenario()),
    Scenario4: ScenarioBuildData("Space Empires Solitaire Scenario #4",
        Scenario4.difficulties(), BaseGameDifficulty.NORMAL, () => Scenario4()),
    VpSoloScenario: ScenarioBuildData(
        "Alien Player VP Rules (Solitaire)",
        VpSoloScenario.difficulties(),
        VpSoloDifficulty.NORMAL,
        () => VpSoloScenario()),
    Vp2pScenario: ScenarioBuildData(
        "Alien Player Co-op (2 Players)",
        Vp2pScenario.difficulties(),
        Vp2pDifficulty.NORMAL,
        () => Vp2pScenario()),
    Vp3pScenario: ScenarioBuildData(
        "Alien Player Co-op (3 Players)",
        Vp3pScenario.difficulties(),
        Vp3pDifficulty.NORMAL,
        () => Vp3pScenario()),
  };

  static Map<String, String> difficulties = {
    "EASY": "Easy",
    "NORMAL": "Normal",
    "HARD": "Hard",
    "HARDER": "Harder",
    "REALLY_TOUGH": "Really Tough",
    "GOOD_LUCK": "Good Luck"
  };
}

class ScenarioBuildData {
  final String name;
  final List<Difficulty> difficulties;
  final Difficulty normalDifficulty;
  final Function constructor;

  ScenarioBuildData(
      this.name, this.difficulties, this.normalDifficulty, this.constructor);
}
