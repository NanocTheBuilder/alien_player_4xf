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

import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenario.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alien_economic_sheet.dart';
import 'dice_roller.dart';

part 'game.g.dart';

@JsonSerializable(explicitToJson: true)
@ScenarioConverter()
@DifficultyConverter()
class Game {
  @JsonKey(ignore: true)
  late DiceRoller roller;
  late Scenario scenario;
  late List<AlienPlayer> aliens;
  Map<Technology, int> seenLevels = {};
  Set<Seeable> seenThings = {};
  int currentTurn = 1;
  late Difficulty difficulty;

  Game(this.scenario, this.difficulty, this.aliens);

  static Game newGame(Scenario scenario, Difficulty difficulty,
      List<PlayerColor> playerColors) {
    var newGame = Game(
        scenario,
        difficulty,
        playerColors
            .map((color) => scenario.newPlayer(difficulty, color))
            .toList());
    newGame.init();
    return newGame;
  }

  void init() {
    scenario.init(this);
    aliens.forEach((element) => element.init(this));
    resetSeenLevels();
    currentTurn = 1;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    var game = _$GameFromJson(json);
    game.scenario.init(game);
    game.aliens.forEach((element) => element.init(game));
    return game;
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);

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
