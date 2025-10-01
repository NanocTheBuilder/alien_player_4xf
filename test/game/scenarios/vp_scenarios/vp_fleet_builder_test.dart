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
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:test/test.dart';

import '../../fixture.dart';

//TODO is there a check that scenarios and difficulties match?

void main() {
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(Game.newGame(new VpSoloScenario(), VpSoloDifficulty.NORMAL, [PlayerColor.GREEN, PlayerColor.YELLOW]));
  });

  tearDown(assertAllRollsUsed);

  void assertBuiltGroups(Fleet fleet, List<Group> expectedGroups) {
    int expectedCost = expectedGroups.fold(0, (value, group) => value + group.cost); //Sum of costs

    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  void assertBuiltFreeGroups(Fleet fleet, List<Group> expectedGroups) {
    int expectedCost = 0;
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  test('vp_scenarios/vp_fleet_builder_test.expansionFleetAlwaysBuysFullyLoadedTransport', () {
    expect(ap.getLevel(Technology.GROUND_COMBAT), 1);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.EXPANSION_FLEET, 0);
    fleetBuilder.buildFleet(ap, fleet, []);
    assertBuiltFreeGroups(fleet, [Group(ShipType.TRANSPORT, 1), Group(ShipType.INFANTRY, 6)]);
  });

  //TODO what about expansion fleet with cp ?

  test('vp_scenarios/vp_fleet_builder_test.exterminationFleetBuysFullyLoadedTransportIfRolled', () {
    expect(ap.getLevel(Technology.GROUND_COMBAT), 1);
    roller.mockRoll("Fully loaded transport", 5);
    roller.mockRoll("Fleet composition", 7); //Largest ships
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.EXTERMINATION_FLEET_HOME_WORLD, 40);
    fleetBuilder.buildFleet(ap, fleet, []);
    assertBuiltGroups(fleet, [
      Group(ShipType.TRANSPORT, 1),
      new Group(ShipType.INFANTRY, 6),
      new Group(ShipType.SCOUT, 3),
    ]);
  });

  test('vp_scenarios/vp_fleet_builder_test.dontBuyUnder40', () {
    expect(ap.getLevel(Technology.GROUND_COMBAT), 1);
    roller.mockRoll("Fleet composition", 7);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.EXTERMINATION_FLEET_HOME_WORLD, 39);
    fleetBuilder.buildFleet(ap, fleet, []);
    assertBuiltGroups(fleet, [Group(ShipType.SCOUT, 6)]);
  });

  test('vp_scenarios/vp_fleet_builder_test.dontBuyIfNotRolled', () {
    expect(ap.getLevel(Technology.GROUND_COMBAT), 1);
    roller.mockRoll("Fully loaded transport", 7); // >5
    roller.mockRoll("Fleet composition", 7);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.EXTERMINATION_FLEET_HOME_WORLD, 40);
    fleetBuilder.buildFleet(ap, fleet, []);
    assertBuiltGroups(fleet, [Group(ShipType.SCOUT, 6)]);
  });

  test('vp_scenarios/vp_fleet_builder_test.subtract2IfAbovePlanet', (){
    expect(ap.getLevel(Technology.GROUND_COMBAT), 1);
    roller.mockRoll("Fully loaded transport", 7); // >5
    roller.mockRoll("Fleet composition", 7);
    var fleet = Fleet.ofAlienPlayer(ap, FleetType.EXTERMINATION_FLEET_HOME_WORLD, 40);
    fleetBuilder.buildFleet(ap, fleet, [FleetBuildOption.COMBAT_IS_ABOVE_PLANET]);
    assertBuiltGroups(fleet, [Group(ShipType.TRANSPORT, 1), Group(ShipType.INFANTRY, 6), Group(ShipType.SCOUT, 3)]);
  });

}
