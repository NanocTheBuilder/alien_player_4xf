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
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {

  late AlienPlayer ap;
  late AlienEconomicSheet sheet;
  late MockRoller roller;
  late DefenseBuilder defBuilder;

  //utils come first
  void assertBuiltGroups(int defCP, int roll, List<Group> expectedGroups) {
    sheet.defCP = defCP;
    roller.mockRoll("Home defense units", roll);
    var fleet = defBuilder.buildHomeDefense(ap);
    var expectedCost = 0;
    for (Group g in expectedGroups) {
      expectedCost += g.shipType.cost * g.size;
    }
    expect(fleet!.fleetType, FleetType.DEFENSE_FLEET);
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  //tests

  setUp(() {
    var game = Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    ap = game.aliens[0];
    sheet = ap.economicSheet;
    roller = MockRoller();
    game.roller = roller;
    defBuilder = game.scenario.defenseBuilder;
  });

  test('spendNoDefenseCPBuildNothings', () {
    sheet.defCP = 0;
    expect(defBuilder.buildHomeDefense(ap), null);
  });

  test('spendAllOnMines', () {
    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
    assertBuiltGroups(10, 1, [Group(ShipType.MINE, 2)]);
  });

  test('spendAllOnBases', () {
    assertBuiltGroups(12, 8, [Group(ShipType.BASE, 1)]);
    assertBuiltGroups(24, 8, [Group(ShipType.BASE, 2)]);
    assertBuiltGroups(36, 8, [Group(ShipType.BASE, 3)]);
    assertBuiltGroups(51, 8, [Group(ShipType.BASE, 4)]);

    assertBuiltGroups(
        17, 8, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        29, 8, [Group(ShipType.BASE, 2), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        34, 8, [Group(ShipType.BASE, 2), Group(ShipType.MINE, 2)]);

    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
  });

  test('spendBalanced', () {
    assertBuiltGroups(12, 5, [Group(ShipType.BASE, 1)]);
    assertBuiltGroups(
        17, 5, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        24, 5, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 2)]);

    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
  });
}
