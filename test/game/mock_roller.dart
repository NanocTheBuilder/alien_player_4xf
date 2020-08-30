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