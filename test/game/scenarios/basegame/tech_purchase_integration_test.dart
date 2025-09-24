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
import '../../technology_buyer_test_base.dart';
import 'base_game_test_base.dart';

void main() {
  //extends BasegameTechnologyBuyerTestBase
  //extends TechnologyBuyerTestBase
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(newGame());

    //TechnologyBuyerTestBase
    setupTechnologyBuyerTestBase();
  });

  tearDown(assertAllRollsUsed);

  test('basegame/tech_purchase_integration_test.integration', () {
    sheet.techCP = 120;
    ap.setLevel(Technology.SHIP_SIZE, 3);
    game.addSeenThing(Seeable.MINES);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.ATTACK, 2);
    ap.setLevel(Technology.DEFENSE, 1);
    roller.mockRoll("Ship size", 10); // no ship shize
    roller.mockRoll("Fighters", 3); // buys fighter
    roller.mockRoll("Tech roll", 5);
    roller.mockRoll("Tech roll", 5);
    roller.mockRoll("Tech roll", 6);
    ap.firstCombat(fleet);
    assertLevels({
      Technology.SHIP_SIZE: 3,
      Technology.FIGHTERS: 2,
      Technology.ATTACK: 2,
      Technology.DEFENSE: 2,
      Technology.TACTICS: 1,
      Technology.CLOAKING: 1,
      Technology.MINE_SWEEPER: 1,
    });
    expect(sheet.techCP, 10);
  });
}
