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
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import 'mock_roller.dart';

void main() {

  //@formatter:off
  var resultTable = [
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
  ];

  var econRolls = [0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5];

  var fleetLaunchValues = [0, -99, 10, 10, 5, 3, 4, 4, 4, 5, 5, 3, 3, 3, 10, 3, 10, 3, 10, 3, 10, 3, 10];
  //@formatter:on

  List getResult(int turn, int index) {
    return resultTable[turn][index];
  }

  List getRange(int turn, int index) {
    var range = getResult(turn, index);
    if (range.isNotEmpty) {
      int lower = range[0];
      int higher = range.length == 1 ? lower + 1 : range[1] + 1;
      var result = List.generate(higher - lower, (int index) => index + lower);
      return result;
    } else {
      return [];
    }
  }

  List getFleetRange(int turn) {
    return getRange(turn, 1);
  }

  List getTechRange(int turn) {
    return getRange(turn, 2);
  }

  List getDefRange(int turn) {
    return getRange(turn, 3);
  }

  void makeRoll(AlienEconomicSheet sheet, int turn, int result) {
    var roller = MockRoller();
    roller.mockRoll("Econ roll", result);
    sheet.makeRoll(turn, roller);
  }

  void assertIsFleet(int turn, Difficulty difficulty, int result) {
    var sheet = AlienEconomicSheet(difficulty);
    makeRoll(sheet, turn, result);
    expect(sheet.fleetCP, difficulty.cpPerEcon,
        reason: "turn $turn roll $result is not Fleet");
  }

  void assertFleetResults(int turn, Difficulty diff) {
    for (var i in getFleetRange(turn)) {
      assertIsFleet(turn, diff, i);
    }
  }

  void assertIsTech(int turn, Difficulty diff, int result) {
    var sheet = AlienEconomicSheet(diff);
    makeRoll(sheet, turn, result);
    expect(sheet.techCP, diff.cpPerEcon);
  }

  void assertTechResults(int turn, Difficulty diff) {
    for (var i in getTechRange(turn)) {
      assertIsTech(turn, diff, i);
    }
  }

  void assertIsDef(int turn, Difficulty diff, int result) {
    var sheet = AlienEconomicSheet(diff);
    makeRoll(sheet, turn, result);
    expect(sheet.defCP, 2 * diff.cpPerEcon);
  }

  void assertDefResults(int turn, Difficulty diff) {
    for (var i in getDefRange(turn)) {
      assertIsDef(turn, diff, i);
    }
  }

  test('testCPResults', () {
    for (int turn = 1; turn < 23; turn++) {
      for (var diff in BaseGameDifficulty.values) {
        assertFleetResults(turn, diff);
        assertTechResults(turn, diff);
        assertDefResults(turn, diff);
      }
    }
  });

  test('testEconResult', () {
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

  test('testEconRollsColumn', () {
    AlienEconomicSheet sheet = AlienEconomicSheet(BaseGameDifficulty.EASY);
    for (int turn = 1; turn < 23; turn++)
      expect(sheet.getEconRolls(turn), econRolls[turn]);
  });

  test('testFleetLaunch', () {
    AlienEconomicSheet sheet = AlienEconomicSheet(BaseGameDifficulty.EASY);
    for (int turn = 1; turn < 23; turn++)
      expect(sheet.getFleetLaunch(turn), fleetLaunchValues[turn]);
  });
}
