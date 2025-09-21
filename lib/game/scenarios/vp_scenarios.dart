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

import 'package:json_annotation/json_annotation.dart';

import '../alien_economic_sheet.dart';
import '../alien_player.dart';
import '../dice_roller.dart';
import '../enums.dart';
import '../fleet.dart';
import '../fleet_launcher.dart';
import '../game.dart';
import 'scenario_4.dart';

part 'vp_scenarios.g.dart';

abstract class VpDifficulty extends Difficulty {
  final int startingBank;
  final int maxDefenseCp;

  const VpDifficulty(String name, int numberOfAlienPlayers, int cpPerEcon,
      this.startingBank, this.maxDefenseCp)
      : super(name, cpPerEcon, numberOfAlienPlayers);
}

class VpSoloDifficulty extends VpDifficulty {
  static const VpSoloDifficulty EASY = VpSoloDifficulty("EASY", 2, 5, 0, 50);
  static const VpSoloDifficulty NORMAL =
      VpSoloDifficulty("NORMAL", 2, 10, 100, 50);
  static const VpSoloDifficulty HARD = VpSoloDifficulty("HARD", 2, 15, 100, 50);

  const VpSoloDifficulty(String name, int numberOfAPs, int cpPerEcon,
      int startingBank, int maxDefenseCp)
      : super(name, numberOfAPs, cpPerEcon, startingBank, maxDefenseCp);

  static get values => const [EASY, NORMAL, HARD];
}

class VpSoloDifficultyConverter implements JsonConverter<VpSoloDifficulty, String> {
  const VpSoloDifficultyConverter();

  @override
  VpSoloDifficulty fromJson(String json) {
    return VpSoloDifficulty.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(VpSoloDifficulty object) {
    return object.name;
  }
}

class Vp2pDifficulty extends VpDifficulty {
  static const Vp2pDifficulty EASY = Vp2pDifficulty("EASY", 2, 5, 150, 75);
  static const Vp2pDifficulty NORMAL = Vp2pDifficulty("NORMAL", 2, 10, 150, 75);
  static const Vp2pDifficulty HARD = Vp2pDifficulty("HARD", 2, 15, 150, 75);

  const Vp2pDifficulty(String name, int numberOfAPs, int cpPerEcon,
      int startingBank, int maxDefenseCp)
      : super(name, numberOfAPs, cpPerEcon, startingBank, maxDefenseCp);

  static get values => const [EASY, NORMAL, HARD];
}

class Vp2pDifficultyConverter implements JsonConverter<Vp2pDifficulty, String> {
  const Vp2pDifficultyConverter();

  @override
  Vp2pDifficulty fromJson(String json) {
    return Vp2pDifficulty.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(Vp2pDifficulty object) {
    return object.name;
  }
}

class Vp3pDifficulty extends VpDifficulty {
  static const Vp3pDifficulty EASY = Vp3pDifficulty("EASY", 2, 10, 200, 125);
  static const Vp3pDifficulty NORMAL =
      Vp3pDifficulty("NORMAL", 2, 15, 200, 125);
  static const Vp3pDifficulty HARD = Vp3pDifficulty("HARD", 2, 20, 200, 155);

  const Vp3pDifficulty(String name, int numberOfAPs, int cpPerEcon,
      int startingBank, int maxDefenseCp)
      : super(name, numberOfAPs, cpPerEcon, startingBank, maxDefenseCp);

  static get values => const [EASY, NORMAL, HARD];
}

class Vp3pDifficultyConverter implements JsonConverter<Vp3pDifficulty, String> {
  const Vp3pDifficultyConverter();

  @override
  Vp3pDifficulty fromJson(String json) {
    return Vp3pDifficulty.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(Vp3pDifficulty object) {
    return object.name;
  }
}

@JsonSerializable()
@DifficultyConverter()
class VpEconomicSheet extends AlienEconomicSheet {
  int bank;

  VpEconomicSheet(Difficulty difficulty) : bank = (difficulty as VpDifficulty).startingBank, super(difficulty);

  factory VpEconomicSheet.fromJson(Map<String, dynamic> json) => _$VpEconomicSheetFromJson(json);
  Map<String, dynamic> toJson() {
    var json = _$VpEconomicSheetToJson(this);
    json["type"] = "VpEconomicSheet";
    return json;
  }

   //@formatter:off
  static final List<List<int>> resultTable = const [
    [99, 99, 99],
    [1, 2, 99],
    [1, 4, 99],
    [1, 4, 9],
    [1, 5, 9],
    [1, 7, 10],
    [1, 5, 10],
    [1, 6, 10],
    [1, 6, 10],
    [1, 6, 10],
    [1, 8, 10],
    [1, 8, 10],
    [1, 8, 10],
    [1, 7, 99],
    [1, 7, 99],
    [1, 8, 99],
    [1, 8, 99],
    [1, 9, 99],
    [1, 9, 99],
    [1, 10, 99],
    [1, 10, 99],
  ];

  static var econRolls = const [
    -99,
    2,
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    4,
    5,
    5,
    5,
    5,
    5,
    5
  ];
  static var fleetLaunch = const [
    -99,
    -99,
    10,
    10,
    5,
    10,
    4,
    10,
    4,
    5,
    6,
    4,
    6,
    3,
    10,
    3,
    10,
    3,
    10,
    3,
    10
  ];
  //@formatter:on

  @override
  EconRollResult makeRoll(int turn, DiceRoller roller) {
    EconRollResult result = EconRollResult();
    int limit = 10;
    if (defCP == (difficulty as VpDifficulty).maxDefenseCp &&
        requiredRoll(turn, AlienEconomicSheet.RESULT_DEF) != 99) {
      limit = requiredRoll(turn, AlienEconomicSheet.RESULT_DEF) - 1;
    }

    int roll = roller.roll(limit);
    if (roll >= requiredRoll(turn, AlienEconomicSheet.RESULT_DEF)) {
      int defCP = 2 * difficulty.cpPerEcon;
      this.defCP += defCP;
      result.defCP = defCP;
    } else if (roll >= requiredRoll(turn, AlienEconomicSheet.RESULT_TECH)) {
      int techCP = difficulty.cpPerEcon;
      this.techCP += techCP;
      result.techCP = techCP;
    } else {
      int fleetCP = difficulty.cpPerEcon;
      this.fleetCP += fleetCP;
      result.fleetCP = fleetCP;
    }

    int maxDefenseCp = (difficulty as VpDifficulty).maxDefenseCp;
    if (defCP > maxDefenseCp) {
      bank += defCP - maxDefenseCp;
      defCP = maxDefenseCp;
    }
    return result;
  }

  @override
  int requiredRoll(int turn, int result) {
    return VpEconomicSheet.resultTable[getResultTableRow(turn)][result];
  }

  @override
  int getExtraEcon(int turn) {
    return 0;
  }

  @override
  int getEconRolls(int turn) {
    return econRolls[getResultTableRow(turn)];
  }

  @override
  int getFleetLaunch(int turn) {
    return VpEconomicSheet.fleetLaunch[getResultTableRow(turn)];
  }

  bool get isMaxDefCP => defCP == (difficulty as VpDifficulty).maxDefenseCp;

  void spendBank(int amount) {
    bank -= amount;
  }

  @override
  void spendDefCP(int amount) {
    defCP -= amount > bank ? amount - bank : 0;
    bank -= amount > bank ? bank : amount;
  }
}

class VpSoloScenario extends Scenario4 {
  @override
  void init(Game game) {
    techBuyer = Scenario4TechnologyBuyer(game);
    techPrices = Scenario4TechnologyPrices();
    fleetBuilder = VpFleetBuilder(game);
    defenseBuilder = VpDefenseBuilder(game);
    fleetLauncher = VpSoloFleetLauncher(game);
  }

  @override
  AlienPlayer newPlayer(Difficulty difficulty, PlayerColor color) {
    return VpAlienPlayer(VpEconomicSheet(difficulty as VpDifficulty), color);
  }

  static List<Difficulty> difficulties() => VpSoloDifficulty.values;
}

class Vp2pScenario extends VpSoloScenario {
  @override
  void init(Game game) {
    techBuyer = Scenario4TechnologyBuyer(game);
    techPrices = Scenario4TechnologyPrices();
    fleetBuilder = VpFleetBuilder(game);
    defenseBuilder = VpDefenseBuilder(game);
    fleetLauncher = VpCoopFleetLauncher(game);
  }

  static List<Difficulty> difficulties() => Vp2pDifficulty.values;
}

class Vp3pScenario extends Vp2pScenario {
  static List<Difficulty> difficulties() => Vp3pDifficulty.values;
}

@JsonSerializable()
class VpAlienPlayer extends Scenario4Player {
  int colonies = 0;

  VpAlienPlayer(VpEconomicSheet economicSheet, PlayerColor color)
      : super(economicSheet, color);

  @override
  int getExtraEconRoll(int turn) {
    return colonies;
  }

  factory VpAlienPlayer.fromJson(Map<String, dynamic> json) => _$VpAlienPlayerFromJson(json);

  @override
  Map<String, dynamic> toJson(){
    var json = _$VpAlienPlayerToJson(this);
    json["type"] = "VpAlienPlayer";
    return json;
  }
}

class VpFleetBuilder extends Scenario4FleetBuilder {
  VpFleetBuilder(Game game) : super(game);

  @override
  void buildOneFullyLoadedTransport(AlienPlayer ap, Fleet fleet,
      [List<FleetBuildOption> options = const []]) {
    if (fleet.fleetType == FleetType.EXPANSION_FLEET) {
      super.buildOneFullyLoadedTransport(ap, fleet);
    } else if (fleet.remainingCP >= 40) {
      int roll = game.roller.roll();
      if (options.contains(FleetBuildOption.COMBAT_IS_ABOVE_PLANET)) roll -= 2;
      if (roll <= 5) {
        fleet.addGroup(Group(ShipType.TRANSPORT, 1));
        buildGroundUnits(ap, fleet).forEach((group) => fleet.addGroup(group));
      }
    }
  }
}

class VpDefenseBuilder extends Scenario4DefenseBuilder {
  VpDefenseBuilder(Game game) : super(game);

  @override
  int getDefCp(AlienPlayer ap) {
    VpEconomicSheet sheet = (ap.economicSheet as VpEconomicSheet);
    return sheet.defCP + sheet.bank;
  }
}

class VpSoloFleetLauncher extends FleetLauncher {
  VpSoloFleetLauncher(Game game) : super(game);

  @override
  Fleet? launchFleet(AlienPlayer ap, int turn,
      [List<FleetBuildOption> options = const []]) {
    int bank = (ap.economicSheet as VpEconomicSheet).bank;
    Fleet? fleet = super.launchFleet(ap, turn, options);
    if (fleet == null) {
      if (bank >= 50) {
        fleet = Fleet.ofAlienPlayer(ap, FleetType.EXPANSION_FLEET, 0);
      }
    }
    if (fleet != null) {
      setFleetType(ap, fleet, turn);
    }
    return fleet;
  }

  void setFleetType(AlienPlayer ap, Fleet fleet, int turn) {
    var sheet = ap.economicSheet as VpEconomicSheet;
    if (fleet.fleetType == FleetType.REGULAR_FLEET) {
      int roll = game.roller.roll();
      if (turn > 7) roll += 2;
      if (turn > 10) roll += 2;
      if (roll < 8) {
        fleet.setFleetType(ap, FleetType.EXPANSION_FLEET);
      } else {
        fleet.setFleetType(ap, getExterminationFleetType(turn));
      }
    }

    if (fleet.fleetType == FleetType.EXPANSION_FLEET && sheet.bank >= 50) {
      fleet.addFleetCp(50);
      sheet.spendBank(50);
    }
  }

  FleetType getExterminationFleetType(int turn) {
    if (game.roller.roll(2) == 1)
      return FleetType.EXTERMINATION_FLEET_HOME_WORLD;
    else
      return FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL;
  }
}

class VpCoopFleetLauncher extends VpSoloFleetLauncher {
  VpCoopFleetLauncher(Game game) : super(game);

  @override
  FleetType getExterminationFleetType(int turn) {
    if ((turn & 1) == 1) {
      return FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL;
    } else
      return FleetType.EXTERMINATION_FLEET_HOME_WORLD;
  }
}
