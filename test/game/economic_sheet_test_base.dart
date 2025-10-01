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

import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:test/test.dart';

import 'mock_roller.dart';

late List<List<List<int>>> resultTable;
late List<int> econRolls;
late List<int> fleetLaunchValues;
var roller = MockRoller();

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
  roller.mockRoll("Econ roll", result);
  sheet.makeRoll(turn, roller);
}

void assertIsFleet(int turn, Function sheetFactory, int result) {
  var sheet = sheetFactory();
  var difficulty = sheet.difficulty;
  makeRoll(sheet, turn, result);
  expect(sheet.fleetCP, difficulty.cpPerEcon, reason: "turn $turn roll $result is not Fleet");
}

void assertFleetResults(int turn, Function sheetFactory) {
  for (var i in getFleetRange(turn)) {
    assertIsFleet(turn, sheetFactory, i);
  }
}

void assertIsTech(int turn, Function sheetFactory, int result) {
  var sheet = sheetFactory();
  var diff = sheet.difficulty;
  makeRoll(sheet, turn, result);
  expect(sheet.techCP, diff.cpPerEcon);
}

void assertTechResults(int turn, Function sheetFactory) {
  for (var i in getTechRange(turn)) {
    assertIsTech(turn, sheetFactory, i);
  }
}

void assertIsDef(int turn, Function sheetFactory, int result) {
  var sheet = sheetFactory();
  var diff = sheet.difficulty;
  makeRoll(sheet, turn, result);
  expect(sheet.defCP, 2 * diff.cpPerEcon);
}

void assertDefResults(int turn, Function sheetFactory) {
  for (var i in getDefRange(turn)) {
    assertIsDef(turn, sheetFactory, i);
  }
}

void testEconRollsColumn(Function sheetFactory) {
  var sheet = sheetFactory();
  for (int turn = 1; turn < 23; turn++)
    expect(sheet.getEconRolls(turn), econRolls[turn]);
}

void testFleetLaunch(Function sheetFactory) {
  var sheet = sheetFactory();
  for (int turn = 1; turn < 23; turn++)
    expect(sheet.getFleetLaunch(turn), fleetLaunchValues[turn]);
}
