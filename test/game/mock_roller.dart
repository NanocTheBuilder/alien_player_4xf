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

import 'package:alienplayer4xf/game/dice_roller.dart';

class MockRoller extends DiceRoller {

  static const int limit = 0;
  static const int result = 1;
  Queue<List<int>> rolls = Queue();

  void mockRoll(int roll) {
    mockRoll2(10, roll);
  }

void mockRoll2(int limit, int roll) {
    rolls.add([limit, roll]);
  }

  @override
  int roll([int bound = 10]) {
    var call = rolls.removeFirst();
    assert(call[limit] == bound);
    return call[result];
  }

}