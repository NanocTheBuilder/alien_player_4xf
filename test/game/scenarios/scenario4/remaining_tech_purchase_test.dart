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
import 'scenario4_test_base.dart';

void main() {
  //extends Fixture

  setUp(() {
    //Fixture
    setupFixture(newGame());

    setupTechnologyBuyerTestBase();
  });

  tearDown(assertAllRollsUsed);

  //  1-16 SHIP_SIZE 16
  // 17-36 ATTACK 20
  // 37-56 DEFENSE 20
  // 57-68 TACTICS 12
  // 69-71 CLOAKING 3
  // 72-73 SCANNER 2
  // 74-81 FIGHTERS 8
  // 82-84 POINT_DEFENSE 3
  // 85-89 MINE_SWEEPER 5
  // 90-92 SECURITY_FORCES 3
  // 93-96 MILITARY_ACADEMY 4
  // 97-100 BOARDING 4

  //10 CP: MINE SWEEPER 1, MILITARY ACADEMY 1 (9)
  //15 CP: TACTICS 1 2 3, SECURTY FORCES 1 2  (15)
  //20 CP: SHIP_SIZE 4, SCANNER 1, POINT_DEFENSE 1, BOARDING 1 (25)

  //DONE Do not buy Tactics before buying Attack 2 and Defense 2. 
  //TODO If buying Attack or Defense but AP cannot equip next level based on Ship Size tech, instead purchase the next level of Ship Size, if able.
  //DONE Reroll Cloaking if AP has seen enemy Scanner 2.

  test('scenario4/remaining_tech_purchase_test.allTechAvailable', () {
    var startingTechs = {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.SHIP_SIZE: 3};
    assertRemainingBuys(startingTechs, 30, [[1, 16, 100], [1, 9]], {Technology.SHIP_SIZE: 4, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[17, 36, 100]], {Technology.ATTACK: 3}, 5);
    assertRemainingBuys(startingTechs, 30, [[37, 56, 100]], {Technology.DEFENSE: 3}, 5);
    assertRemainingBuys(startingTechs, 30, [[57, 68, 100], [1, 24]], {Technology.TACTICS: 2}, 0);
    assertRemainingBuys(startingTechs, 30, [[69, 71, 100]], {Technology.CLOAKING: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[72, 73, 100], [1, 9]], {Technology.SCANNER: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[74, 81, 100]], {Technology.FIGHTERS: 1}, 5);
    assertRemainingBuys(startingTechs, 30, [[82, 84, 100], [1, 9]], {Technology.POINT_DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[85, 89, 100], [1, 49]], {Technology.MINE_SWEEPER: 1, Technology.SHIP_SIZE: 4}, 0);
    assertRemainingBuys(startingTechs, 30, [[90, 92, 100], [1, 24]], {Technology.SECURITY_FORCES: 1, Technology.TACTICS: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[93, 96, 100], [1, 49]], {Technology.MILITARY_ACADEMY: 1, Technology.SHIP_SIZE: 4}, 0);
    assertRemainingBuys(startingTechs, 30, [[97, 100, 100], [1, 9]], {Technology.BOARDING: 1, Technology.MINE_SWEEPER: 1}, 0);
  });

  test('scenario4/remaining_tech_purchase_test.buyAttackOrDefenseInsteadOfTactics', () {
    assertRemainingBuys({Technology.ATTACK: 0, Technology.DEFENSE: 2, Technology.SHIP_SIZE: 3}, 30, [[57, 68, 100], [1, 9]], {Technology.ATTACK: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 1, Technology.DEFENSE: 2, Technology.SHIP_SIZE: 3}, 30, [[57, 68, 100]], {Technology.ATTACK: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 0, Technology.SHIP_SIZE: 3}, 30, [[57, 68, 100], [1, 9]], {Technology.DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys({Technology.ATTACK: 2, Technology.DEFENSE: 1, Technology.SHIP_SIZE: 3}, 30, [[57, 68, 100]], {Technology.DEFENSE: 2}, 0);
    assertRemainingBuys({Technology.ATTACK: 1, Technology.DEFENSE: 1, Technology.SHIP_SIZE: 3}, 30, [[57, 68, 100]], {Technology.ATTACK: 2}, 0);
  });

  test('scenario4/remaining_tech_purchase_test.cantBuyTacticsIfHasNoAttackAndDefense', () {
    //CP 15 Not ehnough for ATTACK or DEFENSE, only TACTICS, MINE_SWEEP, SECURITY FORCES and MILITARY ACADEMY
    assertRemainingBuys({Technology.SHIP_SIZE: 3}, 15, [[1, 12]], {Technology.MINE_SWEEPER: 1}, 5);
  });

  test('scenario4/remaining_tech_purchase_test.cantBuyCloakingIfSeenScanner2', () {
    var startingTechs = {Technology.ATTACK: 2, Technology.DEFENSE: 2, Technology.SHIP_SIZE: 3};
    game.setSeenLevel(Technology.SCANNER, 2);
    assertRemainingBuys(startingTechs, 30, [[1, 16, 97], [1, 9]], {Technology.SHIP_SIZE: 4, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[17, 36, 97]], {Technology.ATTACK: 3}, 5);
    assertRemainingBuys(startingTechs, 30, [[37, 56, 97]], {Technology.DEFENSE: 3}, 5);
    assertRemainingBuys(startingTechs, 30, [[57, 68, 97], [1, 24]], {Technology.TACTICS: 2}, 0);
    assertRemainingBuys(startingTechs, 30, [[69, 70, 97], [1, 9]], {Technology.SCANNER: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[71, 78, 97]], {Technology.FIGHTERS: 1}, 5);
    assertRemainingBuys(startingTechs, 30, [[79, 81, 97], [1, 9]], {Technology.POINT_DEFENSE: 1, Technology.MINE_SWEEPER: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[82, 86, 97], [1, 49]], {Technology.MINE_SWEEPER: 1, Technology.SHIP_SIZE: 4}, 0);
    assertRemainingBuys(startingTechs, 30, [[87, 89, 97], [1, 24]], {Technology.SECURITY_FORCES: 1, Technology.TACTICS: 1}, 0);
    assertRemainingBuys(startingTechs, 30, [[90, 93, 97], [1, 49]], {Technology.MILITARY_ACADEMY: 1, Technology.SHIP_SIZE: 4}, 0);
    assertRemainingBuys(startingTechs, 30, [[94, 97, 97], [1, 9]], {Technology.BOARDING: 1, Technology.MINE_SWEEPER: 1}, 0);
  });  
}