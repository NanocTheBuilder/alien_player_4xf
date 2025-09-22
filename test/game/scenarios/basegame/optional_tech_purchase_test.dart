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
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:alienplayer4xf/game/technology_buyer.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {
  //extends BasegameTechnologyBuyerTestBase
  //extends TechnologyBuyerTestBase
  //extends Fixture

  late Game game;
  late AlienPlayer ap;
  //late DefenseBuilder defBuilder;
  late MockRoller roller;
  late AlienEconomicSheet sheet;
  //late FleetBuilder fleetBuilder;
  late TechnologyBuyer techBuyer;
  //late FleetLauncher fleetLauncher;

  late Fleet fleet;

  void assertLevels(Map<Technology, int> expectedLevels) {
    var errors = [];
    for (var technology in game.scenario.availableTechs) {
      var expectedLevel = expectedLevels[technology] ?? game.scenario.getStartingLevel(technology);
      if(expectedLevel != ap.getLevel(technology)){
        errors.add('$technology: expected $expectedLevel but was ${ap.getLevel(technology)}');
      }
    }
    if(errors.isNotEmpty){
      fail('Level assertions failed:\n${errors.join('\n')}');
    }
  }

  void assertLevel(Technology technology, int expectedLevel) {
    assertLevels({technology: expectedLevel});
  }

  void assertRoller() {
    roller.assertAllUsed();
  }

  setUp(() {
    //Fixture
    game = Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL, [
      PlayerColor.GREEN,
      PlayerColor.YELLOW,
      PlayerColor.RED,
    ]);
    roller = MockRoller();
    game.roller = roller;
    //defBuilder = game.scenario.defenseBuilder;
    //fleetBuilder = game.scenario.fleetBuilder;
    //fleetLauncher = game.scenario.fleetLauncher;
    techBuyer = game.scenario.techBuyer;
    ap = game.aliens[0];
    sheet = ap.economicSheet;

    //TechnologyBuyerTestBase
    for (Technology t in game.scenario.availableTechs) {
      assertLevel(t, game.scenario.getStartingLevel(t));
    }
    fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, -1);
  });

  tearDown(assertRoller);

  void assertOptionalBuy(
    Technology technology,
    int newLevel,
    int remainingCP,
    Function(AlienPlayer) buyAction,
    {int initialCP = 100}
  ) {
    sheet.techCP = initialCP;
    buyAction(ap);
    assertLevel(technology, newLevel);
    expect(sheet.techCP, remainingCP);
  }

  void assertBuyOptional(
    int expectedLevel,
    Technology technology,
    Function(AlienPlayer) buyAction,
  ) {
    assertOptionalBuy(
      technology,
      expectedLevel,
      100 - game.scenario.getCost(technology, expectedLevel),
      buyAction,
    );
  }

  void assertDontBuyOptional(
    int expectedLevel,
    Technology technology,
    Function(AlienPlayer) buyAction,
  ) {
    assertOptionalBuy(technology, expectedLevel - 1, 100, buyAction);
  }

  void assertDontBuyShipSize(int expectedLevel) {
    assertDontBuyOptional(expectedLevel, Technology.SHIP_SIZE, (AlienPlayer ap) {
      techBuyer.buyShipSizeIfRolled(ap);
    });
  }

  void assertBuyShipSize(int newLevel, {int rollNeeded = -1}) {
    if(rollNeeded != -1){
      roller.mockRoll("Ship size", rollNeeded + 1);
      assertDontBuyShipSize(newLevel);
      roller.mockRoll("Ship size", rollNeeded);
    }
    assertBuyOptional(newLevel, Technology.SHIP_SIZE, (AlienPlayer ap) {
      techBuyer.buyShipSizeIfRolled(ap);
    });
  }

  //Tests

  //TODO tests what happens if CP is not enough

  //Space_Empires_Scenarios_1.2.pdf page 10

  //"Alien Players automatically start with Mine Technology"
  // MINES are not used in the app, they are supposed to be there
  // TODO: show it on the app

  // Whenever a fleet is launched, roll for Movement Technology. On
  // a roll of 1-4, the AP will purchase the next Movement Technology available if it has enough CPs
  // TODO convert MovePurchaseTest and add a new case to BaseGameIntegration test

  //• All available technology points will be spent in the following order: (Integration test at the end)

  //• If the human player has used Fighters in combat and the AP does not have Point Defense 1, it will purchase Point Defense 1.

  void assertBuyPD(int expectedLevel) {
    assertBuyOptional(expectedLevel, Technology.POINT_DEFENSE, (
      AlienPlayer ap,
    ) {
      techBuyer.buyPointDefenseIfNeeded(ap);
    });
  }

  void assertDontBuyPD(int expectedLevel) {
    assertDontBuyOptional(expectedLevel, Technology.POINT_DEFENSE, (
      AlienPlayer ap,
    ) {
      techBuyer.buyPointDefenseIfNeeded(ap);
    });
  }

  test('buyOptionalPontDefense', () {
    assertDontBuyPD(1);
    game.addSeenThing(Seeable.FIGHTERS);
    assertBuyPD(1);
    assertDontBuyPD(2);
  });

  //• Next, if the human player has shown Mines, and the AP does not have Minesweeper 1, the AP will purchase MS 1.

  void assertBuyMS(int expectedLevel) {
    assertBuyOptional(expectedLevel, Technology.MINE_SWEEPER, (AlienPlayer ap) {
      techBuyer.buyMineSweepIfNeeded(ap);
    });
  }

  void assertDontBuyMS(int expectedLevel) {
    assertDontBuyOptional(expectedLevel, Technology.MINE_SWEEPER, (
      AlienPlayer ap,
    ) {
      techBuyer.buyMineSweepIfNeeded(ap);
    });
  }

  test('buyOptionalMineSweep', () {
    assertDontBuyMS(1);
    game.addSeenThing(Seeable.MINES);
    assertBuyMS(1);
    assertDontBuyMS(2);
  });

  //• Next, if the human player has used Raiders in combat, and the AP does not have a Scan level capable of detecting those Raiders, roll the die.
  // On a roll of 1-4 the AP will purchase Scanners to be able to detect the Raiders.
  // If the AP would need to purchase two levels of Scanning Technology, and it can only afford one,it will purchase one in an effort to work toward that goal.
  // On a roll of 5-10, the AP will not purchase Scanners at this point in his expenditures.

  void assertBuyScanner(int expectedLevel) {
    assertBuyOptional(expectedLevel, Technology.SCANNER, (AlienPlayer ap) {
      techBuyer.buyScannerIfNeeded(ap);
    });
  }

  void assertDontBuyScanner(int expectedLevel) {
    assertDontBuyOptional(expectedLevel, Technology.SCANNER, (AlienPlayer ap) {
      techBuyer.buyScannerIfNeeded(ap);
    });
  }

  test('buyOptionalScan', () {
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 4);
    assertBuyScanner(1);
    assertDontBuyScanner(2);

    game.setSeenLevel(Technology.CLOAKING, 2);
    roller.mockRoll("Scanner", 5);
    assertDontBuyScanner(2);

    roller.mockRoll("Scanner", 4);
    assertBuyScanner(2);

    game.setSeenLevel(Technology.CLOAKING, 2);
    ap.setLevel(Technology.SCANNER, 0);
    roller.mockRoll("Scanner", 4);
    assertOptionalBuy(Technology.SCANNER, 1, 10, (AlienPlayer ap) {
      techBuyer.buyScannerIfNeeded(ap);
    }, initialCP: 30);
  });

  //• Next the AP will determine if it will spend on ship size. This depends on its current ship size level.
  // Only roll once on this table regardless of how many tech points the AP has to spend.
  // Current Ship Size:                   1    2   3   4   5
  // Roll needed to purchase next level: 1-10 1-7 1-6 1-5 1-3

  test('buyOptionalShipSize', () {
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

  void assertBuyFighters(int expectedLevel) {
      assertBuyOptional(expectedLevel, Technology.FIGHTERS, (AlienPlayer ap) {
          techBuyer.buyFightersIfNeeded(ap);
      });
  }

  void assertDontBuyFighters(int expectedLevel) {
      assertDontBuyOptional(expectedLevel, Technology.FIGHTERS, (AlienPlayer ap) {
          techBuyer.buyFightersIfNeeded(ap);
      });
  }

  test('buyOptionalFighterLevel',() {
      game.setSeenLevel(Technology.POINT_DEFENSE, 0);
      assertDontBuyFighters(1);

      ap.setLevel(Technology.FIGHTERS, 1);
      roller.mockRoll("Fighters", 6);
      assertBuyFighters(2);

      game.setSeenLevel(Technology.POINT_DEFENSE, 1);
      assertDontBuyFighters(3);

      game.setSeenLevel(Technology.POINT_DEFENSE, 0);
      roller.mockRoll("Fighters", 7);
      assertDontBuyFighters(3);

      roller.mockRoll("Fighters", 6);
      assertBuyFighters(3);
  });

  //• If this is a Raider Fleet with Cloak 1 the AP will first buy Cloak 2 on a roll of 1-6 if it has the tech points to make the purchase.
  // On a roll of 7-10 the AP will proceed to the chart below.

  void assertBuyCloaking(int expectedLevel) {
    assertBuyOptional(expectedLevel, Technology.CLOAKING, (AlienPlayer ap) {
      techBuyer.buyCloakingIfNeeded(ap, fleet);
    });
  }

  void assertDontBuyCloaking(int expectedLevel) {
    assertDontBuyOptional(expectedLevel, Technology.CLOAKING, (AlienPlayer ap) {
      techBuyer.buyCloakingIfNeeded(ap, fleet);
    });
  }
  
  test('buyOptionalCloak', () {

       fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
       ap.setLevel(Technology.CLOAKING, 1);
       roller.mockRoll("Cloaking", 7);
       assertDontBuyCloaking(2);

       roller.mockRoll("Cloaking", 6);
       assertBuyCloaking(2);

       fleet.setFleetType(ap, FleetType.REGULAR_FLEET);
       ap.setLevel(Technology.CLOAKING, 1);
       assertDontBuyCloaking(2);
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
  test('buyPointDefenseFirst', () {
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

  test('buyMineSweepSecond', () {
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

  test('buyScannerThird', () {
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

  test('buyShipSizeFourth', () {
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

  test('buyFightersFifth', () {
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

  test('buyCloakingLast', () {
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
