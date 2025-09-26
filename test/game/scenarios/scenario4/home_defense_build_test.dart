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
  setUp(() {
    //Fixture
    setupFixture(newGame());
  });

  tearDown(assertAllRollsUsed);

  void assertBuiltGroups(int defCP, int roll, List<Group> expectedGroups) {
    sheet.defCP = defCP;
    roller.mockRoll("Home defense units", roll);
    Fleet fleet = (defBuilder as Scenario4DefenseBuilder).buildHomeDefense(ap)!;
    int expectedCost = expectedGroups.fold(0, (value, group) => value + group.cost); //Sum of costs
    expect(fleet.fleetType, FleetType.DEFENSE_FLEET);
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  test('senario4/home_defense_build_test.ifNoGroundCombatTechSpendBalanced', () {
    assertBuiltGroups(12, 5, [new Group(ShipType.BASE, 1)]);
    assertBuiltGroups(17, 5, [new Group(ShipType.BASE, 1), new Group(ShipType.MINE, 1)]);
    assertBuiltGroups(24, 5, [new Group(ShipType.BASE, 1), new Group(ShipType.MINE, 2)]);
    assertBuiltGroups(34, 5, [new Group(ShipType.BASE, 2), new Group(ShipType.MINE, 2)]);

    assertBuiltGroups(5, 1, [new Group(ShipType.MINE, 1)]);
  });

  test('scenario4/home_defense_build_test.buyHeavyInfantry', () {
    ap.setLevel(Technology.GROUND_COMBAT, 2);
    assertBuiltGroups(17, 5, [new Group(ShipType.BASE, 1), new Group(ShipType.MINE, 1)]);

    roller.mockRoll("Heavy infantry", 1);
    assertBuiltGroups(27, 5, [
      new Group(ShipType.HEAVY_INFANTRY, 1),
      new Group(ShipType.BASE, 1),
      new Group(ShipType.MINE, 2),
    ]);

    roller.mockRoll("Heavy infantry", 2);
    assertBuiltGroups(30, 5, [
      new Group(ShipType.HEAVY_INFANTRY, 2),
      new Group(ShipType.BASE, 1),
      new Group(ShipType.MINE, 2),
    ]);

    roller.mockRoll("Heavy infantry", 10);
    assertBuiltGroups(35, 5, [new Group(ShipType.HEAVY_INFANTRY, 10), new Group(ShipType.MINE, 1)]);
  });

  test('scenario4/home_defense_build_test.buy2GravIfAble', () {
    ap.setLevel(Technology.GROUND_COMBAT, 3);
    assertBuiltGroups(17, 5, [new Group(ShipType.BASE, 1), new Group(ShipType.MINE, 1)]);

    roller.mockRoll("Heavy infantry", 2);
    assertBuiltGroups(26, 5, [
      new Group(ShipType.GRAV_ARMOR, 2),
      new Group(ShipType.HEAVY_INFANTRY, 2),
      new Group(ShipType.BASE, 1),
    ]);

    roller.mockRoll("Heavy infantry", 2);
    assertBuiltGroups(38, 5, [
      new Group(ShipType.GRAV_ARMOR, 2),
      new Group(ShipType.HEAVY_INFANTRY, 2),
      new Group(ShipType.BASE, 1),
      new Group(ShipType.MINE, 2),
    ]);
  });
}
