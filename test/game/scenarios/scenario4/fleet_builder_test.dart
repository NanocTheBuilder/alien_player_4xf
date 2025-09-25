/*
 *  Copyright (C) 2025 Balázs Péter
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

import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:test/test.dart';

import '../../fixture.dart';
import 'scenario4_test_base.dart';

void main() {
  setUp(() {
    //Fixture
    setupFixture(newGame());
  });

  tearDown(assertAllRollsUsed);

  void assertBuiltGroups(Fleet fleet, List<Group> expectedGroups, [List<FleetBuildOption> options = const []]) {
    List<Group> fleetGroups = [];
    fleetGroups.add(new Group(ShipType.TRANSPORT, 1));
    fleetGroups.add(new Group(ShipType.INFANTRY, 6));

    fleetBuilder.buildFleet(ap, fleet, options);
    int expectedCost = expectedGroups.fold(0, (value, group) => value + group.cost); //Sum of costs
    fleetGroups.addAll(expectedGroups);
    expect(fleet.groups, fleetGroups);
    expect(fleet.buildCost, expectedCost);
    expect(fleet.fleetType, FleetType.REGULAR_FLEET);
  }

  //void assertBuiltFleet(int fleetCP, List<Group> expectedGroups, {int fleetTypeRoll = -1}) {
  void assertBuiltFleet(
    int fleetCP,
    List<Group> expectedGroups, {
    int fleetCompositionRoll = -1,
    List<FleetBuildOption> options = const [],
  }) {
    if (fleetCompositionRoll != -1) {
      roller.mockRoll("Fleet composition", fleetCompositionRoll);
    }
    Fleet fleet = new Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, fleetCP);
    assertBuiltGroups(fleet, expectedGroups, options);
  }

  void assertBuiltFlagship(int shipSize, int fleetCP, ShipType shipType) {
    ap.setLevel(Technology.SHIP_SIZE, shipSize);
    assertBuiltFleet(fleetCP, [new Group(shipType, 1)]);
  }

  void assertBuiltRaiderGroups(Fleet fleet, List<Group> expectedGroups) {
    fleetBuilder.buildFleet(ap, fleet, []);
    int expectedCost = expectedGroups.fold(0, (value, group) => value + group.cost); //Sum of costs
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
    expect(fleet.fleetType, FleetType.RAIDER_FLEET);
  }

  void assertBuiltFreeGroups(Fleet fleet, List<Group> expectedGroups) {
    fleetBuilder.buildFleet(ap, fleet, []);
    int expectedCost = 0;
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
    expect(fleet.fleetType, FleetType.REGULAR_FLEET);
  }

  // Close_Encounters_Scenarios_2018.pdf page 8: During ship purchasing, follow the branch for Expansion fleets
  //  and Ground Combat unit buying and ignore the branch for Extermination fleets.
  //  This means all Regular AP fleets get a fully loaded Transport for free.

  //Raider fleet buys only Raiders
  test("scenario4/fleet_builder_test.raiderFleetBuysOnlyRaiders", () {
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.RAIDER_FLEET, 36);
    assertBuiltRaiderGroups(fleet, [new Group(ShipType.RAIDER, 3)]);
  });

  //AP just purchased a Cloak level
  //Has not seen enemy with equal Scanner level
  // -> This fleet is now a Raider Fleet and follows those rules
  test("scenario4/fleet_builder_test.buildRaiderFleet", () {
    ap.setLevel(Technology.CLOAKING, 2);
    ap.purchasedCloakThisTurn = true;
    game.setSeenLevel(Technology.SCANNER, 1);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 36);
    assertBuiltRaiderGroups(fleet, [new Group(ShipType.RAIDER, 3)]);
  });

  test("scenario4/fleet_builder_test.dontBuildRaiderFleetUnder12", () {
    ap.setLevel(Technology.CLOAKING, 1);
    ap.purchasedCloakThisTurn = true;
    ap.setLevel(Technology.SHIP_SIZE, 2);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 11);
    assertBuiltGroups(fleet, [new Group(ShipType.DESTROYER, 1)]);
  });

  test("scenario4/fleet_builder_test.dontBuildRaiderFleetForHomeDefense", () {
    ap.setLevel(Technology.CLOAKING, 1);
    ap.purchasedCloakThisTurn = true;
    ap.setLevel(Technology.SHIP_SIZE, 2);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 12);
    assertBuiltGroups(fleet, [new Group(ShipType.DESTROYER, 1)], [FleetBuildOption.HOME_DEFENSE]);
  });

  //Follow expansion fleet branch -> fully loaded transport for free
  test('scenario4/fleet_builder_test.buildFullyLoadedTransport', () {
    ap.setLevel(Technology.GROUND_COMBAT, 1);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 0);
    assertBuiltFreeGroups(fleet, [new Group(ShipType.TRANSPORT, 1), new Group(ShipType.INFANTRY, 6)]);
  });

  test('scenario4/fleet_builder_test.buildGC2FullyLoadedTransport', () {
    ap.setLevel(Technology.GROUND_COMBAT, 2);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 0);
    assertBuiltFreeGroups(fleet, [
      new Group(ShipType.TRANSPORT, 1),
      new Group(ShipType.MARINE, 5),
      new Group(ShipType.HEAVY_INFANTRY, 1),
    ]);
  });

  test('scenario4/fleet_builder_test.buildGC3FullyLoadedTransport', () {
    ap.setLevel(Technology.GROUND_COMBAT, 3);
    Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, 0);
    assertBuiltFreeGroups(fleet, [
      new Group(ShipType.TRANSPORT, 1),
      new Group(ShipType.MARINE, 4),
      new Group(ShipType.HEAVY_INFANTRY, 1),
      new Group(ShipType.GRAV_ARMOR, 1),
    ]);
  });

  //AP has Boarding tech 1 or Boarding tech 2 ->buy 2 BDs
  test('scenario4/fleet_builder_test.boarding1Builds1BDs()', () {
    ap.setLevel(Technology.BOARDING, 1);
    assertBuiltFleet(12, [new Group(ShipType.BOARDING_SHIP, 1)]);
  });

  test('scenario4/fleet_builder_test.boarding1Builds2BDs()', () {
    ap.setLevel(Technology.BOARDING, 1);
    assertBuiltFleet(24, [new Group(ShipType.BOARDING_SHIP, 2)]);
  });

  test('scenario4/fleet_builder_test.boarding1BuildsOnly2BDs()', () {
    ap.setLevel(Technology.BOARDING, 1);
    ap.setLevel(Technology.SHIP_SIZE, 2); // spend 9 CP on optional DD
    assertBuiltFleet(36, [new Group(ShipType.BOARDING_SHIP, 2), new Group(ShipType.DESTROYER, 1)]);
  });

  test('scenario4/fleet_builder_test.boarding2BuildsOnly2BDs()', () {
    ap.setLevel(Technology.BOARDING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3); // spend 12 CP on optional CRUISER
    assertBuiltFleet(36, [new Group(ShipType.BOARDING_SHIP, 2), new Group(ShipType.CRUISER, 1)]);
  });

  test('scenario4/fleet_builder_test.dontBuildsBDsIfNotEnoughCP()', () {
    ap.setLevel(Technology.BOARDING, 1);
    assertBuiltFleet(5, []);
  });

  //Has seen enemy Mines -> Buy 2 SC
  test('scenario4/fleet_builder_test.buy1SCIfSeenMines()', () {
    game.addSeenThing(Seeable.MINES);
    assertBuiltFleet(6, [new Group(ShipType.SCOUT, 1)]);
  });

  test('scenario4/fleet_builder_test.buy2SCIfSeenMines()', () {
    game.addSeenThing(Seeable.MINES);
    assertBuiltFleet(12, [new Group(ShipType.SCOUT, 2)]);
  });

  //AP has Fighter tech -> Has not seen enemy Point Def -> Enemy is not NPAs -> Buy only fully loaded Carriers
  //AP has Fighter tech -> Has seen enemy Point Def or Mines -> Roll die Result 1-4 -> Buy only fully loaded Carriers
  test('scenario4/fleet_builder_test.buildCarrierFleet()', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    assertBuiltFleet(27, [new Group(ShipType.CARRIER, 1), new Group(ShipType.FIGHTER, 3)]);
    assertBuiltFleet(54, [new Group(ShipType.CARRIER, 2), new Group(ShipType.FIGHTER, 6)]);
  });

  test('scenario4/fleet_builder_test.dontBuildCarrierFleetUnder27', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    assertBuiltFleet(26, [Group(ShipType.SCOUT, 4)], fleetCompositionRoll: 1);
  });

  test('scenario4/fleet_builder_test.dontBuildCarrierFleetIfSeenPDAndFailedRoll', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
    roller.mockRoll("Carrier fleet", 5);
    assertBuiltFleet(27, [Group(ShipType.SCOUT, 4)], fleetCompositionRoll: 1);
  });

  test('scenario4/fleet_builder_test.dontBuildCarrierFleetIfSeenMinesAndFailedRoll', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.game!.addSeenThing(Seeable.MINES);
    roller.mockRoll("Carrier fleet", 5);
    assertBuiltFleet(27, [Group(ShipType.SCOUT, 4)], fleetCompositionRoll: 1);
  });

  test('scenario4/fleet_builder_test.dontBuildCarrierFleetIfNotSeenPDAndEnemyIsNPA', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    assertBuiltFleet(
      27,
      [Group(ShipType.SCOUT, 4)],
      options: [FleetBuildOption.COMBAT_WITH_NPAS],
      fleetCompositionRoll: 1,
    );
  });

  test('scenario4/fleet_builder_test.dontBuildCarrierFleetIfSeenPDAndEnemyIsNPA', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
    assertBuiltFleet(
      27,
      [Group(ShipType.SCOUT, 4)],
      options: [FleetBuildOption.COMBAT_WITH_NPAS],
      fleetCompositionRoll: 1,
    );
  });

  test('scenario4/fleet_builder_test.buildCarrierFleetIfSeenPDAndPassedRoll', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.game!.setSeenLevel(Technology.POINT_DEFENSE, 1);
    roller.mockRoll("Carrier fleet", 4);
    assertBuiltFleet(27, [Group(ShipType.CARRIER, 1), Group(ShipType.FIGHTER, 3)]);
  });

  // copy from basegame/fleet_build_test.dart end

  //Buy 1 of largest ship size available
  test('scenario4/fleet_builder_test.buyFlagshipFirst()', () {
    assertBuiltFlagship(1, 6, ShipType.SCOUT);
    assertBuiltFlagship(2, 9, ShipType.DESTROYER);
    assertBuiltFlagship(3, 12, ShipType.CRUISER);
    assertBuiltFlagship(4, 15, ShipType.BATTLECRUISER);
    assertBuiltFlagship(5, 20, ShipType.BATTLESHIP);
    assertBuiltFlagship(6, 24, ShipType.DREADNAUGHT);
    assertBuiltFlagship(7, 32, ShipType.TITAN);
  });

  //AP has not seen Cloak greater than the Scanner tech and AP has Scanner tech
  //Largest ship was not a DD -> Buy 1 DD

  test('scenario4/fleet_builder_test.buyOneDD()', () {
    ap.setLevel(Technology.SHIP_SIZE, 2);
    //DD was the largest ship, no more DD
    assertBuiltFleet(27, [new Group(ShipType.DESTROYER, 1), new Group(ShipType.SCOUT, 3)], fleetCompositionRoll: 1);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    //CR was the largest ship, buy 1 DD
    assertBuiltFleet(30, [new Group(ShipType.CRUISER, 1), new Group(ShipType.DESTROYER, 2)], fleetCompositionRoll: 1);

    game.setSeenLevel(Technology.CLOAKING, 1);
    //has seen Cloak > Scanner, no DD
    assertBuiltFleet(30, [new Group(ShipType.CRUISER, 1), new Group(ShipType.SCOUT, 3)], fleetCompositionRoll: 1);

    ap.setLevel(Technology.SCANNER, 1);
    //has Scanner == Cloak, buy 1 DD
    assertBuiltFleet(30, [new Group(ShipType.CRUISER, 1), new Group(ShipType.DESTROYER, 2)], fleetCompositionRoll: 1);
  });

  test('scenario4/fleet_builder_test.buildLargestFleet', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

    ap.setLevel(Technology.SHIP_SIZE, 2);
    assertBuiltFleet(18, [new Group(ShipType.DESTROYER, 2)], fleetCompositionRoll: 1);

    assertBuiltFleet(27, [new Group(ShipType.DESTROYER, 1), new Group(ShipType.SCOUT, 3)], fleetCompositionRoll: 1);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    assertBuiltFleet(30, [new Group(ShipType.CRUISER, 1), new Group(ShipType.SCOUT, 3)], fleetCompositionRoll: 1);
    assertBuiltFleet(33, [
      new Group(ShipType.CRUISER, 1),
      new Group(ShipType.DESTROYER, 1),
      new Group(ShipType.SCOUT, 2),
    ], fleetCompositionRoll: 1);
    assertBuiltFleet(87, [
      new Group(ShipType.CRUISER, 1),
      new Group(ShipType.DESTROYER, 1),
      new Group(ShipType.SCOUT, 11),
    ], fleetCompositionRoll: 1);
  });

  test('scenario4/fleet_builder_test.buildLargestShips', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

    ap.setLevel(Technology.SHIP_SIZE, 2);
    assertBuiltFleet(21, [new Group(ShipType.DESTROYER, 2)], fleetCompositionRoll: 7);
    assertBuiltFleet(27, [new Group(ShipType.DESTROYER, 3)], fleetCompositionRoll: 7);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    assertBuiltFleet(30, [new Group(ShipType.CRUISER, 2), new Group(ShipType.SCOUT, 1)], fleetCompositionRoll: 7);

    ap.setLevel(Technology.SHIP_SIZE, 6);
    assertBuiltFleet(30, [new Group(ShipType.DREADNAUGHT, 1), new Group(ShipType.SCOUT, 1)], fleetCompositionRoll: 7);

    ap.setLevel(Technology.SHIP_SIZE, 7);
    assertBuiltFleet(56, [new Group(ShipType.TITAN, 1), new Group(ShipType.DREADNAUGHT, 1)], fleetCompositionRoll: 7);
  });

  test('scenario4/fleet_builder_test.buildBalancedFleet', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // NO Possible DD

    ap.setLevel(Technology.SHIP_SIZE, 5);
    assertBuiltFleet(44, [new Group(ShipType.BATTLESHIP, 1), new Group(ShipType.SCOUT, 4)], fleetCompositionRoll: 4);

    ap.setLevel(Technology.ATTACK, 2);
    assertBuiltFleet(44, [new Group(ShipType.BATTLESHIP, 1), new Group(ShipType.CRUISER, 2)], fleetCompositionRoll: 4);

    ap.setLevel(Technology.ATTACK, 0);
    ap.setLevel(Technology.DEFENSE, 2);
    assertBuiltFleet(44, [new Group(ShipType.BATTLESHIP, 1), new Group(ShipType.CRUISER, 2)], fleetCompositionRoll: 4);
    assertBuiltFleet(47, [
      new Group(ShipType.BATTLESHIP, 1),
      new Group(ShipType.BATTLECRUISER, 1),
      new Group(ShipType.CRUISER, 1),
    ], fleetCompositionRoll: 4);
    assertBuiltFleet(50, [
      new Group(ShipType.BATTLESHIP, 1),
      new Group(ShipType.BATTLECRUISER, 2),
    ], fleetCompositionRoll: 4);
    assertBuiltFleet(52, [new Group(ShipType.BATTLESHIP, 2), new Group(ShipType.CRUISER, 1)], fleetCompositionRoll: 4);
    assertBuiltFleet(56, [new Group(ShipType.BATTLESHIP, 1), new Group(ShipType.CRUISER, 3)], fleetCompositionRoll: 4);

    ap.setLevel(Technology.SHIP_SIZE, 2);
    assertBuiltFleet(44, [new Group(ShipType.DESTROYER, 2), new Group(ShipType.SCOUT, 4)], fleetCompositionRoll: 4);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    assertBuiltFleet(26, [new Group(ShipType.CRUISER, 2)], fleetCompositionRoll: 4);
  });

  //–2 to the result of fleet composition if AP has Point Def and has seen enemy Fighters
  //If the modified roll result does NOT lead to 'Buy to maximize number of ships' and this AP fleet does not contain at least 1 full carrier
  test('scenario4/fleet_builder_test.subtractTwoIfHasPDAndSeenFighters', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
    ap.setLevel(Technology.POINT_DEFENSE, 1);
    game.addSeenThing(Seeable.FIGHTERS);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    assertBuiltFleet(27, [new Group(ShipType.CRUISER, 1), new Group(ShipType.SCOUT, 2)], fleetCompositionRoll: 5);
  });

  test('scenario4/fleet_builder_test.subtractTwoIfHasPDAndSeenFightersAndBuy2SC', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
    ap.setLevel(Technology.POINT_DEFENSE, 1);
    game.addSeenThing(Seeable.FIGHTERS);

    ap.setLevel(Technology.SHIP_SIZE, 5);
    ap.setLevel(Technology.ATTACK, 2);
    assertBuiltFleet(44, [
      new Group(ShipType.BATTLESHIP, 1),
      new Group(ShipType.SCOUT, 2),
      new Group(ShipType.CRUISER, 1),
    ], fleetCompositionRoll: 6);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    assertBuiltFleet(26, [new Group(ShipType.CRUISER, 1), new Group(ShipType.SCOUT, 2)], fleetCompositionRoll: 6);

    ap.setLevel(Technology.SHIP_SIZE, 2);
    assertBuiltFleet(21, [new Group(ShipType.DESTROYER, 1), new Group(ShipType.SCOUT, 2)], fleetCompositionRoll: 9);
  });

  test('scenario4/fleet_builder_test.subtractTwoIfHasPDAndSeenFightersAndDontBuy2SCIfHasFullCarrier', () {
    game.setSeenLevel(Technology.CLOAKING, 1); // No Possible DD
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.POINT_DEFENSE, 1);
    game.addSeenThing(Seeable.FIGHTERS);

    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.ATTACK, 2);
    assertBuiltFleet(27 + 26, [
      new Group(ShipType.CARRIER, 1),
      new Group(ShipType.FIGHTER, 3),
      new Group(ShipType.CRUISER, 2),
    ], fleetCompositionRoll: 6);

    ap.setLevel(Technology.SHIP_SIZE, 2);
    assertBuiltFleet(27 + 21, [
      new Group(ShipType.CARRIER, 1),
      new Group(ShipType.FIGHTER, 3),
      new Group(ShipType.DESTROYER, 2),
    ], fleetCompositionRoll: 9);
  });
}
