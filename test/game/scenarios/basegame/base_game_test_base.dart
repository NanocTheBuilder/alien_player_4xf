import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';

Game newGame() {
  return Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL, [
    PlayerColor.GREEN,
    PlayerColor.YELLOW,
    PlayerColor.RED,
  ]);
}
