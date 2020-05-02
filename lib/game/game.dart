import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenario.dart';
import 'package:flutter/foundation.dart';

import 'alien_economic_sheet.dart';
import 'dice_roller.dart';

class Game {
  DiceRoller roller;
  Scenario scenario;
  List<AlienPlayer> aliens;
  Map<Technology, int> seenLevels;
  Set<Seeable> seenThings;
  int currentTurn;
  Difficulty difficulty;

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
    return seenLevels[technology];
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
