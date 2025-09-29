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
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:test/test.dart';

import '../../fixture.dart';
import 'scenario4_test_base.dart';

void main() {
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(newGame());
  });

  tearDown(assertAllRollsUsed);

  test('buildHomeDefenseWithMinesAndGround2', (){
    setCPs(70, 60, 30);
    resetLevels({Technology.SHIP_SIZE: 4, Technology.ATTACK: 2, Technology.GROUND_COMBAT: 1});
    roller.mockRoll("Ship size", 5);
    roller.mockRoll("Tech roll", 69, bound: 95); //Cloak
    roller.mockRoll("Fleet composition", 4); //balanced fleet
    roller.mockRoll("Heavy infantry", 4); //number of HI
    roller.mockRoll("Home defense units", 3); //bases, then mines
    var result = ap.buildHomeDefense();
    var fleets = result.newFleets;
    expect(fleets[0].fleetType,  FleetType.REGULAR_FLEET);
    assertGroups(fleets[0],
            [new Group(ShipType.TRANSPORT, 1), new Group (ShipType.MARINE, 5), new Group (ShipType.HEAVY_INFANTRY, 1),
            new Group(ShipType.BATTLESHIP, 1), new Group(ShipType.DESTROYER, 1), new Group(ShipType.BATTLECRUISER, 1), new Group(ShipType.CRUISER, 2)]);
    expect(fleets[1].fleetType, FleetType.DEFENSE_FLEET);
    assertGroups(fleets[1],
            [new Group(ShipType.HEAVY_INFANTRY, 4), new Group(ShipType.MINE, 3)]);
    assertAllRollsUsed();
    assertCPs(2, 0, 3);
    assertLevels({Technology.SHIP_SIZE: 5, Technology.ATTACK: 2, Technology.GROUND_COMBAT: 2, Technology.CLOAKING: 1});
  });

  test('buildColonyDefenseWithBaseAndGround1', (){
    setCPs(70, 60, 30);
    resetLevels({Technology.GROUND_COMBAT: 1});
    roller.mockRoll("Max CP 1", 9); //max spending
    roller.mockRoll("Max CP 2", 7);
    roller.mockRoll("Base or mine", 5); //buy 1 base
    var result = (ap as Scenario4Player).buildColonyDefense();
    var fleets = result.newFleets;
    expect(fleets[0].fleetType, FleetType.DEFENSE_FLEET);
    assertGroups(fleets[0],
            [new Group(ShipType.BASE, 1), new Group(ShipType.INFANTRY, 2)]);
    assertCPs(70, 60, 14);
    expect(fleets[0].hadFirstCombat, true);
    assertLevels({Technology.GROUND_COMBAT: 1});
  });


  test('buildColonyDefenseWith2MinesAndGround2', (){
    setCPs(70, 60, 30);
    resetLevels({Technology.GROUND_COMBAT: 2});
    roller.mockRoll("Max CP 1", 9); //max spending
    roller.mockRoll("Max CP 2", 7);
    roller.mockRoll("Base or mine", 6); //buy 2 mines
    var result = (ap as Scenario4Player).buildColonyDefense();
    var fleets = result.newFleets;
    expect(fleets[0].fleetType, FleetType.DEFENSE_FLEET);
    assertGroups(fleets[0],
            [new Group(ShipType.MINE, 2), new Group(ShipType.HEAVY_INFANTRY, 2)]);
    assertCPs(70, 60, 14);
    expect(fleets[0].hadFirstCombat, true);
    assertLevels({Technology.GROUND_COMBAT: 2});
  });
}