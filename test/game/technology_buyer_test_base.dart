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

import 'package:collection/collection.dart';

import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:test/test.dart';

import 'fixture.dart';

late Fleet fleet;

//setUp
void setupTechnologyBuyerTestBase() {
  for (Technology t in game.scenario.availableTechs) {
    assertLevel(t, game.scenario.getStartingLevel(t));
  }
  fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, -1);
}

void assertOptionalBuy(
  Technology technology,
  int newLevel,
  int remainingCP,
  Function(AlienPlayer) buyAction, {
  int initialCP = 100,
}) {
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
  if (rollNeeded != -1) {
    roller.mockRoll("Ship size", rollNeeded + 1);
    assertDontBuyShipSize(newLevel);
    roller.mockRoll("Ship size", rollNeeded);
  }
  assertBuyOptional(newLevel, Technology.SHIP_SIZE, (AlienPlayer ap) {
    techBuyer.buyShipSizeIfRolled(ap);
  });
}

  void assertAvailableTechs(
    List<({Technology technology, int startingLevel, int maxLevel})>
    expectedTechs,
  ) {
    ap.economicSheet.techCP = 1000;
    for (var technology in Technology.values) {
      var expected = expectedTechs.firstWhereOrNull(
        (e) => e.technology == technology,
      );
//      print("Checking technology ${technology.name}");
      if (expected == null) {
        //Should not be available
        try {
          techBuyer.apCanBuyNextLevel(ap, technology);
          fail(
            "Technology ${technology.name} should not be available for purchase!",
          );
        } on TypeError catch (e) {
          if(e.toString() == "Null check operator used on a null value") {
            //Expected
//            print("Not available, as expected.");
          } else {
            rethrow;
          };
        }
      } else {
        expect(
          game.scenario.getStartingLevel(technology),
          expected.startingLevel,
        );
        expect(game.scenario.getMaxLevel(technology), expected.maxLevel);
      }
    }
  }

