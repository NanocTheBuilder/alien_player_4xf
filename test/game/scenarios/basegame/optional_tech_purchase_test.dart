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

import 'package:alienplayer4xf/game/alien_player.dart';
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

  //TODO tests what happens if CP is not enough

  //Space_Empires_Scenarios_1.2.pdf page 10

  //"Alien Players automatically start with Mine Technology"
  // MINES are not used in the app, they are supposed to be there
  // TODO: show it on the app

  // Whenever a fleet is launched, roll for Movement Technology. On
  // a roll of 1-4, the AP will purchase the next Movement Technology available if it has enough CPs

  //• All available technology points will be spent in the following order: (Integration test at the end)

  //• If the human player has used Fighters in combat and the AP does not have Point Defense 1, it will purchase Point Defense 1.

  test('basegame/optional_tech_purchase_test.buyOptionalPointDefense', () {
    assertDontBuyOptional(1, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
    game.addSeenThing(Seeable.FIGHTERS);
    assertBuyOptional(1, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
    assertDontBuyOptional(2, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
  });

  //• Next, if the human player has shown Mines, and the AP does not have Minesweeper 1, the AP will purchase MS 1.

  test('basegame/optional_tech_purchase_test.buyOptionalMineSweep', () {
    assertDontBuyOptional(1, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
    game.addSeenThing(Seeable.MINES);
    assertBuyOptional(1, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
    assertDontBuyOptional(2, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
  });

  //• Next, if the human player has used Raiders in combat, and the AP does not have a Scan level capable of detecting those Raiders, roll the die.
  // On a roll of 1-4 the AP will purchase Scanners to be able to detect the Raiders.
  // If the AP would need to purchase two levels of Scanning Technology, and it can only afford one,it will purchase one in an effort to work toward that goal.
  // On a roll of 5-10, the AP will not purchase Scanners at this point in his expenditures.
  test('basegame/optional_tech_purchase_test.buyOptionalScan', () {
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 4);
    assertBuyOptional(1, Technology.SCANNER, (AlienPlayer ap) => techBuyer.buyScannerIfNeeded(ap));
    assertDontBuyOptional(2, Technology.SCANNER, (AlienPlayer ap) => techBuyer.buyScannerIfNeeded(ap));

    game.setSeenLevel(Technology.CLOAKING, 2);
    roller.mockRoll("Scanner", 5);
    assertDontBuyOptional(2, Technology.SCANNER, (AlienPlayer ap) => techBuyer.buyScannerIfNeeded(ap));

    roller.mockRoll("Scanner", 4);
    assertBuyOptional(2, Technology.SCANNER, (AlienPlayer ap) => techBuyer.buyScannerIfNeeded(ap));

    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SCANNER, 0);
    roller.mockRoll("Scanner", 4);
    assertOptionalBuy(Technology.SCANNER, 1, 10, (AlienPlayer ap) => techBuyer.buyScannerIfNeeded(ap), initialCP: 30);
  });

  //• Next the AP will determine if it will spend on ship size. This depends on its current ship size level.
  // Only roll once on this table regardless of how many tech points the AP has to spend.
  // Current Ship Size:                   1    2   3   4   5
  // Roll needed to purchase next level: 1-10 1-7 1-6 1-5 1-3

  test('basegame/optional_tech_purchase_test.buyOptionalShipSize', () {
       roller.mockRoll("Ship size", 10);
       assertBuyShipSize(2);
       assertBuyShipSize(3, rollNeeded: 7);
       assertBuyShipSize(4, rollNeeded: 6);
       assertBuyShipSize(5, rollNeeded: 5);
       assertBuyShipSize(6, rollNeeded: 3);
       assertDontBuyShipSize(7);
   });

  //• If the AP has researched Fighter Technology and the human player has not shown Point Defense, then the AP will first buy
  // the next level of Fighter Technology if it has the tech points to make the purchase on a roll of 1-6.
  // On a roll of 7-10 the AP will proceed to the chart below.

  test('basegame/optional_tech_purchase_test.buyOptionalFighterLevel',() {
      game.setSeenLevel(Technology.POINT_DEFENSE, 0);
      assertDontBuyOptional(1, Technology.FIGHTERS, (AlienPlayer ap) => techBuyer.buyFightersIfNeeded(ap));

      ap.setLevel(Technology.FIGHTERS, 1);
      roller.mockRoll("Fighters", 6);
      assertBuyOptional(2, Technology.FIGHTERS, (AlienPlayer ap) => techBuyer.buyFightersIfNeeded(ap));

      game.setSeenLevel(Technology.POINT_DEFENSE, 1);
      assertDontBuyOptional(3, Technology.FIGHTERS, (AlienPlayer ap) => techBuyer.buyFightersIfNeeded(ap));

      game.setSeenLevel(Technology.POINT_DEFENSE, 0);
      roller.mockRoll("Fighters", 7);
      assertDontBuyOptional(3, Technology.FIGHTERS, (AlienPlayer ap) => techBuyer.buyFightersIfNeeded(ap));

      roller.mockRoll("Fighters", 6);
      assertBuyOptional(3, Technology.FIGHTERS, (AlienPlayer ap) => techBuyer.buyFightersIfNeeded(ap));
  });

  //• If this is a Raider Fleet with Cloak 1 the AP will first buy Cloak 2 on a roll of 1-6 if it has the tech points to make the purchase.
  // On a roll of 7-10 the AP will proceed to the chart below.

  test('basegame/optional_tech_purchase_test.buyOptionalCloak', () {

       fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
       ap.setLevel(Technology.CLOAKING, 1);
       roller.mockRoll("Cloaking", 7);
       assertDontBuyOptional(2, Technology.CLOAKING, (AlienPlayer ap) => techBuyer.buyCloakingIfNeeded(ap, fleet));

       roller.mockRoll("Cloaking", 6);
       assertBuyOptional(2, Technology.CLOAKING, (AlienPlayer ap) => techBuyer.buyCloakingIfNeeded(ap, fleet));

       fleet.setFleetType(ap, FleetType.REGULAR_FLEET);
       ap.setLevel(Technology.CLOAKING, 1);
       assertDontBuyOptional(2, Technology.CLOAKING, (AlienPlayer ap) => techBuyer.buyCloakingIfNeeded(ap, fleet));
   });


  //Integration test

  /*
• If the human player has used Fighters in combat and the AP does not have Point Defense 1, it will purchase Point Defense 1.
• Next, if the human player has shown Mines, and the AP does not have Minesweeper 1, the AP will purchase MS 1.
• Next, if the human player has used Raiders in combat, and the AP does not have a Scan level capable of detecting those Raiders, roll the die.
  On a roll of 1-4 the AP will purchase Scanners to be able to detect the Raiders. If the AP would need to purchase two levels of Scanning Technology,
  and it can only afford one, it will purchase one in an effort to work toward that goal. On a roll of 5-10, the AP will not purchase Scanners at this point
• Next the AP will determine if it will spend on ship size. This depends on its current ship size level. Only roll once on this table
• If the AP has researched Fighter Technology and the human player has not shown Point Defense, then the AP will buy the next level of Fighter Technology on a roll of 1-6.
• If this is a Raider Fleet with Cloak 1 the AP will first buy Cloak 2 on a roll of 1-6 if it has the tech points to make the purchase.
  */
  test('basegame/optional_tech_purchase_test.buyPointDefenseFirst', () {
    sheet.techCP = 30;
    game.addSeenThing(Seeable.FIGHTERS);
    game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    roller.mockRoll("Ship size", 1);
    roller.mockRoll("Fighters", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.POINT_DEFENSE: 1, Technology.MINE_SWEEPER: 1, Technology.SHIP_SIZE: 3, Technology.FIGHTERS: 1, Technology.CLOAKING: 1});
    expect(sheet.techCP, 0);
  });

  test('basegame/optional_tech_purchase_test.buyMineSweepSecond', () {
    sheet.techCP = 20;
    //game.addSeenThing(Seeable.FIGHTERS);
    game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    roller.mockRoll("Ship size", 1);
    roller.mockRoll("Fighters", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.MINE_SWEEPER: 1, Technology.SHIP_SIZE: 3, Technology.FIGHTERS: 1, Technology.CLOAKING: 1});
    expect(sheet.techCP, 10);
  });

  test('basegame/optional_tech_purchase_test.buyScannerThird', () {
    sheet.techCP = 40;
    //game.addSeenThing(Seeable.FIGHTERS);
    //game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    roller.mockRoll("Ship size", 1);
    roller.mockRoll("Fighters", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.SCANNER: 2, Technology.SHIP_SIZE: 3, Technology.FIGHTERS: 1, Technology.CLOAKING: 1});
    expect(sheet.techCP, 0); //Scanner 1 + Scanner 2
  });

  test('basegame/optional_tech_purchase_test.buyShipSizeFourth', () {
    sheet.techCP = 40;
    //game.addSeenThing(Seeable.FIGHTERS);
    //game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 10);
    roller.mockRoll("Ship size", 1);
    roller.mockRoll("Fighters", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.SHIP_SIZE: 4, Technology.FIGHTERS: 1, Technology.CLOAKING: 1});
    expect(sheet.techCP, 20); //Ship size 4
  });

  test('basegame/optional_tech_purchase_test.buyFightersFifth', () {
    sheet.techCP = 45;
    //game.addSeenThing(Seeable.FIGHTERS);
    //game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 10);
    roller.mockRoll("Ship size", 10);
    roller.mockRoll("Fighters", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.SHIP_SIZE: 3, Technology.FIGHTERS: 2, Technology.CLOAKING: 1});
    expect(sheet.techCP, 20); //Fighters 2
  });

  test('basegame/optional_tech_purchase_test.buyCloakingLast', () {
    sheet.techCP = 50;
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    //game.addSeenThing(Seeable.FIGHTERS);
    //game.addSeenThing(Seeable.MINES);
    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SHIP_SIZE, 3);
    ap.setLevel(Technology.FIGHTERS, 1);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 10);
    roller.mockRoll("Ship size", 10);
    roller.mockRoll("Fighters", 10);
    roller.mockRoll("Cloaking", 1);
    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({Technology.SHIP_SIZE: 3, Technology.FIGHTERS: 1, Technology.CLOAKING: 2});
    expect(sheet.techCP, 20); //Cloaking 2
  });
}
