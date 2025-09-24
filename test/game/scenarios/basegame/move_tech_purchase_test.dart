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
import 'package:test/test.dart';

import '../../fixture.dart';
import 'base_game_test_base.dart';

void main() {
  //extends BasegameFixture
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(newGame());
  });

  void assertMovePurchase(int level, int techCP, int newLevel, int newTechCP) {
    ap.setLevel(Technology.MOVE, level);
    sheet.techCP = techCP;
    roller.mockRoll("Buy move", 1);
    var result = ap.buyNextMoveLevel();
    expect(result, newLevel != level);
    expect(ap.getLevel(Technology.MOVE), newLevel);
    expect(sheet.techCP, newTechCP);
  }

  test('buyNextMoveAtFleetLaunch', () {
    expect(ap.getLevel(Technology.MOVE), 1);
    assertMovePurchase(1, 20, 2, 0);
    assertMovePurchase(2, 25, 3, 0);
    assertMovePurchase(3, 25, 4, 0);
    assertMovePurchase(4, 25, 5, 0);
    assertMovePurchase(5, 20, 6, 0);
    assertMovePurchase(6, 20, 7, 0);
    assertMovePurchase(7, 100, 7, 100);
  });

  test('dontBuyMoveIfNoCP', () {
    assertMovePurchase(2, 10, 2, 10);
  });

  test('dontBuyMoveIfRollFails', () {
    ap.setLevel(Technology.MOVE, 3);
    sheet.techCP = 10;
    roller.mockRoll("Buy move", 5);
    ap.buyNextMoveLevel();
    expect(ap.getLevel(Technology.MOVE), 3);
    expect(sheet.techCP, 10);
  });
}
