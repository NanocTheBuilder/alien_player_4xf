import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game/alien_economic_sheet.dart';
import 'game/alien_player.dart';
import 'game/dice_roller.dart';
import 'game/enums.dart';
import 'game/fleet.dart';
import 'game/fleet_builders.dart';
import 'game/game.dart';
import 'game/scenario.dart';
import 'game/scenarios/base_game.dart';
import 'game/scenarios/scenario_4.dart';
import 'game/scenarios/vp_scenarios.dart';

class GameModel extends ChangeNotifier {
  Game? _game = null;

  GameModel() {
    //_game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);
    //_game = Game(Scenario4(), BaseGameDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);
    //_game = Game(VpSoloScenario(), VpSoloDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.BLUE]);
    //_game.roller = DiceRoller();
    loadGame();
  }

  void newGame(Scenario scenario, Difficulty difficulty,
      List<PlayerColor> playerColors) {
    _game = Game.newGame(scenario, difficulty, playerColors);
    _game!.roller = DiceRoller();
    notifyListeners();
    saveGame();
  }

  void saveGame() async {
    var json = jsonEncode(_game);
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString("game", json);
  }

  void loadGame() async {
    var prefs = await SharedPreferences.getInstance();
    try {
      _game = Game.fromJson(jsonDecode(prefs.getString("game")!));
      _game!.roller = DiceRoller();
      notifyListeners();
    } catch (e) {
      print(e);
      newGame(Scenario4(), BaseGameDifficulty.NORMAL,
          [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    }
  }

  List<AlienPlayer> get aliens => _game!.aliens;

  get scenario => _game?.scenario;

  get difficulty => _game!.difficulty;

  List<EconPhaseResult> doEconomicPhase() {
    var result = _game!.doEconomicPhase();
    notifyListeners();
    saveGame();
    return result;
  }

  FleetBuildResult buildHomeDefense(AlienPlayer ap) {
    var result = ap.buildHomeDefense();
    notifyListeners();
    saveGame();
    return result;
  }

  FleetBuildResult buildColonyDefense(Scenario4Player ap) {
    var result = ap.buildColonyDefense();
    notifyListeners();
    saveGame();
    return result;
  }

  FleetBuildResult firstCombat(AlienPlayer ap, Fleet fleet,
      [List<FleetBuildOption> options = const []]) {
    var result = ap.firstCombat(fleet, options);
    notifyListeners();
    saveGame();
    return result;
  }

  void deleteFleet(AlienPlayer ap, Fleet fleet) {
    ap.removeFleet(fleet);
    notifyListeners();
    saveGame();
  }

  void eliminate(AlienPlayer ap) {
    ap.isEliminated = true;
    notifyListeners();
    saveGame();
  }

  //These change the game state, but don't call notifyListeners.
  //Call "updateSeenThing" after all techs & seeables has been updated to call notifyListeners.
  int getSeenLevel(Technology technology) => _game!.getSeenLevel(technology);
  void setSeenLevel(Technology technology, int level) =>
      _game!.setSeenLevel(technology, level);
  bool isSeenThing(Seeable seeable) => _game!.isSeenThing(seeable);
  void addSeenThing(Seeable seeable) => _game!.addSeenThing(seeable);
  void removeSeenThing(Seeable seeable) => _game!.removeSeenThing(seeable);
  void setSeenThing(Seeable seeable, bool seen) {
    if (seen)
      _game!.addSeenThing(seeable);
    else
      _game!.removeSeenThing(seeable);
  }

  void finishUpdate() {
    notifyListeners();
    saveGame();
  }

  int getMaxLevel(Technology technology) =>
      _game!.scenario.getMaxLevel(technology);

  void setLevel(AlienPlayer alienPlayer, Technology technology, int level) {
    alienPlayer.technologyLevels[technology] = level;
    notifyListeners();
    saveGame();
  }

  void setColonies(AlienPlayer alienPlayer, int colonies) {
    (alienPlayer as VpAlienPlayer).colonies = colonies;
    notifyListeners();
    saveGame();
  }

  get currentTurn => _game!.currentTurn;

  bool showDetails = false;

  get started => _game != null;
}
