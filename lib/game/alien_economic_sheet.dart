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

import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alien_player.dart';
import 'dice_roller.dart';
import 'enums.dart';
import 'fleet.dart';

part 'alien_economic_sheet.g.dart';

class EconRollResult {
  int fleetCP = 0;
  int techCP = 0;
  int defCP = 0;
  int extraEcon = 0;

  void add(EconRollResult other) {
    fleetCP += other.fleetCP;
    techCP += other.techCP;
    defCP += other.defCP;
    extraEcon += other.extraEcon;
  }
}

class EconPhaseResult extends EconRollResult {
  Fleet? fleet;
  AlienPlayer alienPlayer;
  bool moveTechRolled = false;

  EconPhaseResult(this.alienPlayer);
}

@JsonSerializable(explicitToJson: true)
@DifficultyConverter()
class AlienEconomicSheet {
  static const int RESULT_FLEET = 0;
  static const int RESULT_TECH = 1;
  static const int RESULT_DEF = 2;

  //@formatter:off
  static final List<List<int>> resultTable = const[
    [ 99, 99, 99],
    [ 99, 3, 99],
    [ 2, 4, 99],
    [ 2, 5, 9],
    [ 2, 6, 9],
    [ 2, 6, 10],
    [ 2, 7, 10],
    [ 1, 6, 10],
    [ 1, 6, 10],
    [ 1, 6, 10],
    [ 1, 7, 10],
    [ 1, 7, 10],
    [ 1, 7, 10],
    [ 1, 7, 99],
    [ 1, 7, 99],
    [ 1, 8, 99],
    [ 1, 8, 99],
    [ 1, 9, 99],
    [ 1, 9, 99],
    [ 1, 10, 99],
    [ 1, 10, 99],
  ];

  static var econRolls =   const[ -99,   1,  1,  2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,  4, 5,  5, 5,  5, 5,  5];
  static var fleetLaunch = const[ -99, -99, 10, 10, 5, 3, 4, 4, 4, 5, 5, 3, 3, 3, 10, 3, 10, 3, 10, 3, 10];

  //@formatter:on

  Difficulty difficulty;
  var fleetCP = 0;
  var techCP = 0;
  var defCP = 0;
  List<int> extraEcon;

  AlienEconomicSheet(this.difficulty, {extraEcon}) : this.extraEcon = extraEcon ?? [for(int i = 0; i < 21; i++) 0];

  factory AlienEconomicSheet.fromJson(Map<String, dynamic> json) {
    String type = json["type"];
    switch(type){
      case "AlienEconomicSheet":
        return _$AlienEconomicSheetFromJson(json);
      case "VpEconomicSheet":
        return VpEconomicSheet.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }
  Map<String, dynamic> toJson(){
    var json = _$AlienEconomicSheetToJson(this);
    json["type"] = "AlienEconomicSheet";
    return json;
  }

  EconRollResult makeRoll(int turn, DiceRoller roller) {
    EconRollResult result = EconRollResult();
    int roll = roller.roll();
    if (roll >= requiredRoll(turn, RESULT_DEF)) {
      int defCP = 2 * difficulty.cpPerEcon;
      this.defCP += defCP;
      result.defCP = defCP;
    }
    else if (roll >= requiredRoll(turn, RESULT_TECH)) {
      int techCP = difficulty.cpPerEcon;
      this.techCP += techCP;
      result.techCP = techCP;
    }
    else if (roll >= requiredRoll(turn, RESULT_FLEET)) {
      int fleetCP = difficulty.cpPerEcon;
      this.fleetCP += fleetCP;
      result.fleetCP = fleetCP;
    }
    else {
      for (int i = turn + 3; i < 21; i++)
        extraEcon[i] += 1;
      result.extraEcon = 1;
    }
    return result;
  }

  int requiredRoll(int turn, int result) {
    return AlienEconomicSheet.resultTable[getResultTableRow(turn)][result];
  }

  int getResultTableRow(int turn) {
    return turn < 20 ? turn : 20 - (turn % 2);
  }

  int getExtraEcon(int turn) => extraEcon[getResultTableRow(turn)];

  int getEconRolls(int turn) =>
      AlienEconomicSheet.econRolls[getResultTableRow(turn)];

  int getFleetLaunch(int turn) =>
      AlienEconomicSheet.fleetLaunch[getResultTableRow(turn)];

  void spendFleetCP(int amount) {
    fleetCP -= amount;
  }

  void addFleetCP(int amount) {
    fleetCP += amount;
  }

  void spendTechCP(int amount) {
    techCP -= amount;
  }

  int getDefCP() => defCP;

  void spendDefCP(int amount) {
    defCP -= amount;
  }
}
