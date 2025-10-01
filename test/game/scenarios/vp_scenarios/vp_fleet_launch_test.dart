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

  void assertFleetLaunched(int turn, FleetType fleetType, String name, int fleetCP) {
    Fleet fleet = fleetLauncher.rollFleetLaunch(ap, turn)!;
    expect(fleet.fleetType, fleetType);
    expect(fleet.name, name);
    expect(fleet.fleetCP, fleetCP);
  }

  void assertBank(int expectedBank) {
    expect((sheet as VpEconomicSheet).bank, expectedBank);
  }

  test('vp_scenarios/vp_fleet_launch_test.noCpLaunchesExpansionFleetFromBank', () {
    roller.mockRoll("Fleet launch", 1); //launch
    assertFleetLaunched(2, FleetType.EXPANSION_FLEET, "1", 50);
    assertBank(50);

    roller.mockRoll("Fleet launch", 1); //launch
    assertFleetLaunched(2, FleetType.EXPANSION_FLEET, "2", 50);
    assertBank(0);

    roller.mockRoll("Fleet launch", 1); //launch
    expect(fleetLauncher.rollFleetLaunch(ap, 2), null);
    assertBank(0);
  });

  test('vp_scenarios/vp_fleet_launch_test.dontSpendMoreFromTheBankThanAvailable', () {
    var vpSheet = sheet as VpEconomicSheet;
    vpSheet.spendBank(40);
    expect(vpSheet.bank, 60);
    roller.mockRoll("Fleet launch", 1); //launch
    assertFleetLaunched(2, FleetType.EXPANSION_FLEET, "1", 50);
    assertBank(10);
    roller.mockRoll("Fleet launch", 1); //launch
    expect(fleetLauncher.rollFleetLaunch(ap, 2), null);
    assertBank(10);
  });

  test('vp_scenarios/vp_fleet_launch_test.launchExpansionFleetIfRolled', () {
    var vpSheet = sheet as VpEconomicSheet;

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 7);
    assertFleetLaunched(2, FleetType.EXPANSION_FLEET, "1", 60);
    assertBank(50);

    vpSheet.fleetCP = 10;
    vpSheet.bank = 60;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 5);
    assertFleetLaunched(8, FleetType.EXPANSION_FLEET, "2", 60);
    assertBank(10);

    vpSheet.fleetCP = 10;
    vpSheet.bank = 60;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 3);
    assertFleetLaunched(11, FleetType.EXPANSION_FLEET, "3", 60);
    assertBank(10);
  });

  //TODO in coop, fleet type depends on turn number

  test('vp_scenarios/vp_fleet_launch_test.launchExterminationFleet', () {
    VpEconomicSheet vpSheet = sheet as VpEconomicSheet;

    vpSheet.bank = 60;

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 8);
    roller.mockRoll("Extermination Fleet Type", 1, bound: 2);
    assertFleetLaunched(7, FleetType.EXTERMINATION_FLEET_HOME_WORLD, "1", 10);
    assertBank(60);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    roller.mockRoll("Extermination Fleet Type", 1, bound: 2);
    assertFleetLaunched(8, FleetType.EXTERMINATION_FLEET_HOME_WORLD, "2", 10);
    assertBank(60);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    roller.mockRoll("Extermination Fleet Type", 2, bound: 2);
    assertFleetLaunched(9, FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL, "3", 10);
    assertBank(60);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    roller.mockRoll("Extermination Fleet Type", 2, bound: 2);
    assertFleetLaunched(10, FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL, "4", 10);
    assertBank(60);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 4);
    roller.mockRoll("Extermination Fleet Type", 1, bound: 2);
    assertFleetLaunched(11, FleetType.EXTERMINATION_FLEET_HOME_WORLD, "5", 10);
    assertBank(60);
  });

  test('vp_scenarios/vp_fleet_launch_test.launchRaiderFleet', () {
    VpEconomicSheet vpSheet = sheet as VpEconomicSheet;

    vpSheet.fleetCP = 12;
    vpSheet.bank = 10;
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Fleet launch", 1); //launch
    assertFleetLaunched(2, FleetType.RAIDER_FLEET, "1", 12);
    assertBank(10);
  });
}
