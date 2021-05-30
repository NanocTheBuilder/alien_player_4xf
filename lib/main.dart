import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/dice_roller.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:alienplayer4xf/widgets/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'game/fleet.dart';

const Map PlayerColors = {
  PlayerColor.RED: Color.fromARGB(255, 255, 0, 0),
  PlayerColor.GREEN: Color.fromARGB(255, 0, 255, 0),
  PlayerColor.BLUE: Color.fromARGB(255, 0, 200, 255),
  PlayerColor.YELLOW: Color.fromARGB(255, 255, 255, 0),
};

void main() {
  runApp(ChangeNotifierProvider<GameModel>(
      create: (context) => GameModel(), child: MyApp()));
}

class GameModel extends ChangeNotifier {
  Game _game;

  GameModel() {
    //_game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);
    //_game = Game(Scenario4(), BaseGameDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);
    _game = Game(VpSoloScenario(), VpSoloDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.BLUE]);
    _game.roller = DiceRoller();
  }

  get aliens => _game.aliens;

  get scenario => _game.scenario;

  List<EconPhaseResult> doEconomicPhase() {
    var result = _game.doEconomicPhase();
    notifyListeners();
    return result;
  }

  FleetBuildResult buildHomeDefense(AlienPlayer ap){
    var result = ap.buildHomeDefense();
    notifyListeners();
    return result;
  }

  FleetBuildResult buildColonyDefense(Scenario4Player ap){
    var result = ap.buildColonyDefense();
    notifyListeners();
    return result;
  }

  FleetBuildResult firstCombat(Fleet fleet, [List<FleetBuildOption> options = const []]){
    var result = fleet.ap.firstCombat(fleet, options);
    notifyListeners();
    return result;
  }

  void deleteFleet(Fleet fleet){
    fleet.ap.removeFleet(fleet);
    notifyListeners();
  }

  void eliminate(AlienPlayer ap){
    ap.isEliminated = true;
    notifyListeners();
  }

  //These change the game state, but don't call notifyListeners.
  //Call "updateSeenThing" after all techs & seeables has been updated to call notifyListeners.
  int getSeenLevel(Technology technology) => _game.getSeenLevel(technology);
  void setSeenLevel(Technology technology, int level) => _game.setSeenLevel(technology, level);
  bool isSeenThing(Seeable seeable) => _game.isSeenThing(seeable);
  void addSeenThing(Seeable seeable) => _game.addSeenThing(seeable);
  void removeSeenThing(Seeable seeable) => _game.removeSeenThing(seeable);
  void setSeenThing(Seeable seeable, bool seen){
    if(seen)
      _game.addSeenThing(seeable);
    else
      _game.removeSeenThing(seeable);
  }
  void finishUpdate(){
    notifyListeners();
  }

  int getMaxLevel(Technology technology) => _game.scenario.getMaxLevel(technology);

  void setLevel(AlienPlayer alienPlayer, Technology technology, int level){
    alienPlayer.technologyLevels[technology] = level;
    notifyListeners();
  }

  void setColonies(AlienPlayer alienPlayer, int colonies){
    (alienPlayer as VpAlienPlayer).colonies = colonies;
    notifyListeners();
  }

  get currentTurn => _game.currentTurn;

  bool showDetails = true;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Alien Player 4X App',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: TextTheme(
            bodyText2: TextStyle(fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 1.3),
            button: TextStyle(fontSize: Theme.of(context).textTheme.button.fontSize * 1.3),
          )
        ),
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/smc_wing_full_2560.png",
                      bundle: DefaultAssetBundle.of(context)),
                  fit: BoxFit.cover)),
          child: GamePage(title: 'Alien Player 4X'),
        ));
  }
}
