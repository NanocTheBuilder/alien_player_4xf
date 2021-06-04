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

import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenario.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alien_economic_sheet.dart';
import 'dice_roller.dart';

@JsonSerializable()
class Game {
  late DiceRoller roller;
  late Scenario scenario;
  late List<AlienPlayer> aliens;
  Map<Technology, int> seenLevels = {};
  Set<Seeable> seenThings = {};
  int currentTurn = 1;
  late Difficulty difficulty;

  Game(this.scenario, this.difficulty, List playerColors) {
    scenario.init(this);
    aliens = [];
    for (int i = 0; i < difficulty.numberOfAlienPlayers; i++) {
      aliens.add(scenario.newPlayer(this, difficulty, playerColors[i]));
    }

    resetSeenLevels();
    currentTurn = 1;
  }

  void resetSeenLevels() {
    seenThings = {};
    seenLevels = {};
    for (Technology technology in scenario.availableTechs) {
      int startingLevel = scenario.getStartingLevel(technology);
      seenLevels[technology] = startingLevel;
    }
  }

  List<EconPhaseResult> doEconomicPhase() {
    List<EconPhaseResult> results = [];
    for (AlienPlayer ap in aliens) {
      if (!ap.isEliminated) {
        results.add(ap.makeEconRoll(currentTurn));
      }
    }
    currentTurn++;
    return results;
  }

  int getSeenLevel(Technology technology) {
    return seenLevels[technology]!;
  }

  void setSeenLevel(Technology technology, int level) {
    seenLevels[technology] = level;
  }

  void addSeenThing(Seeable seeable) {
    seenThings.add(seeable);
  }

  void removeSeenThing(Seeable seeable) {
    seenThings.remove(seeable);
  }

  bool isSeenThing(Seeable seeable) {
    return seenThings.contains(seeable);
  }
}
