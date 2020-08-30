import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {

  AlienPlayer ap;
  AlienEconomicSheet sheet;
  MockRoller roller;
  DefenseBuilder defBuilder;

  //utils come first
  void assertBuiltGroups(int defCP, int roll, List<Group> expectedGroups) {
    sheet.defCP = defCP;
    roller.mockRoll(roll);
    var fleet = defBuilder.buildHomeDefense(ap);
    var expectedCost = 0;
    for (Group g in expectedGroups) {
      expectedCost += g.shipType.cost * g.size;
    }
    expect(fleet.fleetType, FleetType.DEFENSE_FLEET);
    expect(fleet.groups, expectedGroups);
    expect(fleet.buildCost, expectedCost);
  }

  //tests

  setUp(() {
    var game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    ap = game.aliens[0];
    sheet = ap.economicSheet;
    roller = MockRoller();
    game.roller = roller;
    defBuilder = game.scenario.defenseBuilder;
  });

  test('spendNoDefenseCPBuildNothings', () {
    sheet.defCP = 0;
    expect(defBuilder.buildHomeDefense(ap), null);
  });

  test('spendAllOnMines', () {
    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
    assertBuiltGroups(10, 1, [Group(ShipType.MINE, 2)]);
  });

  test('spendAllOnBases', () {
    assertBuiltGroups(12, 8, [Group(ShipType.BASE, 1)]);
    assertBuiltGroups(24, 8, [Group(ShipType.BASE, 2)]);
    assertBuiltGroups(36, 8, [Group(ShipType.BASE, 3)]);
    assertBuiltGroups(51, 8, [Group(ShipType.BASE, 4)]);

    assertBuiltGroups(
        17, 8, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        29, 8, [Group(ShipType.BASE, 2), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        34, 8, [Group(ShipType.BASE, 2), Group(ShipType.MINE, 2)]);

    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
  });

  test('spendBalanced', () {
    assertBuiltGroups(12, 5, [Group(ShipType.BASE, 1)]);
    assertBuiltGroups(
        17, 5, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 1)]);
    assertBuiltGroups(
        24, 5, [Group(ShipType.BASE, 1), Group(ShipType.MINE, 2)]);

    assertBuiltGroups(5, 1, [Group(ShipType.MINE, 1)]);
  });
}
