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
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(newGame());

    setupTechnologyBuyerTestBase();
  });

  tearDown(assertAllRollsUsed);

  // 1-2 Attack
  // 3-4 Defense
  // 5* Tactics
  // 6** Cloak
  // 7 Scan
  // 8 Fighter
  // 9 Point Defense
  // 10 Mine Sweeper

  test('basegame/remaining_tech_purchase_test.allTechAvailable', () {
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[1, 2, 10]], {Technology.ATTACK: 3, Technology.DEFENSE: 2}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[3, 4, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 3}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[5, 10],[1, 2]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.TACTICS: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[6, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.CLOAKING: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[7, 10], [1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.SCANNER: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[8, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.FIGHTERS: 1}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[9, 10], [1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.POINT_DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[10, 10], [4, 4]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.MINE_SWEEPER: 2}, 5);
  });

  
  test('basegame/remaining_tech_purchase_test.rerollMineSweepersInHomeDefense', () {
    var options = [FleetBuildOption.HOME_DEFENSE];
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[1, 2, 9]], {Technology.ATTACK: 3, Technology.DEFENSE: 2}, 5, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[3, 4, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 3}, 5, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[5, 9],[1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.TACTICS: 2}, 0, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[6, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.CLOAKING: 1}, 0, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[7, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.SCANNER: 1}, 10, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[8, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.FIGHTERS: 1}, 5, options);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[9, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.POINT_DEFENSE: 1}, 10, options);
  });

  test('basegame/remaining_tech_purchase_test.buyAttackOrDefenseInsteadOfTactics', () {
    assertRemainingBuys({Technology.ATTACK: 0, Technology.DEFENSE: 2}, 30, [[5, 10], [1, 1]], {Technology.ATTACK: 1, Technology.DEFENSE: 2, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 1, Technology.DEFENSE: 2}, 30, [[5, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 0}, 30, [[5, 10], [1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 1}, 30, [[5, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 1, Technology.DEFENSE: 1}, 30, [[5, 10]], {Technology.ATTACK: 2, Technology.DEFENSE: 1}, 0);
  });

  test('basegame/remaining_tech_purchase_test.cantBuyTacticsIfHasNoAttackAndDefense', () {
    //CP 15 Not ehnough for ATTACK or DEFENSE, only TACTICS and MINE_SWEEP
    assertRemainingBuys({}, 15, [[1, 1]], {Technology.MINE_SWEEPER: 1}, 5);
    assertRemainingBuys({}, 15, [], {}, 15, [FleetBuildOption.HOME_DEFENSE]);
  });

  test('basegame/remaining_tech_purchase_test.cantBuyCloakingIfSeenScanner2', () {
    game.setSeenLevel(Technology.SCANNER, 2);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[1, 2, 9]], {Technology.ATTACK: 3, Technology.DEFENSE: 2}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[3, 4, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 3}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[5, 9], [1, 2]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.TACTICS: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[6, 9], [1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.SCANNER: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[7, 9]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.FIGHTERS: 1}, 5);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[8, 9], [1, 1]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.POINT_DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[9, 9], [4, 4]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.MINE_SWEEPER: 2}, 5);
  });

  test('basegame/remaining_tech_purchase_test.cantBuyCloakingOrMineSweeper', () {
    game.setSeenLevel(Technology.SCANNER, 2);
    var options = [FleetBuildOption.HOME_DEFENSE];
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 2}, 30, [[8, 8]], {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.POINT_DEFENSE: 1}, 10, options);
  });

}
