import 'dart:collection';
import 'dart:math';

import 'alien_player.dart';
import 'enums.dart';
import 'fleet.dart';
import 'game.dart';

abstract class TechnologyPrices {
  List<Technology> availableTechs = [];
  Map<Technology, List<int>> map = {};

  void init(Technology technology, List<int> ints) {
    map[technology] = ints;
    availableTechs.add(technology);
  }

  int getStartingLevel(Technology technology) {
    return map[technology][0];
  }

  int getCost(Technology technology, int level) {
    return map[technology][level];
  }

  int getMaxLevel(Technology technology) {
    return map[technology].length - 1;
  }
}

abstract class TechnologyBuyer {
  Game game;

  Map<Technology, int> TECHNOLOGY_ROLL_TABLE = SplayTreeMap((tech1, tech2){return tech1.index - tech2.index;});

  List<int> get shipSizeRollTable;

  TechnologyBuyer(this.game) {
    initRollTable();
  }

  void buyTechs(Fleet fleet, [List<FleetBuildOption> options = const []]) {
    buyOptionalTechs(fleet, options);
    spendRemainingTechCP(fleet, options);
  }

  void initRollTable();

  void addToRollTable(Technology technology, int values) {
    TECHNOLOGY_ROLL_TABLE[technology] = values;
  }

  void buyOptionalTechs(Fleet fleet, [List<FleetBuildOption> options]);

  void spendRemainingTechCP(Fleet fleet, [List<FleetBuildOption> options = const []]) {
    while (true) {
      List<Technology> buyable = findBuyableTechs(fleet, options);
      if (buyable.isEmpty) break;
      int roll = game.roller.roll(buyable.length);
      buyRolledTech(fleet.ap, buyable[roll - 1]);
    }
  }

  void buyRolledTech(AlienPlayer ap, Technology technology) {
    switch (technology) {
      case Technology.TACTICS:
        if (ap.getLevel(Technology.ATTACK) < 2 &&
            apCanBuyNextLevel(ap, Technology.ATTACK))
          buyNextLevel(ap, Technology.ATTACK);
        else if (ap.getLevel(Technology.DEFENSE) < 2 &&
            apCanBuyNextLevel(ap, Technology.DEFENSE))
          buyNextLevel(ap, Technology.DEFENSE);
        else
          buyNextLevel(ap, Technology.TACTICS);
        break;
      case Technology.CLOAKING:
        buyNextLevel(ap, Technology.CLOAKING);
        ap.purchasedCloakThisTurn = true;
        break;
      default:
        buyNextLevel(ap, technology);
        break;
    }
  }

  void buyNextLevel(AlienPlayer ap, Technology technology) {
    int currentLevel = ap.getLevel(technology);
    if (apCanBuyNextLevel(ap, technology)) {
      int nextLevel = currentLevel + 1;
      int cost = game.scenario.getCost(technology, nextLevel);
      ap.setLevel(technology, nextLevel);
      ap.economicSheet.spendTechCP(cost);
    }
  }

  bool apCanBuyNextLevel(AlienPlayer ap, Technology technology) {
    int currentLevel = ap.getLevel(technology);
    if (technology == Technology.TACTICS) {
      int lesser =
          min(ap.getLevel(Technology.ATTACK), ap.getLevel(Technology.DEFENSE));
      if (lesser < 2) {
        return apCanBuyNextLevel(ap, Technology.ATTACK) |
            apCanBuyNextLevel(ap, Technology.DEFENSE);
      }
    }
    if (technology == Technology.CLOAKING &&
        game.getSeenLevel(Technology.SCANNER) ==
            game.scenario.getMaxLevel(Technology.SCANNER)) {
      return false;
    }

    return currentLevel < game.scenario.getMaxLevel(technology) &&
        ap.economicSheet.techCP >=
            game.scenario.getCost(technology, currentLevel + 1);
  }

  bool fleetCanBuyNextLevel(
      Fleet fleet, Technology technology, [List<FleetBuildOption> options = const []]) {
    if (technology == Technology.MINE_SWEEPER &&
        options.contains(FleetBuildOption.HOME_DEFENSE))
      return false;
    else
      return apCanBuyNextLevel(fleet.ap, technology);
  }

  List<Technology> findBuyableTechs(
      Fleet fleet, [List<FleetBuildOption> options = const []]) {
    List<Technology> buyable = [];
    for (Technology technology in TECHNOLOGY_ROLL_TABLE.keys) {
      if (fleetCanBuyNextLevel(fleet, technology, options)) {
        for (int i = 0; i < TECHNOLOGY_ROLL_TABLE[technology]; i++)
          buyable.add(technology);
      }
    }
    return buyable;
  }

  void buyCloakingIfNeeded(Fleet fleet) {
    if (fleet.fleetType == FleetType.RAIDER_FLEET &&
        fleet.ap.getLevel(Technology.CLOAKING) == 1) {
      if (game.roller.roll() <= 6) buyNextLevel(fleet.ap, Technology.CLOAKING);
    }
  }

  void buyFightersIfNeeded(AlienPlayer ap) {
    if (game.getSeenLevel(Technology.POINT_DEFENSE) == 0 &&
        ap.getLevel(Technology.FIGHTERS) != 0) if (game.roller.roll() <= 6)
      buyNextLevel(ap, Technology.FIGHTERS);
  }

  void buyShipSizeIfRolled(AlienPlayer ap) {
    if (ap.getLevel(Technology.SHIP_SIZE) <
        game.scenario.getMaxLevel(Technology.SHIP_SIZE)) if (game.roller
            .roll() <=
        shipSizeRollTable[ap.getLevel(Technology.SHIP_SIZE)])
      buyNextLevel(ap, Technology.SHIP_SIZE);
  }

  void buyScannerIfNeeded(AlienPlayer ap) {
    if (game.getSeenLevel(Technology.CLOAKING) >
        ap.getLevel(Technology.SCANNER)) {
      if (game.roller.roll() <= 4) {
        int levelsNeeded = game.getSeenLevel(Technology.CLOAKING) -
            ap.getLevel(Technology.SCANNER);
        for (int i = 0; i < levelsNeeded; i++)
          buyNextLevel(ap, Technology.SCANNER);
      }
    }
  }

  void buyMineSweepIfNeeded(AlienPlayer ap) {
    if (game.isSeenThing(Seeable.MINES) &&
        ap.getLevel(Technology.MINE_SWEEPER) == 0) {
      buyNextLevel(ap, Technology.MINE_SWEEPER);
    }
  }

  void buyPointDefenseIfNeeded(AlienPlayer ap) {
    if (game.isSeenThing(Seeable.FIGHTERS) &&
        ap.getLevel(Technology.POINT_DEFENSE) == 0) {
      buyNextLevel(ap, Technology.POINT_DEFENSE);
    }
  }

  void buySecurityIfNeeded(AlienPlayer ap) {
    if (game.isSeenThing(Seeable.BOARDING_SHIPS) &&
        ap.getLevel(Technology.SECURITY_FORCES) == 0)
      buyNextLevel(ap, Technology.SECURITY_FORCES);
  }

  void buyGroundCombatIfNeeded(AlienPlayer ap, {bool combatIsAbovePlanet}) {
    if (combatIsAbovePlanet) buyNextLevel(ap, Technology.GROUND_COMBAT);
  }

  void buyMilitaryAcademyIfNeeded(AlienPlayer ap) {
    if (game.isSeenThing(Seeable.VETERANS)) if (game.roller.roll() <= 6)
      buyNextLevel(ap, Technology.MILITARY_ACADEMY);
  }

  void buyBoardingIfNeeded(AlienPlayer ap) {
    if (game.isSeenThing(Seeable.SIZE_3_SHIPS) &&
        ap.getLevel(Technology.BOARDING) == 0) if (game.roller.roll() <= 4)
      buyNextLevel(ap, Technology.BOARDING);
  }
}
