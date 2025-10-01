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
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';


import 'economic_sheet_test_base.dart';

void main() {

  //@formatter:off
  resultTable = [
    [[     ], [     ], [      ], [      ]],
    [[ 1, 2], [     ], [ 3, 10], [      ]],
    [[    1], [ 2, 3], [ 4, 10], [      ]],
    [[    1], [ 2, 4], [ 5,  8], [ 9, 10]],
    [[    1], [ 2, 5], [ 6,  8], [ 9, 10]],
    [[    1], [ 2, 5], [ 6,  9], [    10]],
    [[    1], [ 2, 6], [ 7,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 6], [ 7,  9], [    10]],
    [[     ], [ 1, 6], [ 7,  9], [    10]],
    [[     ], [ 1, 6], [ 7,  9], [    10]],
    [[     ], [ 1, 6], [ 7, 10], [      ]],
    [[     ], [ 1, 6], [ 7, 10], [      ]],
    [[     ], [ 1, 7], [ 8, 10], [      ]],
    [[     ], [ 1, 7], [ 8, 10], [      ]],
    [[     ], [ 1, 8], [ 9, 10], [      ]],
    [[     ], [ 1, 8], [ 9, 10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
  ];

  econRolls = [0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5];

  fleetLaunchValues = [0, -99, 10, 10, 5, 3, 4, 4, 4, 5, 5, 3, 3, 3, 10, 3, 10, 3, 10, 3, 10, 3, 10];
  //@formatter:on

  tearDown(roller.assertAllUsed);

  //TODO delete 'new' keywords everywhere

  test('alien_economic_sheet_test.testCPResults', () {
    for (int turn = 1; turn < 23; turn++) {
      for (var diff in BaseGameDifficulty.values) {
        assertFleetResults(turn, () => AlienEconomicSheet(diff));
        assertTechResults(turn, () => AlienEconomicSheet(diff));
        assertDefResults(turn, () => AlienEconomicSheet(diff));
      }
    }
  });

  test('alien_economic_sheet_test.testEconResult', () {
    AlienEconomicSheet sheet = AlienEconomicSheet(BaseGameDifficulty.EASY);
    expect(sheet.getExtraEcon(4), 0);
    makeRoll(sheet, 1, 1);
    makeRoll(sheet, 2, 1);
    expect(sheet.getExtraEcon(4), 1);
    expect(sheet.getExtraEcon(5), 2);
    expect(sheet.getExtraEcon(6), 2);
    makeRoll(sheet, 7, 1);
    expect(sheet.getExtraEcon(10), 2);
    expect(sheet.getExtraEcon(98), 2);
    expect(sheet.getExtraEcon(99), 2);
  });

  test('alien_economic_sheet_test.testEconRollsColumn', () {
    testEconRollsColumn(() => AlienEconomicSheet(BaseGameDifficulty.EASY));
  });

  test('alien_economic_sheet_test.testFleetLaunch', () {
    testFleetLaunch(() => AlienEconomicSheet(BaseGameDifficulty.EASY));
  });
}
