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

    sheet.defCP = 100;
  });

  tearDown(assertAllRollsUsed);

  void assertBuiltGroups(List<Group> expectedGroups) {
    Fleet fleet = (defBuilder as Scenario4DefenseBuilder).buildColonyDefense(ap)!;
    var expectedCost = 0;
    for (Group g in expectedGroups) {
      expectedCost += g.cost;
    }
    expect(fleet.fleetType, FleetType.DEFENSE_FLEET);
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }


    test('scenario4/colony_defense_builder_test.noCPbuildsNull', (){
        sheet.defCP = 1;
        expect((ap as Scenario4Player).buildColonyDefense().newFleets.length, 0);
    });


    test('scenario4/colony_defense_builder_test.dontSpendOverDiceRoll', () {
        roller.mockRoll("Max CP 1", 1);
        roller.mockRoll("Max CP 2", 1);
        roller.mockRoll("Base or mine", 1);
        assertBuiltGroups([new Group(ShipType.INFANTRY, 1)]);
    });

    test('scenario4/colony_defense_builder_test.dontSpendMoreThanDefCP', () {
        sheet.defCP = 2;
        roller.mockRoll("Max CP 1", 10);
        roller.mockRoll("Max CP 2", 10);
        roller.mockRoll("Base or mine", 1);
        assertBuiltGroups([new Group(ShipType.INFANTRY, 1)]);
    });

      test('scenario4/colony_defense_builder_test.buy1Base', () {
        roller.mockRoll("Max CP 1", 5);
        roller.mockRoll("Max CP 2", 7); //max cp
        roller.mockRoll("Base or mine", 5); //buy 1 base
        assertBuiltGroups([new Group(ShipType.BASE, 1)]);
    });

    test('scenario4/colony_defense_builder_test.buy0Base', () {
        roller.mockRoll("Max CP 1", 1);
        roller.mockRoll("Max CP 2", 0); //max cp
        roller.mockRoll("Base or mine", 5); //buy 1 base
        assertBuiltGroups([]);
    });

    test('scenario4/colony_defense_builder_test.buy2Mines', () {
        roller.mockRoll("Max CP 1", 3);
        roller.mockRoll("Max CP 2", 7); //max cp
        roller.mockRoll("Base or mine", 6); //buy 2 mines
        assertBuiltGroups([new Group(ShipType.MINE, 2)]);
    });

    test('scenario4/colony_defense_builder_test.buy1Mine', () {
        roller.mockRoll("Max CP 1", 3);
        roller.mockRoll("Max CP 2", 2); //max cp
        roller.mockRoll("Base or mine", 6); //buy 2 mines
        assertBuiltGroups([new Group(ShipType.MINE, 1)]);
    });

    test('scenario4/colony_defense_builder_test.buy1MineIfCantAffordBase', () {
        roller.mockRoll("Max CP 1", 2);
        roller.mockRoll("Max CP 2", 3); //max cp
        roller.mockRoll("Base or mine", 5); //buy 1 base
        assertBuiltGroups([new Group(ShipType.MINE, 1)]);
    });

    test('scenario4/colony_defense_builder_test.buy2MinesAnd4Infantry', () {
        roller.mockRoll("Max CP 1", 10);
        roller.mockRoll("Max CP 2", 9); //max cp
        roller.mockRoll("Base or mine", 6); //buy 2 mines
        assertBuiltGroups([new Group(ShipType.MINE, 2), new Group(ShipType.INFANTRY, 4)]);
    });

    test('scenario4/colony_defense_builder_test.buy2MinesAnd3HeavyInfantry', () {
        ap.setLevel(Technology.GROUND_COMBAT, 2);
        roller.mockRoll("Max CP 1", 10);
        roller.mockRoll("Max CP 2", 9); //max cp
        roller.mockRoll("Base or mine", 6); //buy 2 mines
        assertBuiltGroups([new Group(ShipType.MINE, 2), new Group(ShipType.HEAVY_INFANTRY, 3)]);
    });

    test('scenario4/colony_defense_builder_test.buy2MinesAnd1InfIfCantAffordHI', () {
        ap.setLevel(Technology.GROUND_COMBAT, 2);
        roller.mockRoll("Max CP 1", 10);
        roller.mockRoll("Max CP 2", 2); //max cp
        roller.mockRoll("Base or mine", 6); //buy 2 mines
        assertBuiltGroups([new Group(ShipType.MINE, 2), new Group(ShipType.INFANTRY, 1)]);
    });

}
