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

import 'dart:collection';
import 'dart:core';
import 'package:test/test.dart';

import 'package:alienplayer4xf/game/dice_roller.dart';

typedef RollMock = ({String description, int bound, int result}); 

class MockRoller extends DiceRoller {

  Queue<RollMock> rolls = Queue();

  void mockRoll(String description, int result, {int bound = 10}) {
    rolls.add((description: description, bound: bound, result: result));
  }

  @override
  int roll(String description, {int bound = 10}) {
    var call = rolls.removeFirst();
    expect(call.bound, equals(bound));
    expect(call.description, equals(description));
    return call.result;
  }

  void assertAllUsed() {
    expect(rolls.isEmpty, isTrue, reason: "Not all mocked rolls were used! Remaining: $rolls");
  }
}