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

import '../alien_economic_sheet.dart';
import '../alien_player.dart';
import '../enums.dart';
import '../fleet.dart';
import '../fleet_builders.dart';
import '../fleet_launcher.dart';
import '../game.dart';
import '../scenario.dart';
import '../technology_buyer.dart';
import 'base_game.dart';

class Scenario4 extends Scenario {
  @override
  void init(Game game) {
    techBuyer = Scenario4TechnologyBuyer(game);
    techPrices = Scenario4TechnologyPrices();
    fleetBuilder = Scenario4FleetBuilder(game);
    defenseBuilder = Scenario4DefenseBuilder(game);
    fleetLauncher = FleetLauncher(game);
  }

  @override
  AlienPlayer newPlayer(Game game, Difficulty difficulty, PlayerColor color) {
    return Scenario4Player(AlienEconomicSheet(difficulty), game, color);
  }

  static List<Difficulty> difficulties() => const [
        BaseGameDifficulty.EASY,
        BaseGameDifficulty.NORMAL,
        BaseGameDifficulty.HARD,
        BaseGameDifficulty.HARDER,
        BaseGameDifficulty.REALLY_TOUGH,
        BaseGameDifficulty.GOOD_LUCK
      ];

  Fleet buildColonyDefense(AlienPlayer alienPlayer) {
    return (defenseBuilder as Scenario4DefenseBuilder)
        .buildColonyDefense(alienPlayer);
  }
}

class Scenario4Player extends AlienPlayer {
  Scenario4Player(AlienEconomicSheet sheet, Game game, PlayerColor color)
      : super(sheet, game, color);

  FleetBuildResult buildColonyDefense() {
    FleetBuildResult result = FleetBuildResult(this);
    Fleet fleet = (game.scenario as Scenario4).buildColonyDefense(this);
    if (fleet != null) {
      economicSheet.spendDefCP(fleet.buildCost);
      fleet.hadFirstCombat = true;
      result.addNewFleet(fleet);
    }
    return result;
  }
}

class Scenario4TechnologyBuyer extends TechnologyBuyer {
  static const List<int> SHIP_SIZE_ROLL_TABLE = const [0, 10, 7, 6, 5, 3, 6];

  Scenario4TechnologyBuyer(Game game) : super(game);

  @override
  void initRollTable() {
    addToRollTable(Technology.SHIP_SIZE, 16);
    addToRollTable(Technology.ATTACK, 20);
    addToRollTable(Technology.DEFENSE, 20);
    addToRollTable(Technology.TACTICS, 12);
    addToRollTable(Technology.CLOAKING, 3);
    addToRollTable(Technology.SCANNER, 2);
    addToRollTable(Technology.FIGHTERS, 8);
    addToRollTable(Technology.POINT_DEFENSE, 3);
    addToRollTable(Technology.MINE_SWEEPER, 5);
    addToRollTable(Technology.SECURITY_FORCES, 3);
    addToRollTable(Technology.MILITARY_ACADEMY, 4);
    addToRollTable(Technology.BOARDING, 4);
  }

  @override
  List<int> get shipSizeRollTable => SHIP_SIZE_ROLL_TABLE;

  @override
  void buyOptionalTechs(Fleet fleet,
      [List<FleetBuildOption> options = const []]) {
    AlienPlayer ap = fleet.ap;
    buyPointDefenseIfNeeded(ap);
    buyMineSweepIfNeeded(ap);
    buySecurityIfNeeded(ap);
    buyGroundCombatIfNeeded(ap,
        combatIsAbovePlanet:
            options.contains(FleetBuildOption.COMBAT_IS_ABOVE_PLANET));
    buyMilitaryAcademyIfNeeded(ap);
    buyScannerIfNeeded(ap);
    buyBoardingIfNeeded(ap);
    buyShipSizeIfRolled(ap);
    buyFightersIfNeeded(ap);
    buyCloakingIfNeeded(fleet);
  }
}

class Scenario4TechnologyPrices extends TechnologyPrices {
  Scenario4TechnologyPrices() {
    init(Technology.MOVE, const [1, 0, 20, 25, 25, 25, 20, 20]);
    init(Technology.SHIP_SIZE, const [1, 0, 10, 15, 20, 20, 20, 30]);
    //init(MINES,0, 20);

    init(Technology.ATTACK, const [0, 20, 30, 25]);
    init(Technology.DEFENSE, const [0, 20, 30, 25]);
    init(Technology.TACTICS, const [0, 15, 15, 15]);
    init(Technology.CLOAKING, const [0, 30, 30]);
    init(Technology.SCANNER, const [0, 20, 20]);
    init(Technology.FIGHTERS, const [0, 25, 25, 25]);
    init(Technology.POINT_DEFENSE, const [0, 20, 20, 20]);
    init(Technology.MINE_SWEEPER, const [0, 10, 15, 20]);

    init(Technology.SECURITY_FORCES, const [0, 15, 15]);
    init(Technology.MILITARY_ACADEMY, const [0, 10, 20]);
    init(Technology.BOARDING, const [0, 20, 25]);
    init(Technology.GROUND_COMBAT, const [1, 0, 10, 15]);
  }
}

class Scenario4DefenseBuilder extends DefenseBuilder {
  Scenario4DefenseBuilder(Game game) : super(game);

  @override
  void buyHomeDefenseUnits(Fleet fleet) {
    if (fleet.remainingCP > 25) {
      buyGravArmor(fleet);
      buyHeavyInfantry(fleet);
    }
    super.buyHomeDefenseUnits(fleet);
  }

  void buyGravArmor(Fleet fleet) {
    if (fleet.ap.getLevel(Technology.GROUND_COMBAT) == 3) {
      buildGroup(fleet, ShipType.GRAV_ARMOR, 2);
    }
  }

  void buyHeavyInfantry(Fleet fleet) {
    if (fleet.ap.getLevel(Technology.GROUND_COMBAT) >= 2) {
      int howManyHI = game.roller.roll();
      buildGroup(fleet, ShipType.HEAVY_INFANTRY, howManyHI);
    }
  }

  Fleet buildColonyDefense(AlienPlayer ap) {
    int defCP = getDefCp(ap);
    if (defCP >= ShipType.INFANTRY.cost) {
      int maxCP = game.roller.roll() + game.roller.roll();
      maxCP = maxCP < defCP ? maxCP : defCP;
      Fleet fleet = Fleet(ap, FleetType.DEFENSE_FLEET, maxCP);
      addBasesOrMines(fleet);
      addGroundTroops(ap, fleet);
      return fleet;
    } else
      return null;
  }

  void addGroundTroops(AlienPlayer ap, Fleet fleet) {
    if (ap.getLevel(Technology.GROUND_COMBAT) > 1 &&
        fleet.remainingCP >= ShipType.HEAVY_INFANTRY.cost) {
      buildGroup(fleet, ShipType.HEAVY_INFANTRY);
    } else {
      buildGroup(fleet, ShipType.INFANTRY);
    }
  }

  void addBasesOrMines(Fleet fleet) {
    if (game.roller.roll() < 6 && fleet.remainingCP >= ShipType.BASE.cost)
      buildGroup(fleet, ShipType.BASE, 1);
    else
      buildGroup(fleet, ShipType.MINE, 2);
  }
}

class Scenario4FleetBuilder extends FleetBuilder {
  Scenario4FleetBuilder(Game game) : super(game);

  void buildFleet(Fleet fleet, [List<FleetBuildOption> options]) {
    if (fleet.fleetType == FleetType.RAIDER_FLEET ||
        shouldBuildRaiderFleet(fleet, options)) {
      buildRaiderFleet(fleet);
    } else {
      buildOneFullyLoadedTransport(fleet, options);
      buyBoardingShips(fleet);
      buyScoutsIfSeenMines(fleet);
      buyFullCarriers(fleet, options);
      buildFlagship(fleet);
      buildPossibleDD(fleet);
      buildRemainderFleet(fleet);
    }
  }

  void buyBoardingShips(Fleet fleet) {
    if (fleet.ap.getLevel(Technology.BOARDING) != 0) {
      buildGroup(fleet, ShipType.BOARDING_SHIP, 2);
    }
  }

  void buyScoutsIfSeenMines(Fleet fleet) {
    if (game.isSeenThing(Seeable.MINES)) {
      buildGroup(fleet, ShipType.SCOUT, 2);
    }
  }

  void buildOneFullyLoadedTransport(Fleet fleet,
      [List<FleetBuildOption> options]) {
    fleet.addFreeGroup(Group(ShipType.TRANSPORT, 1));
    buildGroundUnits(fleet).forEach((group) => fleet.addFreeGroup(group));
  }

  List<Group> buildGroundUnits(Fleet fleet) {
    List<Group> groups = [];
    switch (fleet.ap.getLevel(Technology.GROUND_COMBAT)) {
      case 1:
        groups.add(Group(ShipType.INFANTRY, 6));
        break;
      case 2:
        groups.add(Group(ShipType.MARINE, 5));
        groups.add(Group(ShipType.HEAVY_INFANTRY, 1));
        break;
      case 3:
        groups.add(Group(ShipType.MARINE, 4));
        groups.add(Group(ShipType.HEAVY_INFANTRY, 1));
        groups.add(Group(ShipType.GRAV_ARMOR, 1));
        break;
    }
    return groups;
  }
}
