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
import 'package:alienplayer4xf/game/fleet_launcher.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/game/technology_buyer.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {
//extends BasegameFixture {

  late Game game;
  late AlienPlayer ap;
  late DefenseBuilder defBuilder;
  late MockRoller roller;
  late AlienEconomicSheet sheet;
  late FleetBuilder fleetBuilder;
  late TechnologyBuyer techBuyer;
  late FleetLauncher fleetLauncher;

  void assertEquals(expected, actual) {
    expect(actual, expected);
  }

  void setLevel(Technology technology, int level) {
    ap.technologyLevels[technology] = level;
  }

  void assertLevel(Technology technology, int expected) {
    expect(ap.technologyLevels[technology], expected);
  }

  void assertRoller() {
    expect(roller.rolls.length, 0);
  }

  void setCPs(int fleetCP, int techCP, int defCP) {
    sheet.fleetCP = fleetCP;
    sheet.techCP = techCP;
    sheet.defCP = defCP;
  }

  void assertCPs(int fleetCP, int techCP, int defCP) {
    expect(sheet.fleetCP, fleetCP);
    expect(sheet.techCP, techCP);
    expect(sheet.defCP, defCP);
  }

  //assertGroups
  void assertFleet(Fleet fleet, List<Group> expectedGroups) {
    assertEquals(expectedGroups, fleet.groups);
  }

  setUp(() {
    game = Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    roller = MockRoller();
    game.roller = roller;
    defBuilder = game.scenario.defenseBuilder;
    fleetBuilder = game.scenario.fleetBuilder;
    fleetLauncher = game.scenario.fleetLauncher;
    techBuyer = game.scenario.techBuyer;
    ap = game.aliens[0];
    sheet = ap.economicSheet;
  });

  tearDown(assertRoller);
//BaseGameFixture

  late EconPhaseResult result;

  void assertGroups(List<Group> expectedGroups) {
    assertFleet(result.fleet!, expectedGroups);
  }

  void mock2Fleet1Tech1DefRoll() {
    roller.mockRoll(3);
    roller.mockRoll(6);
    roller.mockRoll(8);
    roller.mockRoll(10);
  }

  void assertRegularFirstCombat(int fleetCompositionRoll) {
    roller.mockRoll(5); //Ship size
    roller.mockRoll2(10, 1); //Attack
    roller.mockRoll(fleetCompositionRoll); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.SHIP_SIZE, 5);
    assertLevel(Technology.ATTACK, 2);
    assertRoller();
  }

  void assertRegularFleetLaunch(int fleetCP) {
    assertEquals(ap, result.alienPlayer);
    assertEquals(fleetCP, result.fleet!.fleetCP);
    assertEquals(FleetType.REGULAR_FLEET, result.fleet!.fleetType);
  }

  void launchRegularFleet() {
    setCPs(60, 45, 0);
    setLevel(Technology.SHIP_SIZE, 4);
    setLevel(Technology.ATTACK, 1);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(3); //fleet launch
    roller.mockRoll(7); //move tech
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    assertEquals(10, result.fleetCP);
    assertEquals(5, result.techCP);
    assertEquals(10, result.defCP);
    assertEquals(ap.fleets[0], result.fleet);
    assertCPs(0, 50, 10);
    assertRoller();
  }

  test('launchRegularFleetThenBuildLargestFleet', () {
    launchRegularFleet();
    assertRegularFirstCombat(3);
    assertGroups([
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 2),
      Group(ShipType.SCOUT, 5)
    ]);
    assertCPs(2, 0, 10);
  });

  test('launchRegularFleetThenBuildBalancedWith2SC', () {
    setLevel(Technology.POINT_DEFENSE, 1);
    game.addSeenThing(Seeable.FIGHTERS);
    launchRegularFleet();
    assertRegularFirstCombat(8);
    assertGroups([
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2),
      Group(ShipType.BATTLECRUISER, 1),
      Group(ShipType.CRUISER, 1)
    ]);
    assertCPs(2, 0, 10);
  });

  test('launchRegularFleetThenBuildLargestShips', () {
    launchRegularFleet();
    assertRegularFirstCombat(8);
    assertGroups([Group(ShipType.BATTLESHIP, 3), Group(ShipType.DESTROYER, 1)]);
    assertCPs(1, 0, 10);
  });

  test('launchCarrierFleetThenBuildLargestFleet', () {
    setCPs(65, 45, 0);
    setLevel(Technology.SHIP_SIZE, 2);
    setLevel(Technology.ATTACK, 1);
    setLevel(Technology.FIGHTERS, 1);
    game.setSeenLevel(Technology.POINT_DEFENSE, 0);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(7); //fleet launch
    roller.mockRoll(7); //move tech
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 50, 10);
    assertRoller();

    roller.mockRoll(8); //Ship size
    roller.mockRoll(6); //Buy next fighter level
    roller.mockRoll2(7, 5); //Fighters (no attack & cloak)
    roller.mockRoll(3); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.SHIP_SIZE, 2);
    assertLevel(Technology.ATTACK, 1);
    assertLevel(Technology.FIGHTERS, 3);
    assertRoller();
    assertGroups([
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2)
    ]);
    assertCPs(0, 0, 10);
  });

  test('launchCarrierFleetThenBuildBalancedFleet', () {
    setCPs(65, 20, 0);
    setLevel(Technology.SHIP_SIZE, 2);
    setLevel(Technology.ATTACK, 1);
    setLevel(Technology.FIGHTERS, 2);
    game.setSeenLevel(Technology.POINT_DEFENSE, 1);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(7); //fleet launch
    roller.mockRoll(7); //move tech
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 25, 10);
    assertRoller();

    roller.mockRoll(8); //Ship size
    roller.mockRoll2(7, 5); //Fighters (no attack & cloak)
    roller.mockRoll(4); //Has seen PD, but buy only full cariers
    roller.mockRoll(6); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.SHIP_SIZE, 2);
    assertLevel(Technology.ATTACK, 1);
    assertLevel(Technology.FIGHTERS, 3);
    assertRoller();
    assertGroups([
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2)
    ]);
    assertCPs(0, 0, 10);
  });

  test('launchRegularFleetThenCarrierWithLargestShips', () {
    setCPs(65, 20, 0);
    setLevel(Technology.SHIP_SIZE, 2);
    setLevel(Technology.ATTACK, 1);
    setLevel(Technology.FIGHTERS, 0);
    game.setSeenLevel(Technology.POINT_DEFENSE, 0);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(5); //fleet launch
    roller.mockRoll(7); //move tech
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 25, 10);
    assertRoller();

    roller.mockRoll(8); //Ship size
    roller.mockRoll2(7, 5); //Fighters (no attack & cloak)
    roller.mockRoll(8); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.SHIP_SIZE, 2);
    assertLevel(Technology.ATTACK, 1);
    assertLevel(Technology.FIGHTERS, 1);
    assertRoller();
    assertGroups([
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 2)
    ]);
    assertCPs(3, 0, 10);
  });

  test('launchRegularButBuildRaider', () {
    setCPs(60, 45, 0);
    setLevel(Technology.SHIP_SIZE, 4);
    setLevel(Technology.ATTACK, 1);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(3); //fleet launch
    roller.mockRoll(7); //move tech
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    assertCPs(0, 50, 10);
    assertRoller();
    roller.mockRoll(5); //Ship size
    roller.mockRoll2(10, 6); //Cloak
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.SHIP_SIZE, 5);
    assertLevel(Technology.CLOAKING, 1);
    assertRoller();
    assertGroups([Group(ShipType.RAIDER, 5)]);
    assertEquals(FleetType.RAIDER_FLEET, result.fleet!.fleetType);
    assertCPs(10, 0, 10);
  });

  test('launchRaiderBuyTechs', () {
    setCPs(12, 45, 0);
    setLevel(Technology.SHIP_SIZE, 4);
    setLevel(Technology.ATTACK, 1);
    setLevel(Technology.CLOAKING, 1);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll(7); //fleet launch
    roller.mockRoll(4); //move tech
    result = ap.makeEconRoll(10);
    assertEquals(FleetType.RAIDER_FLEET, result.fleet!.fleetType);
    assertCPs(10, 30, 10);
    assertLevel(Technology.MOVE, 2);
    assertEquals(true, result.moveTechRolled);
    assertGroups([Group(ShipType.RAIDER, 1)]);
    assertRoller();

    roller.mockRoll(6); //Ship size
    roller.mockRoll(6); //next cloak
    ap.firstCombat(result.fleet!);
    assertLevel(Technology.CLOAKING, 2);
    assertCPs(10, 0, 10);
  });

  test('buildHomeDefenseNoRaiderFleetNoMineSweep', () {
    setCPs(70, 50, 30);
    setLevel(Technology.SHIP_SIZE, 4);
    setLevel(Technology.ATTACK, 2);
    roller.mockRoll(5); //Ship size
    roller.mockRoll2(9, 6); //Cloak
    roller.mockRoll(4); //balanced fleet
    roller.mockRoll(7); //bases, then mines
    FleetBuildResult result = ap.buildHomeDefense();
    List<Fleet> fleets = result.newFleets;
    assertEquals(FleetType.REGULAR_FLEET, fleets[0].fleetType);
    assertFleet(fleets[0], [
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.BATTLECRUISER, 1),
      Group(ShipType.CRUISER, 2)
    ]);
    assertEquals(FleetType.DEFENSE_FLEET, fleets[1].fleetType);
    assertFleet(fleets[1], [Group(ShipType.BASE, 2), Group(ShipType.MINE, 1)]);
    assertRoller();
    assertCPs(2, 0, 1);
    assertLevel(Technology.SHIP_SIZE, 5);
    assertLevel(Technology.CLOAKING, 1);
    assertEquals(true, fleets[0].hadFirstCombat);
    assertEquals(true, fleets[1].hadFirstCombat);
  });
}
