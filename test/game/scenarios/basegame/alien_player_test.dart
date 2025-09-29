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
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import '../../fixture.dart';
import '../../mock_roller.dart';

void main() {
//extends BasegameFixture {

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

  tearDown(assertAllRollsUsed);

  late EconPhaseResult result;

  void mock2Fleet1Tech1DefRoll() {
    roller.mockRoll("Econ roll", 3);
    roller.mockRoll("Econ roll", 6);
    roller.mockRoll("Econ roll", 8);
    roller.mockRoll("Econ roll", 10);
  }

  void assertRegularFleetLaunch(int fleetCP) {
    expect(result.alienPlayer, ap);
    expect(result.fleet!.fleetCP, fleetCP);
    expect(result.fleet!.fleetType, FleetType.REGULAR_FLEET);
  }

  test('basegame/alien_player_test.launchRegularFleetThenBuildLargestFleet', () {
    setCPs(60, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1});
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 3);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    expect(result.fleetCP, 10);
    expect(result.techCP, 5);
    expect(result.defCP, 10);
    expect(result.fleet, ap.fleets[0]);
    assertCPs(0, 50, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 5); //Ship size
    roller.mockRoll("Tech roll", 1); //Attack
    roller.mockRoll("Fleet composition", 3); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 2});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 2),
      Group(ShipType.SCOUT, 5)
    ]);
    assertCPs(2, 0, 10);
  });

  test('basegame/alien_player_test.launchRegularFleetThenBuildBalancedWith2SC', () {
    setCPs(60, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1, Technology.POINT_DEFENSE: 1});
    game.addSeenThing(Seeable.FIGHTERS);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 3);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    expect(result.fleetCP, 10);
    expect(result.techCP, 5);
    expect(result.defCP, 10);
    expect(result.fleet, ap.fleets[0]);
    assertCPs(0, 50, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 5); //Ship size
    roller.mockRoll("Tech roll", 1); //Attack
    roller.mockRoll("Fleet composition", 8); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 2, Technology.POINT_DEFENSE: 1});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2),
      Group(ShipType.BATTLECRUISER, 1),
      Group(ShipType.CRUISER, 1)
    ]);
    assertCPs(2, 0, 10);
  });

  test('basegame/alien_player_test.launchRegularFleetThenBuildLargestShips', () {
    setCPs(60, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1});
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 3);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    expect(result.fleetCP, 10);
    expect(result.techCP, 5);
    expect(result.defCP, 10);
    expect(result.fleet, ap.fleets[0]);
    assertCPs(0, 50, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 5); //Ship size
    roller.mockRoll("Tech roll", 1); //Attack
    roller.mockRoll("Fleet composition", 8); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 2});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [Group(ShipType.BATTLESHIP, 3), Group(ShipType.DESTROYER, 1)]);
    assertCPs(1, 0, 10);
  });

  test('basegame/alien_player_test.launchCarrierFleetThenBuildLargestFleet', () {
    setCPs(65, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1, Technology.FIGHTERS: 1});
    game.setSeenLevel(Technology.POINT_DEFENSE, 0);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 7);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 50, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 8);
    roller.mockRoll("Fighters", 6); //Buy next fighter level
    roller.mockRoll("Tech roll", 5, bound: 7); //Fighters (no attack & cloak)
    roller.mockRoll("Fleet composition", 3);
    ap.firstCombat(result.fleet!);
    assertLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1, Technology.FIGHTERS: 3});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2)
    ]);
    assertCPs(0, 0, 10);
  });

  test('basegame/alien_player_test.launchCarrierFleetThenBuildBalancedFleet', () {
    setCPs(65, 20, 0);
    resetLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1, Technology.FIGHTERS: 2});
    game.setSeenLevel(Technology.POINT_DEFENSE, 1);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 7);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 25, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 8);
    roller.mockRoll("Tech roll", 5, bound: 7); //Fighters (no attack & cloak)
    roller.mockRoll("Carrier fleet", 4); //Has seen PD, but buy only full cariers
    roller.mockRoll("Fleet composition", 6); //fleet composition
    ap.firstCombat(result.fleet!);
    assertLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1, Technology.FIGHTERS: 3});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.SCOUT, 2)
    ]);
    assertCPs(0, 0, 10);
  });

  test('basegame/alien_player_test.launchRegularFleetThenCarrierWithLargestShips', () {
    setCPs(65, 20, 0);
    resetLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1});
    game.setSeenLevel(Technology.POINT_DEFENSE, 0);
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 5);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(75);
    assertCPs(0, 25, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 8);
    roller.mockRoll("Tech roll", 5, bound: 7); //Fighters (no attack & cloak)
    roller.mockRoll("Fleet composition", 8); //fleet composition
    ap.firstCombat(result.fleet!);
    resetLevels({Technology.SHIP_SIZE: 2, Technology.ATTACK: 1, Technology.FIGHTERS: 1});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [
      Group(ShipType.CARRIER, 2),
      Group(ShipType.FIGHTER, 6),
      Group(ShipType.DESTROYER, 2)
    ]);
    assertCPs(3, 0, 10);
  });

  test('basegame/alien_player_test.launchRegularButBuildRaider', () {
    setCPs(60, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1});
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 3);
    roller.mockRoll("Buy move", 7);
    result = ap.makeEconRoll(10);
    assertRegularFleetLaunch(70);
    assertCPs(0, 50, 10);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 5);
    roller.mockRoll("Tech roll", 6, bound: 10); //Cloak
    ap.firstCombat(result.fleet!);
    resetLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 1});
    assertAllRollsUsed();
    assertGroups(result.fleet!, [Group(ShipType.RAIDER, 5)]);
    expect(result.fleet!.fleetType, FleetType.RAIDER_FLEET);
    assertCPs(10, 0, 10);
  });

  test('basegame/alien_player_test.launchRaiderBuyTechs', () {
    setCPs(12, 45, 0);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1, Technology.CLOAKING: 1});
    mock2Fleet1Tech1DefRoll();
    roller.mockRoll("Fleet launch", 7);
    roller.mockRoll("Buy move", 4);
    result = ap.makeEconRoll(10);
    expect(result.fleet!.fleetType, FleetType.RAIDER_FLEET);
    assertCPs(10, 30, 10);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1, Technology.CLOAKING: 1, Technology.MOVE: 2});
    expect(result.moveTechRolled, true);
    assertGroups(result.fleet!, [Group(ShipType.RAIDER, 1)]);
    assertAllRollsUsed();

    roller.mockRoll("Ship size", 6);
    roller.mockRoll("Cloaking", 6); //next cloak
    ap.firstCombat(result.fleet!);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 1, Technology.CLOAKING: 2, Technology.MOVE: 2});
    assertCPs(10, 0, 10);
  });

  test('basegame/alien_player_test.buildHomeDefenseNoRaiderFleetNoMineSweep', () {
    setCPs(70, 50, 30);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 2});
    roller.mockRoll("Ship size", 5);
    roller.mockRoll("Tech roll", 6, bound: 9); //Cloak, no Mine Sweep
    roller.mockRoll("Fleet composition", 4); //balanced fleet
    roller.mockRoll("Home defense units", 7); //bases, then mines
    FleetBuildResult result = ap.buildHomeDefense();
    List<Fleet> fleets = result.newFleets;
    expect(fleets[0].fleetType, FleetType.REGULAR_FLEET);
    assertGroups(fleets[0], [
      Group(ShipType.BATTLESHIP, 1),
      Group(ShipType.DESTROYER, 1),
      Group(ShipType.BATTLECRUISER, 1),
      Group(ShipType.CRUISER, 2)
    ]);
    expect(fleets[1].fleetType, FleetType.DEFENSE_FLEET);
    assertGroups(fleets[1], [Group(ShipType.BASE, 2), Group(ShipType.MINE, 1)]);
    assertAllRollsUsed();
    assertCPs(2, 0, 1);
    assertLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 2, Technology.CLOAKING: 1});
    expect(fleets[0].hadFirstCombat, true);
    expect(fleets[1].hadFirstCombat, true);
  });
}
