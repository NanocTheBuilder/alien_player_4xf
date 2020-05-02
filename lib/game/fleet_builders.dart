import 'dart:math';

import 'package:alienplayer4xf/game/alien_player.dart';

import 'enums.dart';
import 'fleet.dart';
import 'game.dart';

class FleetBuildResult {
  List<Fleet> newFleets = [];
  Map<Technology, int> newTechs = {};
  AlienPlayer alienPlayer;

  FleetBuildResult(this.alienPlayer);

  void addNewFleet(Fleet fleet) {
    newFleets.add(fleet);
  }

  void addNewTech(Technology technology, int level) {
    newTechs[technology] = level;
  }
}

class GroupBuilder {
  Game game;

  GroupBuilder(this.game);

  void buildGroup(Fleet fleet, ShipType shipType, [int maxToBuy = 999]) {
    int shipToBuy = (fleet.remainingCP / shipType.cost) as int;
    shipToBuy = shipToBuy > maxToBuy ? maxToBuy : shipToBuy;
    fleet.addGroup(Group(shipType, shipToBuy));
  }
}

class FleetBuilder extends GroupBuilder {
  static int FULL_CV_COST = ShipType.CARRIER.cost + ShipType.FIGHTER.cost * 3;

  FleetBuilder(Game game) : super(game);

  void buildFleet(Fleet fleet, List<FleetBuildOption> options) {
    if (fleet.fleetType == FleetType.RAIDER_FLEET) {
      buildRaiderFleet(fleet);
    } else {
      buyFullCarriers(fleet, options);
      if (shouldBuildRaiderFleet(fleet, options)) {
        buildRaiderFleet(fleet);
      } else {
        buildFlagship(fleet);
        buildPossibleDD(fleet);
        buildRemainderFleet(fleet);
      }
    }
  }

  void buildRemainderFleet(Fleet fleet) {
    if (fleet.canBuyMoreShips) {
      int fleetCompositionRoll = game.roller.roll();
      bool canUsePD = fleet.ap.getLevel(Technology.POINT_DEFENSE) > 0 &&
          game.isSeenThing(Seeable.FIGHTERS);
      if (canUsePD) {
        fleetCompositionRoll -= 2;
        if (fleet.findGroup(ShipType.CARRIER) == null) {
          buildGroup(fleet, ShipType.SCOUT, 2);
        }
      }

      if (fleetCompositionRoll <= 3) {
        buildBallanced(fleet, 1);
      } else if (fleetCompositionRoll <= 6) {
        if (fleet.canBuyMoreShips)
          buildBallanced(
              fleet,
              max(fleet.ap.getLevel(Technology.ATTACK),
                  fleet.ap.getLevel(Technology.DEFENSE)));
      } else {
        while (fleet.canBuyMoreShips) {
          buildGroup(
              fleet,
              ShipType.findBiggest(
                  fleet.remainingCP, fleet.ap.getLevel(Technology.SHIP_SIZE)));
        }
      }
    }
  }

  void buyFullCarriers(Fleet fleet, List<FleetBuildOption> options) {
    if (shouldBuildCarrierFleet(fleet, options)) {
      buildCarrierFleet(fleet);
    }
  }

  void buildCarrierFleet(Fleet fleet) {
    int shipsToBuild = (fleet.fleetCP / FULL_CV_COST) as int;
    fleet.addGroup(Group(ShipType.CARRIER, shipsToBuild));
    fleet.addGroup(Group(ShipType.FIGHTER, shipsToBuild * 3));
  }

  //TODO: FIND A READABLE ALGORITHM?
  void buildBallanced(Fleet fleet, int minHullSize) {
    int apShipSize = fleet.ap.getLevel(Technology.SHIP_SIZE);
    for (int i = minHullSize; i >= 0; i--) {
      ShipType cheapestType = ShipType.findCheapest(i);
      if (apShipSize >= cheapestType.requiredShipSize) {
        for (ShipType biggerType
            in ShipType.getBiggerTypesInReverse(cheapestType)) {
          if (apShipSize >= biggerType.requiredShipSize &&
              fleet.remainingCP >= biggerType.cost) {
            int remainder = fleet.remainingCP % cheapestType.cost;
            int difference = biggerType.cost - cheapestType.cost;
            int shipType2ToBuy = (remainder / difference) as int;
            buildGroup(fleet, biggerType, shipType2ToBuy);
          }
        }
        buildGroup(fleet, cheapestType);
      }
    }
  }

  void buildPossibleDD(Fleet fleet) {
    if (fleet.remainingCP >= ShipType.RAIDER.cost) {
      if (ShipType.DESTROYER.canBeBuilt(
              fleet.remainingCP, fleet.ap.getLevel(Technology.SHIP_SIZE)) &&
          game.getSeenLevel(Technology.CLOAKING) <=
              fleet.ap.getLevel(Technology.SCANNER) &&
          fleet.findGroup(ShipType.DESTROYER) == null)
        fleet.addGroup(Group(ShipType.DESTROYER, 1));
    }
  }

  void buildRaiderFleet(Fleet fleet) {
    fleet.fleetType = FleetType.RAIDER_FLEET;
    buildGroup(fleet, ShipType.RAIDER);
  }

  void buildFlagship(Fleet fleet) {
    if (fleet.canBuyMoreShips) {
      ShipType shipType = ShipType.findBiggest(
          fleet.remainingCP, fleet.ap.getLevel(Technology.SHIP_SIZE));
      fleet.addGroup(Group(shipType, 1));
    }
  }

  bool shouldBuildCarrierFleet(Fleet fleet, [List<FleetBuildOption> options = const []]) {
    if (fleet.fleetCP < FULL_CV_COST ||
        fleet.ap.getLevel(Technology.FIGHTERS) == 0 ||
        options.contains(FleetBuildOption.COMBAT_WITH_NPAS)) return false;
    return game.getSeenLevel(Technology.POINT_DEFENSE) == 0 &&
            !game.isSeenThing(Seeable.MINES) ||
        game.roller.roll() < 5;
  }

  bool shouldBuildRaiderFleet(Fleet fleet, [List<FleetBuildOption> options = const []]) {
    // TODO more test for this. Especially the resetting of
    // isPurchasedThisTurn
    if (options.contains(FleetBuildOption.HOME_DEFENSE)) return false;
    return fleet.groups.isEmpty &&
        fleet.fleetCP >= ShipType.RAIDER.cost &&
        fleet.ap.purchasedCloakThisTurn &&
        fleet.ap.getLevel(Technology.CLOAKING) >
            game.getSeenLevel(Technology.SCANNER);
  }
}

class DefenseBuilder extends GroupBuilder {
  DefenseBuilder(Game game) : super(game);

  int getDefCp(AlienPlayer ap){
    return ap.economicSheet.defCP;
  }

  Fleet buildHomeDefense(AlienPlayer ap) {
    if (ap.economicSheet.defCP >= ShipType.MINE.cost) {
      Fleet fleet = Fleet(ap, FleetType.DEFENSE_FLEET, ap.economicSheet.defCP);
      buyHomeDefenseUnits(fleet);
      return fleet;
    } else
      return null;
  }

  void buyHomeDefenseUnits(Fleet fleet) {
    int roll = game.roller.roll();
    if (roll < 4) {
      buildGroup(fleet, ShipType.MINE);
    } else if (roll < 8) {
      while (canBuyMine(fleet)) {
        buildGroup(fleet, ShipType.BASE, 1);
        buildGroup(fleet, ShipType.MINE, 1);
      }
    } else {
      buildGroup(fleet, ShipType.BASE);
      buildGroup(fleet, ShipType.MINE);
    }
  }

  bool canBuyMine(Fleet fleet) {
    return fleet.remainingCP >= ShipType.MINE.cost;
  }
}
