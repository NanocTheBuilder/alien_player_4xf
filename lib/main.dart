import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/dice_roller.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/widgets/game_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Map PlayerColors = {
  PlayerColor.RED: Color.fromARGB(255, 255, 0, 0),
  PlayerColor.GREEN: Color.fromARGB(255, 0, 255, 0),
  PlayerColor.BLUE: Color.fromARGB(255, 0, 0, 255),
  PlayerColor.YELLOW: Color.fromARGB(255, 255, 255, 0),
};

void main() {
  runApp(
      ChangeNotifierProvider<GameModel>(create: (context) => GameModel(), child: MyApp()));
}

class GameModel extends ChangeNotifier {
  Game _game;

  GameModel() {
    _game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);
    _game.roller = DiceRoller();
  }

  get aliens => _game.aliens;

  List<EconPhaseResult> doEconomicPhase() {
    var result = _game.doEconomicPhase();
    notifyListeners();
    return result;
  }

  get currentTurn => _game.currentTurn;

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien Player 4X App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GamePage(title: 'Alien Player 4X Main'),
    );
  }
}

