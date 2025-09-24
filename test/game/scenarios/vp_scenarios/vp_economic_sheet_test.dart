/*
 *  Copyright (C) 2021 Balázs Péter
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

import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {
  //@formatter:off
  var resultTable = [
    [[     ], [     ], [      ], [      ]],
    [[     ], [    1], [ 2, 10], [      ]],
    [[     ], [ 1, 3], [ 4, 10], [      ]],
    [[     ], [ 1, 3], [ 4,  8], [ 9, 10]],
    [[     ], [ 1, 4], [ 5,  8], [ 9, 10]],
    [[     ], [ 1, 6], [ 7,  9], [    10]],
    [[     ], [ 1, 4], [ 5,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 5], [ 6,  9], [    10]],
    [[     ], [ 1, 7], [ 8,  9], [    10]],
    [[     ], [ 1, 7], [ 8,  9], [    10]],
    [[     ], [ 1, 7], [ 8,  9], [    10]],
    [[     ], [ 1, 6], [ 7, 10], [      ]],
    [[     ], [ 1, 6], [ 7, 10], [      ]],
    [[     ], [ 1, 7], [ 8, 10], [      ]],
    [[     ], [ 1, 7], [ 8, 10], [      ]],
    [[     ], [ 1, 8], [ 9, 10], [      ]],
    [[     ], [ 1, 8], [ 9, 10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
    [[     ], [ 1, 9], [    10], [      ]],
  ];

  var econRolls = [0, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5];

  var fleetLaunchValues = [0, -99, 10, 10, 5, 10, 4, 10, 4, 5, 6, 4, 6, 3, 10, 3, 10, 3, 10, 3, 10, 3, 10];
  //@formatter:on

  void makeRoll(VpEconomicSheet sheet, int turn, int result) {
    var roller = MockRoller();
    roller.mockRoll("Econ roll",result);
    sheet.makeRoll(turn, roller);
  }

  List getResult(int turn, int index) {
    return resultTable[turn][index];
  }

  test('vp_scenarios/vp_economic_sheet_test.testMaxDefense', (){
    var sheet = new VpEconomicSheet(VpSoloDifficulty.EASY);
    sheet.defCP = 49;
    makeRoll(sheet, 3, 10);
    expect(sheet.defCP, 50);
  });

  test('vp_scenarios/vp_economic_sheet_test.testIsMaxDefense', (){
    var sheet = new VpEconomicSheet(VpSoloDifficulty.EASY);
    expect(sheet.isMaxDefCP, false);
    sheet.defCP = 50;
    expect(sheet.isMaxDefCP, true);
  });

  test('vp_scenarios/vp_economic_sheet_test.rerollDefIfIsMaxDefense', (){
    var sheet = new VpEconomicSheet(VpSoloDifficulty.EASY);
    sheet.defCP = 50;

    MockRoller roller = new MockRoller();
    roller.mockRoll("Econ roll",9, bound: 9);
    sheet.makeRoll(5, roller);
    expect(sheet.defCP, 50);
    expect(sheet.techCP, 5);
  });

  test('vp_scenarios/vp_economic_sheet_test.testStartingBank', (){
    expect(new VpEconomicSheet(VpSoloDifficulty.EASY).bank, 0);
    expect(new VpEconomicSheet(VpSoloDifficulty.NORMAL).bank, 100);
    expect(new VpEconomicSheet(VpSoloDifficulty.HARD).bank, 100);

    expect(new VpEconomicSheet(Vp2pDifficulty.EASY).bank, 150);
    expect(new VpEconomicSheet(Vp2pDifficulty.NORMAL).bank, 150);
    expect(new VpEconomicSheet(Vp2pDifficulty.HARD).bank, 150);

    expect(new VpEconomicSheet(Vp3pDifficulty.EASY).bank, 200);
    expect(new VpEconomicSheet(Vp3pDifficulty.NORMAL).bank, 200);
    expect(new VpEconomicSheet(Vp3pDifficulty.HARD).bank, 200);
  });

  test('vp_scenarios/vp_economic_sheet_test.spendDefCPFromBankIfAble', (){
    var sheet = new VpEconomicSheet(VpSoloDifficulty.NORMAL);
    sheet.defCP = 50;
    expect(sheet.bank, 100);

    sheet.spendDefCP(50);
    expect(sheet.defCP, 50);
    expect(sheet.bank, 50);

    sheet.bank = 25;
    sheet.spendDefCP(50);
    expect(sheet.defCP, 25);
    expect(sheet.bank, 0);

    sheet.spendDefCP(5);
    expect(sheet.defCP, 20);
    expect(sheet.bank, 0);

    sheet.spendDefCP(20);
    expect(sheet.defCP, 0);
    expect(sheet.bank, 0);
  });

  test('vp_scenarios/vp_economic_sheet_test.defCP is added to bank',(){
    var sheet = VpEconomicSheet(VpSoloDifficulty.NORMAL);
    sheet.bank = 0;
    sheet.defCP = 45;
    makeRoll(sheet, 3, 9); //DEFENSE
    expect(sheet.defCP, 50);
    expect(sheet.bank, 15);
  });
}