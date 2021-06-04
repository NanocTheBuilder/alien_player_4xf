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

import 'dart:core';

import 'package:alienplayer4xf/game/game.dart';

import 'alien_economic_sheet.dart';
import 'enums.dart';
import 'fleet.dart';
import 'fleet_builders.dart';

class AlienPlayer {
  Game game;
  PlayerColor color;
  AlienEconomicSheet economicSheet;
  List<Fleet> fleets = [];
  Map<Technology, int> technologyLevels = {};

  var purchasedCloakThisTurn = false;
  var isEliminated = false;

  AlienPlayer(this.economicSheet, this.game, this.color) {
    for (Technology technology in game.scenario.availableTechs) {
      var startingLevel = game.scenario.getStartingLevel(technology);
      technologyLevels[technology] = startingLevel;
    }
  }

  EconPhaseResult makeEconRoll(int turn) {
    var result = EconPhaseResult(this);
    var econRolls = economicSheet.getEconRolls(turn) + getExtraEconRoll(turn);
    for (int i = 0; i < econRolls; i++) {
      EconRollResult rollResult = economicSheet.makeRoll(turn, game.roller);
      result.add(rollResult);
    }
    var newFleet = game.scenario.rollFleetLaunch(this, turn);
    if (newFleet != null) {
      result.fleet = newFleet;
      result.moveTechRolled = buyNextMoveLevel();
    }
    return result;
  }

  int getExtraEconRoll(int turn) => economicSheet.getExtraEcon(turn);

  void buyTechs(Fleet fleet, [List<FleetBuildOption> options = const[]]) {
    purchasedCloakThisTurn = false;
    game.scenario.buyTechs(fleet, options);
  }

  FleetBuildResult firstCombat(Fleet fleet, [List<FleetBuildOption> options = const []]) {
    var result = FleetBuildResult(this);
    var oldTechValues = Map.fromIterable(game.scenario.availableTechs,
        key: (tech) => tech, value: (tech) => technologyLevels[tech]);
    buyTechs(fleet, options);
    if (FleetType.RAIDER_FLEET != fleet.fleetType) {
      game.scenario.buildFleet(fleet, options);
      economicSheet.addFleetCP(fleet.fleetCP - fleet.buildCost);
      result.newFleets.add(fleet);
    }
    fleet.hadFirstCombat = true;
    for (Technology technology in game.scenario.availableTechs) {
      if (oldTechValues[technology] != getLevel(technology)) {
        result.newTechs[technology] = getLevel(technology);
      }
    }
    return result;
  }

  void removeFleet(Fleet fleet) => fleets.remove(fleet);

  FleetBuildResult buildHomeDefense() {
    var result = FleetBuildResult(this);
    Fleet? fleet = game.scenario.fleetLauncher
        .launchFleet(this, game.currentTurn, [FleetBuildOption.HOME_DEFENSE]);
    if (fleet != null) {
      result = firstCombat(fleet, [
        FleetBuildOption.HOME_DEFENSE,
        FleetBuildOption.COMBAT_IS_ABOVE_PLANET
      ]);
    }

    Fleet? defenseFleet = game.scenario.buildHomeDefense(this);
    if (defenseFleet != null) {
      economicSheet.spendDefCP(defenseFleet.buildCost);
      defenseFleet.hadFirstCombat = true;
      result.addNewFleet(defenseFleet);
    }

    return result;
  }

  bool buyNextMoveLevel() {
    int oldLevel = technologyLevels[Technology.MOVE]!;
    if (game.roller.roll() <= 4) {
      game.scenario.buyNextLevel(this, Technology.MOVE);
    }
    return technologyLevels[Technology.MOVE] != oldLevel;
  }

  int getLevel(Technology technology) => technologyLevels[technology]!;

  void setLevel(Technology technology, int level) {
    technologyLevels[technology] = level;
  }

  String findFleetName(FleetType fleetType) {
    for (int i = 1; i < 100; i++) {
      if (findFleetByName(i.toString(), fleetType) == null) {
        return i.toString();
      }
    }
    return "?";
  }

  Fleet? findFleetByName(String name, FleetType fleetType) {
    return fleets.cast<Fleet?>().firstWhere(
        (fleet) =>
            fleet!.name == name && fleet.fleetType.isSameNameSequence(fleetType),
        orElse: () => null);
  }
}
