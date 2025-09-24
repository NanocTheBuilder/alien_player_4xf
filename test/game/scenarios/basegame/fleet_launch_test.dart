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
import 'package:test/test.dart';

import '../../fixture.dart';
import 'base_game_test_base.dart';

void main() {
  //extends BasegameTechnologyBuyerTestBase
  //extends TechnologyBuyerTestBase
  //extends Fixture

  late int roll, turn;

  setUp(() {
    //Fixture
    setupFixture(newGame());

    sheet.fleetCP = 500;
    turn = 4;
    roll = 7; //5 or less required in turn 4
  });

  tearDown(assertAllRollsUsed);

  void assertFleetLaunches() {
    int fleetCP = sheet.fleetCP;
    roller.mockRoll("Fleet launch", roll);
    fleetLauncher.rollFleetLaunch(ap, turn);
    expect(sheet.fleetCP, 0);
    expect(ap.fleets[0].fleetCP, fleetCP);
  }

  void assertFleetDoesNotLaunch() {
    int fleetCP = sheet.fleetCP;
    roller.mockRoll("Fleet launch", roll);
    fleetLauncher.rollFleetLaunch(ap, turn);
    expect(sheet.fleetCP, fleetCP);
    expect(ap.fleets, isEmpty);
  }

  test('basegame/fleet_launch_test.noLaunchInTurn1', () {
    turn = 1;
    roll = 1;
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.noLaunchUnder6', () {
    sheet.fleetCP = 5;
    turn = 2;
    roll = 1;
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.alwaysLaunchInTurn2', () {
    turn = 2;
    roll = 10;
    assertFleetLaunches();
  });

  test('basegame/fleet_launch_test.dontLaunchIfRollFails', () {
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.subtract2ForFighters', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    assertFleetLaunches();
  });

  test('basegame/fleet_launch_test.onlySubtract2ForFightersIfPDNotSeen', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    game.setSeenLevel(Technology.POINT_DEFENSE, 1);
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.onlySubtract2ForFightersIfHasEnoughCP', () {
    sheet.fleetCP = 26;
    ap.setLevel(Technology.FIGHTERS, 1);
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.testRaiderFleetLaunch', () {
    ap.setLevel(Technology.CLOAKING, 1);
    sheet.fleetCP = 13;
    roller.mockRoll("Fleet launch", roll);
    fleetLauncher.rollFleetLaunch(ap, turn);
    var fleet = ap.fleets[0];
    expect(sheet.fleetCP, 1);
    expect(fleet.fleetType, FleetType.RAIDER_FLEET);
    expect(fleet.fleetCP, 13);
    expect(fleet.buildCost, 12);
  });

  test('basegame/fleet_launch_test.onlySubtract2ForCloakingIfScannerNotSeen', () {
    ap.setLevel(Technology.FIGHTERS, 1);
    game.setSeenLevel(Technology.POINT_DEFENSE, 1);
    assertFleetDoesNotLaunch();
  });

  test('basegame/fleet_launch_test.noRaiderUnder12', () {
    ap.setLevel(Technology.CLOAKING, 1);
    sheet.fleetCP = 11;
    roller.mockRoll("Fleet launch", 3);
    fleetLauncher.rollFleetLaunch(ap, turn);
    var fleet = ap.fleets[0];
    expect(sheet.fleetCP, 0);
    expect(fleet.fleetType, FleetType.REGULAR_FLEET);
    expect(fleet.fleetCP, 11);
    expect(fleet.buildCost, 0);
  });

  test('basegame/fleet_launch_test.noRaiderFleetForHomeDefense', () {
    ap.setLevel(Technology.CLOAKING, 1);
    sheet.fleetCP = 12;
    fleetLauncher.launchFleet(ap, turn, [FleetBuildOption.HOME_DEFENSE]);
    var fleet = ap.fleets[0];
    expect(sheet.fleetCP, 0);
    expect(fleet.fleetType, FleetType.REGULAR_FLEET);
    expect(fleet.fleetCP, 12);
    expect(fleet.buildCost, 0);
  });
}
