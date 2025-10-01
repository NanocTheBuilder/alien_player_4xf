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
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:test/test.dart';

import '../../fixture.dart';

void main() {
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(Game.newGame(new Vp2pScenario(), Vp2pDifficulty.NORMAL, [PlayerColor.GREEN, PlayerColor.YELLOW]));
  });

  tearDown(assertAllRollsUsed);

  test('vp_scenarios/vp_2p_fleet_launch_test.launchExterminationFleet', () {
    VpEconomicSheet vpSheet = sheet as VpEconomicSheet;

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 8);
    assertFleetLaunched(7, FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL, "1", 10);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    assertFleetLaunched(8, FleetType.EXTERMINATION_FLEET_HOME_WORLD, "2", 10);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    assertFleetLaunched(9, FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL, "3", 10);

    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 6);
    assertFleetLaunched(10, FleetType.EXTERMINATION_FLEET_HOME_WORLD, "4", 10);

    vpSheet.fleetCP = 10;
    vpSheet.fleetCP = 10;
    roller.mockRoll("Fleet launch", 1); //launch
    roller.mockRoll("Fleet type", 4);
    assertFleetLaunched(11, FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL, "5", 10);
  });
}

void assertFleetLaunched(int turn, FleetType fleetType, String name, int fleetCP) {
  var fleet = fleetLauncher.rollFleetLaunch(ap, turn)!;
  expect(fleet.fleetType, fleetType);
  expect(fleet.name, name);
  expect(fleet.fleetCP, fleetCP);
  expect(sheet.fleetCP, 0);
  expect(ap.fleets.last, fleet);
}
