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

import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {
  late AlienPlayer ap;
  late AlienEconomicSheet sheet;
  late MockRoller roller;
  late FleetBuilder fleetBuilder;

  //utils come first
  void assertBuiltGroups(AlienPlayer ap, Fleet fleet, List<FleetBuildOption> options, List<Group> expectedGroups) {
    fleetBuilder.buildFleet(ap, fleet, options);
    var expectedCost = 0;
    for (Group g in expectedGroups) {
      expectedCost += g.shipType.cost * g.size;
    }
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  void assertBuiltFlagship(int shipSize, int fleetCP, ShipType shipType) {
    ap.setLevel(Technology.SHIP_SIZE, shipSize);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, fleetCP);
    assertBuiltGroups(ap, fleet, [], [Group(shipType, 1)]);
  }

  void assertBuiltFleet(int fleetTypeRoll, int fleetCP, List<FleetBuildOption> options, List<Group> expectedGroups) {
    roller.mockRoll("Fleet composition", fleetTypeRoll);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, fleetCP);
    assertBuiltGroups(ap, fleet, options, expectedGroups);
  }

  setUp(() {
    var game = Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    ap = game.aliens[0];
    sheet = ap.economicSheet;
    roller = MockRoller();
    game.roller = roller;
    fleetBuilder = game.scenario.fleetBuilder;
  });

  test('basegame/fleet_build_test.buildRaiderFleet', (){
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.RAIDER_FLEET, 24);
    assertBuiltGroups(ap, fleet, [], [Group(ShipType.RAIDER, 2)]);
  });

  test('basegame/fleet_build_test.buildScoutFleet',() {
  assertBuiltFleet(1, 12, [], [Group(ShipType.SCOUT, 2)]);
  assertBuiltFleet(4, 12, [], [Group(ShipType.SCOUT, 2)]);
  assertBuiltFleet(7, 12, [], [Group(ShipType.SCOUT, 2)]);
  });

  test('basegame/fleet_build_test.buildCarrierFleet', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 27);
  assertBuiltGroups(ap, fleet, [], [Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3)]);

  fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 54);
  assertBuiltGroups(ap, fleet, [], [Group(ShipType.CARRIER, 2), Group(ShipType.FIGHTER, 6)]);

  });

  test('basegame/fleet_build_test.dontBuildCarrierFleetUnder27', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  assertBuiltFleet(1, 26, [], [Group(ShipType.SCOUT, 4)]);
  });

  test('basegame/fleet_build_test.dontBuildCarrierFleetIfSeenPDAndFailedRoll', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
  roller.mockRoll("Carrier fleet", 5);
  assertBuiltFleet(1, 27, [], [Group(ShipType.SCOUT, 4)]);
  });

  test('basegame/fleet_build_test.dontBuildCarrierFleetIfSeenMinesAndFailedRoll', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.game!.addSeenThing(Seeable.MINES);
  roller.mockRoll("Carrier fleet", 5);
  assertBuiltFleet(1, 27, [], [Group(ShipType.SCOUT, 4)]);
  });

  test('basegame/fleet_build_test.dontBuildCarrierFleetIfNotSeenPDAndEnemyIsNPA', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  assertBuiltFleet(1, 27, [FleetBuildOption.COMBAT_WITH_NPAS], [Group(ShipType.SCOUT, 4)]);
  });

  test('basegame/fleet_build_test.dontBuildCarrierFleetIfSeenPDAndEnemyIsNPA', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
  assertBuiltFleet(1, 27, [FleetBuildOption.COMBAT_WITH_NPAS], [Group(ShipType.SCOUT, 4)]);
  });

  test('basegame/fleet_build_test.buildCarrierFleetIfSeenPDAndPassedRoll', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
  roller.mockRoll("Carrier fleet", 4);
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 27);
  assertBuiltGroups(ap, fleet, [], [Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3)]);
  });

  test('basegame/fleet_build_test.buildRaiderFleetIfJustPurchasedCloak', () {
  ap.setLevel(Technology.CLOAKING, 1);
  ap.purchasedCloakThisTurn = true;
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 12);
  assertBuiltGroups(ap, fleet, [], [Group(ShipType.RAIDER, 1)]);
  expect(fleet.fleetType, FleetType.RAIDER_FLEET);

  ap.game!.setSeenLevel(Technology.SCANNER, 1);
  assertBuiltFleet(1, 12, [], [Group(ShipType.SCOUT, 2)]);
  });

  test('basegame/fleet_build_test.dontBuildRaiderFleetUnder12', () {
  ap.setLevel(Technology.CLOAKING, 1);
  ap.purchasedCloakThisTurn = true;
  ap.setLevel(Technology.SHIP_SIZE, 2);
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 11);
  assertBuiltGroups(ap, fleet,[], [Group(ShipType.DESTROYER, 1)]);
  });


  test('basegame/fleet_build_test.dontBuildRaiderFleetForHomeDefense', () {
  ap.setLevel(Technology.CLOAKING, 1);
  ap.purchasedCloakThisTurn = true;
  ap.setLevel(Technology.SHIP_SIZE, 2);
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 12);
  assertBuiltGroups(ap, fleet,[FleetBuildOption.HOME_DEFENSE], [Group(ShipType.DESTROYER, 1)]);

  });

  test('basegame/fleet_build_test.checkFighterFleetBeforeRaiderFleet', () {
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.setLevel(Technology.CLOAKING, 1);
  ap.purchasedCloakThisTurn = true;
  ap.setLevel(Technology.SHIP_SIZE, 2);
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 39);
  assertBuiltGroups(ap, fleet, [], [Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3), Group(ShipType.DESTROYER, 1)]);
  });

  test('basegame/fleet_build_test.buyFlagshipFirst', () {
  assertBuiltFlagship(1, 6, ShipType.SCOUT);
  assertBuiltFlagship(2, 9, ShipType.DESTROYER);
  assertBuiltFlagship(3, 12, ShipType.CRUISER);
  assertBuiltFlagship(4, 15, ShipType.BATTLECRUISER);
  assertBuiltFlagship(5, 20, ShipType.BATTLESHIP);
  assertBuiltFlagship(6, 24, ShipType.DREADNAUGHT);
  });

  test('basegame/fleet_build_test.buyOneDD', () {
  ap.setLevel(Technology.SHIP_SIZE, 2);
  assertBuiltFleet(1, 27, [], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 3)]);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(1, 30, [], [Group(ShipType.CRUISER, 1), Group(ShipType.DESTROYER, 2)]);

  ap.game!.setSeenLevel(Technology.CLOAKING, 1);
  assertBuiltFleet(1, 30, [], [Group(ShipType.CRUISER, 1), Group(ShipType.SCOUT, 3)]);

  ap.setLevel(Technology.SCANNER, 1);
  assertBuiltFleet(1, 30, [], [Group(ShipType.CRUISER, 1), Group(ShipType.DESTROYER, 2)]);
  });

  test('basegame/fleet_build_test.buildLargestFleet', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

  ap.setLevel(Technology.SHIP_SIZE, 2);
  assertBuiltFleet(1, 18, [], [Group(ShipType.DESTROYER, 2)]);

  assertBuiltFleet(1, 27, [], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 3)]);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(1, 30, [], [Group(ShipType.CRUISER, 1), Group(ShipType.SCOUT, 3)]);
  assertBuiltFleet(1, 33, [], [Group(ShipType.CRUISER, 1), Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 2)]);
  assertBuiltFleet(1, 87, [], [Group(ShipType.CRUISER, 1), Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 11)]);
  });

  test('basegame/fleet_build_test.buildLargestShips', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

  ap.setLevel(Technology.SHIP_SIZE, 2);
  assertBuiltFleet(7, 21, [], [Group(ShipType.DESTROYER, 2)]);
  assertBuiltFleet(7, 27, [], [Group(ShipType.DESTROYER, 3)]);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(7, 30, [], [Group(ShipType.CRUISER, 2), Group(ShipType.SCOUT, 1)]);

  ap.setLevel(Technology.SHIP_SIZE, 6);
  assertBuiltFleet(7, 30, [], [Group(ShipType.DREADNAUGHT, 1), Group(ShipType.SCOUT, 1)]);
  });

  test('basegame/fleet_build_test.buildBalancedFleet', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

  ap.setLevel(Technology.SHIP_SIZE, 5);
  assertBuiltFleet(4, 44, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.SCOUT, 4)]);

  ap.setLevel(Technology.ATTACK, 2);
  assertBuiltFleet(4, 44, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.CRUISER, 2)]);

  ap.setLevel(Technology.ATTACK, 0);
  ap.setLevel(Technology.DEFENSE, 2);
  assertBuiltFleet(4, 44, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.CRUISER, 2)]);
  assertBuiltFleet(4, 47, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.BATTLECRUISER, 1), Group(ShipType.CRUISER, 1)]);
  assertBuiltFleet(4, 50, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.BATTLECRUISER, 2)]);
  assertBuiltFleet(4, 52, [], [Group(ShipType.BATTLESHIP, 2), Group(ShipType.CRUISER, 1)]);
  assertBuiltFleet(4, 56, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.CRUISER, 3)]);
  //+20 for BATTLESHIP
  assertBuiltFleet(4, 26, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.SCOUT, 1)]);
  assertBuiltFleet(4, 29, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.DESTROYER, 1)]);
  assertBuiltFleet(4, 32, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.CRUISER, 1)]);
  assertBuiltFleet(4, 35, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.BATTLECRUISER, 1)]);
  assertBuiltFleet(4, 41, [], [Group(ShipType.BATTLESHIP, 2)]);

  ap.setLevel(Technology.SHIP_SIZE, 2); //+9 for DD
  assertBuiltFleet(4, 15, [], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 1)]);
  assertBuiltFleet(4, 18, [], [Group(ShipType.DESTROYER, 2)]);
  assertBuiltFleet(4, 21, [], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 2)]);
  assertBuiltFleet(4, 24, [], [Group(ShipType.DESTROYER, 2), Group(ShipType.SCOUT, 1)]);
  assertBuiltFleet(4, 44, [], [Group(ShipType.DESTROYER, 2), Group(ShipType.SCOUT, 4)]);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(4, 26, [], [Group(ShipType.CRUISER, 2)]);
  });

  test('basegame/fleet_build_test.subtractTwoIfHasPDAndSeenFighters', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
  ap.setLevel(Technology.POINT_DEFENSE, 1);
  ap.game!.addSeenThing(Seeable.FIGHTERS);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(5, 27, [], [Group(ShipType.CRUISER, 1), Group(ShipType.SCOUT, 2)]);
  });

  test('basegame/fleet_build_test.subtractTwoIfHasPDAndSeenFightersAndBuy2SC', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
  ap.setLevel(Technology.POINT_DEFENSE, 1);
  ap.game!.addSeenThing(Seeable.FIGHTERS);

  ap.setLevel(Technology.SHIP_SIZE, 5);
  ap.setLevel(Technology.ATTACK, 2);
  assertBuiltFleet(6, 44, [], [Group(ShipType.BATTLESHIP, 1), Group(ShipType.SCOUT, 2), Group(ShipType.CRUISER, 1)]);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  assertBuiltFleet(6, 26, [], [Group(ShipType.CRUISER, 1), Group(ShipType.SCOUT, 2)]);

  ap.setLevel(Technology.SHIP_SIZE, 2);
  assertBuiltFleet(9, 21, [], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 2)]);
  });

  test('basegame/fleet_build_test.subtractTwoIfHasPDAndSeenFightersAndDontBuy2SCIfHasFullCarrier', () {
  ap.game!.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
  ap.setLevel(Technology.FIGHTERS, 1);
  ap.setLevel(Technology.POINT_DEFENSE, 1);
  ap.game!.addSeenThing(Seeable.FIGHTERS);

  ap.setLevel(Technology.SHIP_SIZE, 3);
  ap.setLevel(Technology.ATTACK, 2);
  assertBuiltFleet(6, 27 + 26, [],[ Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3), Group(ShipType.CRUISER, 2)]);

  ap.setLevel(Technology.SHIP_SIZE, 2);
  assertBuiltFleet(9, 27 + 21, [], [Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3), Group(ShipType.DESTROYER, 2)]);
  });

  test('basegame/fleet_build_test.noCPnoFleet', () {
  Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 5);
  assertBuiltGroups(ap, fleet, [], []);
  expect(fleet.buildCost, 0);
  });
  
}