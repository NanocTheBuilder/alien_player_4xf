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
import 'scenario4_test_base.dart';

void main() {
  setUp(() {
    //Fixture
    setupFixture(newGame());

    setupTechnologyBuyerTestBase();
  });

  tearDown(assertAllRollsUsed);

  // Starts the same as the base game

  //Has seen enemy Fighters -> Lacks Point Def 1 -> Buys Point Def 1
  test('scenario4/optional_tech_purchase_test.buyOptionalPointDefense', () {
    assertDontBuyOptional(1, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
    game.addSeenThing(Seeable.FIGHTERS);
    assertBuyOptional(1, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
    assertDontBuyOptional(2, Technology.POINT_DEFENSE, (AlienPlayer ap) => techBuyer.buyPointDefenseIfNeeded(ap));
  });

  //Has seen enemy Mines -> Lacks Mine Sweeper 1 -> Buys Mine Sweeper 1
  test('basegame/optional_tech_purchase_test.buyOptionalMineSweep', () {
    assertDontBuyOptional(1, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
    game.addSeenThing(Seeable.MINES);
    assertBuyOptional(1, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
    assertDontBuyOptional(2, Technology.MINE_SWEEPER, (AlienPlayer ap) => techBuyer.buyMineSweepIfNeeded(ap));
  });

  //Has seen enemy BDs -> Lacks Security Forces 1 -> Buys Security Forces 1
  test('basegame/optional_tech_purchase_test.buyOptionalSecurityForces', () {
    assertDontBuyOptional(1, Technology.SECURITY_FORCES, (AlienPlayer ap) => techBuyer.buySecurityIfNeeded(ap));
    game.addSeenThing(Seeable.BOARDING_SHIPS);
    assertBuyOptional(1, Technology.SECURITY_FORCES, (AlienPlayer ap) => techBuyer.buySecurityIfNeeded(ap));
    assertDontBuyOptional(2, Technology.SECURITY_FORCES, (AlienPlayer ap) => techBuyer.buySecurityIfNeeded(ap));
  });

  //Combat is above a planet -> Buys next level of Ground Combat
  //Only buys Ground Combat 3 if has seen an enemy with Ground Combat 2.
  test('scenario4/optional_tech_purchase_test.buyOptionalGroundCombat', () {
    assertDontBuyOptional(
      2,
      Technology.GROUND_COMBAT,
      (AlienPlayer ap) => techBuyer.buyGroundCombatIfNeeded(ap, combatIsAbovePlanet: false),
    );
    assertBuyOptional(
      2,
      Technology.GROUND_COMBAT,
      (AlienPlayer ap) => techBuyer.buyGroundCombatIfNeeded(ap, combatIsAbovePlanet: true),
    );
    assertDontBuyOptional(
      3,
      Technology.GROUND_COMBAT,
      (AlienPlayer ap) => techBuyer.buyGroundCombatIfNeeded(ap, combatIsAbovePlanet: true),
    );
    game.setSeenLevel(Technology.GROUND_COMBAT, 2);
    assertBuyOptional(
      3,
      Technology.GROUND_COMBAT,
      (AlienPlayer ap) => techBuyer.buyGroundCombatIfNeeded(ap, combatIsAbovePlanet: true),
    );
    assertDontBuyOptional(
      4,
      Technology.GROUND_COMBAT,
      (AlienPlayer ap) => techBuyer.buyGroundCombatIfNeeded(ap, combatIsAbovePlanet: true),
    );
  });
  //TODO test starting levels?

  //Has seen Veteran or greater enemy ships
  //On a roll of 1-6 Buys next level of Military Academy
  test('scenario4/optional_tech_purchase_test.buyOptionalMilitaryAcademy', () {
    assertDontBuyOptional(1, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));

    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 7);
    assertDontBuyOptional(1, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));
    roller.mockRoll("Military Academy", 6);
    assertBuyOptional(1, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));

    roller.mockRoll("Military Academy", 7);
    assertDontBuyOptional(2, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));
    roller.mockRoll("Military Academy", 6);
    assertBuyOptional(2, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));

    roller.mockRoll("Military Academy", 6);
    assertDontBuyOptional(3, Technology.MILITARY_ACADEMY, (AlienPlayer ap) => techBuyer.buyMilitaryAcademyIfNeeded(ap));
  });

  //Has seen enemy Raiders -> Lacks Scan capable of detecting them -> On a roll of 1-4 Buys required Scanner level(s)
  test('scenario4/optional_tech_purchase_test.buyOptionalScan', () {
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

  //Has seen enemy with Ships Size tech > 3 (excludes NPAs) -> on a roll of 1-4 Buys Boarding 1
  test('scenario4/optional_tech_purchase_test.buyOptionalBoarding', () {
    assertDontBuyOptional(1, Technology.BOARDING, (AlienPlayer ap) => techBuyer.buyBoardingIfNeeded(ap));
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 5);
    assertDontBuyOptional(1, Technology.BOARDING, (AlienPlayer ap) => techBuyer.buyBoardingIfNeeded(ap));
    roller.mockRoll("Boarding", 4);
    assertBuyOptional(1, Technology.BOARDING, (AlienPlayer ap) => techBuyer.buyBoardingIfNeeded(ap));

    assertDontBuyOptional(2, Technology.BOARDING, (AlienPlayer ap) => techBuyer.buyBoardingIfNeeded(ap));
  });

  //Roll die for Ship Size tech
  test('scenario4/optional_tech_purchase_test.buyOptionalShipSize', () {
    roller.mockRoll("Ship size", 10);
    assertBuyShipSize(2);

    assertBuyShipSize(3, rollNeeded: 7);
    assertBuyShipSize(4, rollNeeded: 6);
    assertBuyShipSize(5, rollNeeded: 5);
    assertBuyShipSize(6, rollNeeded: 3);
    assertBuyShipSize(7, rollNeeded: 6);

    assertDontBuyShipSize(8);
  });

  //AP has Fighter tech -> Has not seen enemy Point Def -> On a roll of 1-6 Buys next Fighter level
  test('scenario4/optional_tech_purchase_test.buyOptionalFighterLevel', () {
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

  //This fleet is a Raider fleet -> AP has Cloak 1 -> On a roll of 1-6 Buys Cloak 2
  test('scenario4/optional_tech_purchase_test.buyOptionalCloaking', () {
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

  //Tests to assert the order of optional tech purchases
  // 1. Point Defense
  // 2. Mine Sweeper
  // 3. Security Forces
  // 4. Ground Combat
  // 5. Military Academy
  // 6. Scanner
  // 7. Boarding
  // 8. Ship Size
  // 9. Fighters
  // 10. Cloaking

  test('scenario4/optional_tech_purchase_test.buyPointDefenseFirst', () {
    sheet.techCP = 50;
    game.addSeenThing(Seeable.FIGHTERS);
    game.addSeenThing(Seeable.MINES);
    game.addSeenThing(Seeable.BOARDING_SHIPS);
    var options = [FleetBuildOption.COMBAT_IS_ABOVE_PLANET];
    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 1);
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet, options);
    assertLevels({
      Technology.POINT_DEFENSE: 1,
      Technology.MINE_SWEEPER: 1,
      Technology.SECURITY_FORCES: 1,
      Technology.SHIP_SIZE: 1,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 5);
  });


  test('scenario4/optional_tech_purchase_test.buyMineSweeperSecond', () {
    sheet.techCP = 50;
    game.addSeenThing(Seeable.MINES);
    game.addSeenThing(Seeable.BOARDING_SHIPS);
    var options = [FleetBuildOption.COMBAT_IS_ABOVE_PLANET];
    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 1);
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet, options);
    assertLevels({
      Technology.MINE_SWEEPER: 1,
      Technology.SECURITY_FORCES: 1,
      Technology.GROUND_COMBAT: 2,
      Technology.MILITARY_ACADEMY: 1,
      Technology.SHIP_SIZE: 1,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 5);
  });

  test('scenario4/optional_tech_purchase_test.buySecurityForcesThird', () {
    sheet.techCP = 50;
    game.addSeenThing(Seeable.BOARDING_SHIPS);
    var options = [FleetBuildOption.COMBAT_IS_ABOVE_PLANET];
    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 1);
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet, options);
    assertLevels({
      Technology.SECURITY_FORCES: 1,
      Technology.GROUND_COMBAT: 2,
      Technology.MILITARY_ACADEMY: 1,
      Technology.SHIP_SIZE: 2,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 5);
  });

  test('scenario4/optional_tech_purchase_test.buyGroundCombatFourth', () {
    sheet.techCP = 50;
    var options = [FleetBuildOption.COMBAT_IS_ABOVE_PLANET];
    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 1);
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet, options);
    assertLevels({
      Technology.GROUND_COMBAT: 2,
      Technology.MILITARY_ACADEMY: 1,
      Technology.SCANNER: 1,
      Technology.SHIP_SIZE: 2,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 0);
  });

  test('scenario4/optional_tech_purchase_test.buyMilitaryAcademy5th', () {
    sheet.techCP = 50;
    game.addSeenThing(Seeable.VETERANS);
    roller.mockRoll("Military Academy", 1);
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.MILITARY_ACADEMY: 1,
      Technology.SCANNER: 1,
      Technology.BOARDING: 1,
      Technology.SHIP_SIZE: 1,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 0);
  });

  test('scenario4/optional_tech_purchase_test.buyScanner6th', () {
    sheet.techCP = 50;
    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Scanner", 1);
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.SCANNER: 1,
      Technology.BOARDING: 1,
      Technology.SHIP_SIZE: 2,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 0);
  });  

  test('scenario4/optional_tech_purchase_test.buyBoarding7th', () {
    sheet.techCP = 50;
    game.addSeenThing(Seeable.SIZE_3_SHIPS);
    roller.mockRoll("Boarding", 1);
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.BOARDING: 1,
      Technology.SHIP_SIZE: 2,
      Technology.FIGHTERS: 1,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 20);
  });

  test('scenario4/optional_tech_purchase_test.buyShipSize8th', () {
    sheet.techCP = 50;
    ap.setLevel(Technology.SHIP_SIZE, 1);
    roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.SHIP_SIZE: 2,
      Technology.FIGHTERS: 2,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 15);
  });

  test('scenario4/optional_tech_purchase_test.buyFighters10th', () {
    sheet.techCP = 50;
    ap.setLevel(Technology.SHIP_SIZE, 7);
    //roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 1);
    roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.SHIP_SIZE: 7,
      Technology.FIGHTERS: 2,
      Technology.CLOAKING: 1,
    });
    expect(sheet.techCP, 25);
  });
  
  test('scenario4/optional_tech_purchase_test.buyCloakingLast', () {
    sheet.techCP = 50;
    ap.setLevel(Technology.SHIP_SIZE, 7);
    //roller.mockRoll("Ship size", 1);
    ap.setLevel(Technology.FIGHTERS, 0);
    //roller.mockRoll("Fighters", 1);
    fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
    ap.setLevel(Technology.CLOAKING, 1);
    roller.mockRoll("Cloaking", 1);

    techBuyer.buyOptionalTechs(ap, fleet);
    assertLevels({
      Technology.SHIP_SIZE: 7,
      Technology.FIGHTERS: 0,
      Technology.CLOAKING: 2,
    });
    expect(sheet.techCP, 20);
  });    
}
