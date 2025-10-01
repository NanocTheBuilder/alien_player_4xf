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

import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:test/test.dart';

void main() {
  test('testStartingBank', () {
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

  test('spendDefCPFromBankIfAble', () {
    VpEconomicSheet sheet = new VpEconomicSheet(VpSoloDifficulty.NORMAL);
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
}
