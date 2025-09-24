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

  void buyTech() {
    techBuyer.spendRemainingTechCP(ap, fleet);
  }

  void doBuy(Technology technology, int techonogyLevel, Map<Technology, int> expectedLevels) {
    buyTech();
    assertLevels(expectedLevels);
  }

  void assertBuy(Technology technology, int techonogyLevel, int roll, int bound, Map<Technology, int> expectedLevels) {
    roller.mockRoll("Tech roll", roll, bound: bound);
    doBuy(technology, techonogyLevel, expectedLevels);
  }

  void assertBuysNextRemaining(
    Technology technology,
    int currentLevel,
    int rollNeeded,
    int bound, [
    Map<Technology, int> expectedLevels = const {},
  ]) {
    ap.setLevel(technology, currentLevel);
    int nextLevel = currentLevel + 1;
    sheet.techCP = game.scenario.getCost(technology, nextLevel);
    assertBuy(technology, nextLevel, rollNeeded, bound, {technology: nextLevel, ...expectedLevels});
    expect(sheet.techCP, 0);
  }

  test('basegame/remaining_tech_purchase_test.assertAvailableTechs', () {
    assertAvailableTechs([
      (technology: Technology.MOVE, startingLevel: 1, maxLevel: 7),
      (technology: Technology.SHIP_SIZE, startingLevel: 1, maxLevel: 6),
      (technology: Technology.ATTACK, startingLevel: 0, maxLevel: 3),
      (technology: Technology.DEFENSE, startingLevel: 0, maxLevel: 3),
      (technology: Technology.TACTICS, startingLevel: 0, maxLevel: 3),
      (technology: Technology.CLOAKING, startingLevel: 0, maxLevel: 2),
      (technology: Technology.SCANNER, startingLevel: 0, maxLevel: 2),
      (technology: Technology.FIGHTERS, startingLevel: 0, maxLevel: 3),
      (technology: Technology.POINT_DEFENSE, startingLevel: 0, maxLevel: 3),
      (technology: Technology.MINE_SWEEPER, startingLevel: 0, maxLevel: 2),
    ]);
  });

  test('basegame/remaining_tech_purchase_test.buyAttack', () {
    assertBuysNextRemaining(Technology.ATTACK, 0, 2, 8);
    assertBuysNextRemaining(Technology.ATTACK, 1, 2, 10);
    assertBuysNextRemaining(Technology.ATTACK, 2, 2, 9);
  });

  test('basegame/remaining_tech_purchase_test.buyDefense', () {
    assertBuysNextRemaining(Technology.DEFENSE, 0, 4, 8);
    assertBuysNextRemaining(Technology.DEFENSE, 1, 4, 10);
    assertBuysNextRemaining(Technology.DEFENSE, 2, 4, 9);
  });

  test('basegame/remaining_tech_purchase_test.buyTacticsOrAttackOrDefense', () {
    ap.setLevel(Technology.ATTACK, 1);
    ap.setLevel(Technology.DEFENSE, 1);

    sheet.techCP = game.scenario.getCost(Technology.ATTACK, 2);
    roller.mockRoll("Tech roll", 5); //Tactics
    buyTech();
    expect(ap.getLevel(Technology.ATTACK), 2);
    expect(ap.getLevel(Technology.TACTICS), 0);

    sheet.techCP = game.scenario.getCost(Technology.DEFENSE, 2);
    roller.mockRoll("Tech roll", 5);
    buyTech();
    expect(ap.getLevel(Technology.DEFENSE), 2);
    expect(ap.getLevel(Technology.TACTICS), 0);

    sheet.techCP = game.scenario.getCost(Technology.TACTICS, 1);
    roller.mockRoll("Tech roll", 1, bound: 2); //TACTICS & MINE SWEEPER (for 15)
    buyTech();
    expect(ap.getLevel(Technology.TACTICS), 1);

    ap.setLevel(Technology.ATTACK, 1);
    ap.setLevel(Technology.DEFENSE, 0);
    ap.setLevel(Technology.TACTICS, 0);
    sheet.techCP = game.scenario.getCost(Technology.DEFENSE, 1);
    roller.mockRoll("Tech roll", 3, bound: 6); //ATTACK FIGHTERS AND CLOAK IS NOT BUYABLE
    buyTech();
    expect(ap.getLevel(Technology.ATTACK), 1);
    expect(ap.getLevel(Technology.DEFENSE), 1);
    expect(ap.getLevel(Technology.TACTICS), 0);

    ap.setLevel(Technology.ATTACK, 0);
    ap.setLevel(Technology.DEFENSE, 1);
    ap.setLevel(Technology.TACTICS, 0);
    sheet.techCP = game.scenario.getCost(Technology.ATTACK, 1);
    roller.mockRoll("Tech roll", 3, bound: 6); //DEFENSE FIGHTERS AND CLOAK IS NOT BUYABLE
    buyTech();
    expect(ap.getLevel(Technology.ATTACK), 1);
    expect(ap.getLevel(Technology.DEFENSE), 1);
    expect(ap.getLevel(Technology.TACTICS), 0);
  });

  test('basegame/remaining_tech_purchase_test.cantBuyTacticsIfHasNoAttackAndDefense', () {
    sheet.techCP = 15; //Not ehnough for ATTACK or DEFENSE, only TACTICS
    ap.setLevel(Technology.ATTACK, 0);
    ap.setLevel(Technology.DEFENSE, 0);
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.TACTICS), false);

    ap.setLevel(Technology.ATTACK, 2);
    ap.setLevel(Technology.DEFENSE, 0);
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.TACTICS), false);

    ap.setLevel(Technology.ATTACK, 0);
    ap.setLevel(Technology.DEFENSE, 2);
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.TACTICS), false);

    ap.setLevel(Technology.ATTACK, 2);
    ap.setLevel(Technology.DEFENSE, 2);
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.TACTICS), true);

    ap.setLevel(Technology.ATTACK, 1);
    ap.setLevel(Technology.DEFENSE, 0);
    sheet.techCP = game.scenario.getCost(Technology.DEFENSE, 1);
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.TACTICS), true);
  });

  test('basegame/remaining_tech_purchase_test.buyTactics', () {
    ap.setLevel(Technology.ATTACK, 2);
    ap.setLevel(Technology.DEFENSE, 2);
    assertBuysNextRemaining(Technology.TACTICS, 0, 1, 2, {Technology.ATTACK: 2, Technology.DEFENSE: 2});
    assertBuysNextRemaining(Technology.TACTICS, 1, 1, 2, {Technology.ATTACK: 2, Technology.DEFENSE: 2});
    assertBuysNextRemaining(Technology.TACTICS, 2, 1, 2, {Technology.ATTACK: 2, Technology.DEFENSE: 2});
  });

  test('basegame/remaining_tech_purchase_test.buyCloaking', () {
    assertBuysNextRemaining(Technology.CLOAKING, 0, 6, 10);
    assertBuysNextRemaining(Technology.CLOAKING, 1, 6, 10);
  });

  test('basegame/remaining_tech_purchase_test.cantBuyCloakingIfSeenScanner2', () {
    game.setSeenLevel(Technology.SCANNER, 2);
    sheet.techCP = 100;
    expect(techBuyer.apCanBuyNextLevel(ap, Technology.CLOAKING), false);
  });

  test('basegame/remaining_tech_purchase_test.buyScanner', () {
    assertBuysNextRemaining(Technology.SCANNER, 0, 6, 8); //CLOAK AND FIGHTERS ARE TOO EXPENSIVE
    assertBuysNextRemaining(Technology.SCANNER, 1, 6, 8);
  });

  test('basegame/remaining_tech_purchase_test.buyFighters', () {
    assertBuysNextRemaining(Technology.FIGHTERS, 0, 7, 9); //CLOAK IS TOO EXPENSIVE
    assertBuysNextRemaining(Technology.FIGHTERS, 1, 7, 9);
    assertBuysNextRemaining(Technology.FIGHTERS, 2, 7, 9);
  });

  test('basegame/remaining_tech_purchase_test.buyPointDefense', () {
      assertBuysNextRemaining(Technology.POINT_DEFENSE, 0, 7, 8); //FIGHTER AND CLOAK ARE TOO EXPENSIVE
      assertBuysNextRemaining(Technology.POINT_DEFENSE, 1, 7, 8);
      assertBuysNextRemaining(Technology.POINT_DEFENSE, 2, 7, 8);
  });

  test('basegame/remaining_tech_purchase_test.buyMineSweep', () {
      assertBuysNextRemaining(Technology.MINE_SWEEPER, 0, 1, 1); //EVERYTHING ELSE IS TOO EXPENSIVE
      assertBuysNextRemaining(Technology.MINE_SWEEPER, 1, 1, 1);
  });

  test('basegame/remaining_tech_purchase_test.dontBuyMineSweepForDefenseFleet', () {
      sheet.techCP = 100;
      expect(techBuyer.fleetCanBuyNextLevel(ap, fleet, Technology.MINE_SWEEPER), true);
      expect(techBuyer.fleetCanBuyNextLevel(ap, fleet, Technology.MINE_SWEEPER, [FleetBuildOption.HOME_DEFENSE]), false);
  });
}
