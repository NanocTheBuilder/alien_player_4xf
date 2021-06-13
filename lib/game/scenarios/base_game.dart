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

import 'package:json_annotation/json_annotation.dart';

import '../alien_economic_sheet.dart';
import '../alien_player.dart';
import '../enums.dart';
import '../fleet.dart';
import '../fleet_builders.dart';
import '../fleet_launcher.dart';
import '../game.dart';
import '../scenario.dart';
import '../technology_buyer.dart';

class BaseGameDifficulty extends Difficulty{
  static const BaseGameDifficulty EASY = BaseGameDifficulty('EASY', 5, 2);
  static const BaseGameDifficulty NORMAL = BaseGameDifficulty('NORMAL', 5, 3);
  static const BaseGameDifficulty HARD = BaseGameDifficulty('HARD', 10, 2);
  static const BaseGameDifficulty HARDER = BaseGameDifficulty('HARDER', 10, 3);
  static const BaseGameDifficulty REALLY_TOUGH =
      BaseGameDifficulty('REALLY_TOUGH', 15, 2);
  static const BaseGameDifficulty GOOD_LUCK =
      BaseGameDifficulty('GOOD_LUCK', 15, 3);

  const BaseGameDifficulty(name, cpPerEcon, numberOfAlienPlayers)
      : super(name, cpPerEcon, numberOfAlienPlayers);

  static List<BaseGameDifficulty> get values =>
      const [EASY, NORMAL, HARD, HARDER, REALLY_TOUGH, GOOD_LUCK];
}

class BaseGameDifficultyConverter implements JsonConverter<BaseGameDifficulty, String>{
  const BaseGameDifficultyConverter();

  @override
  BaseGameDifficulty fromJson(String json) {
    return BaseGameDifficulty.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(BaseGameDifficulty object) {
    return object.name;
  }
}

class BaseGameScenario extends Scenario {
  @override
  void init(Game game) {
    techBuyer = BaseGameTechnologyBuyer(game);
    techPrices = BaseGameTechnologyPrices();
    fleetBuilder = FleetBuilder(game);
    defenseBuilder = DefenseBuilder(game);
    fleetLauncher = FleetLauncher(game);
  }

  @override
  AlienPlayer newPlayer(Difficulty difficulty, PlayerColor color) {
    return AlienPlayer(AlienEconomicSheet(difficulty), color);
  }

  static List<Difficulty> difficulties() => const [
        BaseGameDifficulty.EASY,
        BaseGameDifficulty.NORMAL,
        BaseGameDifficulty.HARD,
        BaseGameDifficulty.HARDER,
        BaseGameDifficulty.REALLY_TOUGH,
        BaseGameDifficulty.GOOD_LUCK
      ];
}

class BaseGameTechnologyBuyer extends TechnologyBuyer {
  static const SHIP_SIZE_ROLL_TABLE = const [0, 10, 7, 6, 5, 3];

  BaseGameTechnologyBuyer(Game game) : super(game);

  @override
  void initRollTable() {
    addToRollTable(Technology.ATTACK, 2);
    addToRollTable(Technology.DEFENSE, 2);
    addToRollTable(Technology.TACTICS, 1);
    addToRollTable(Technology.CLOAKING, 1);
    addToRollTable(Technology.SCANNER, 1);
    addToRollTable(Technology.FIGHTERS, 1);
    addToRollTable(Technology.POINT_DEFENSE, 1);
    addToRollTable(Technology.MINE_SWEEPER, 1);
  }

  @override
  List<int> get shipSizeRollTable => SHIP_SIZE_ROLL_TABLE;

  @override
  void buyOptionalTechs(AlienPlayer ap, Fleet fleet, [List<FleetBuildOption> options = const[]]) {
    buyPointDefenseIfNeeded(ap);
    buyMineSweepIfNeeded(ap);
    buyScannerIfNeeded(ap);
    buyShipSizeIfRolled(ap);
    buyFightersIfNeeded(ap);
    buyCloakingIfNeeded(ap, fleet);
  }
}

class BaseGameTechnologyPrices extends TechnologyPrices {
  BaseGameTechnologyPrices() {
    init(Technology.MOVE, const [1, 0, 20, 25, 25, 25, 20, 20]);
    init(Technology.SHIP_SIZE, const [1, 0, 10, 15, 20, 20, 20]);
    //init(MINES,0, 20);

    init(Technology.ATTACK, const [0, 20, 30, 25]);
    init(Technology.DEFENSE, const [0, 20, 30, 25]);
    init(Technology.TACTICS, const [0, 15, 15, 15]);
    init(Technology.CLOAKING, const [0, 30, 30]);
    init(Technology.SCANNER, const [0, 20, 20]);
    init(Technology.FIGHTERS, const [0, 25, 25, 25]);
    init(Technology.POINT_DEFENSE, const [0, 20, 20, 20]);
    init(Technology.MINE_SWEEPER, const [0, 10, 15]);
  }
}
