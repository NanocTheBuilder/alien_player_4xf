import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

import '../../mock_roller.dart';

void main() {
  AlienPlayer ap;
  AlienEconomicSheet sheet;
  Fleet fleet;

  void assertEquals(expected, actual) {
    expect(actual, expected);
  }

  void assertRegularFleetLaunch(EconPhaseResult result, int fleetCP) {
    assertEquals(fleetCP, result.fleet.fleetCP);
    assertEquals(FleetType.REGULAR_FLEET, result.fleet.fleetType);
    assertEquals(result.fleet, ap.fleets[0]);
  }

  void assertNoFleetLaunch(EconPhaseResult result) {
    assertEquals(null, result.fleet);
  }

  void assertCPs(int fleetCP, int techCP, int defCP) {
    assertEquals(fleetCP, sheet.fleetCP);
    assertEquals(techCP, sheet.techCP);
    assertEquals(defCP, sheet.defCP);
  }

  void assertGroups(Fleet fleet, List<Group> expectedGroups) {
    assertEquals(expectedGroups, fleet.groups);
  }

  test('economyRollStartsNewFleet', () {
    MockRoller roller = MockRoller();
    var game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    game.roller = roller;
    ap = game.aliens[0];
    sheet = ap.economicSheet;

    roller.mockRoll(1); //extra econ
    roller.mockRoll(1); //launch
    assertNoFleetLaunch(ap.makeEconRoll(1));
    assertEquals(1, sheet.getExtraEcon(4));
    assertCPs(0, 0, 0);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(5);
    roller.mockRoll(1); //launch
    assertNoFleetLaunch(ap.makeEconRoll(2));
    assertCPs(0, 5, 0);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(4);
    roller.mockRoll(3);
    roller.mockRoll(2);
    roller.mockRoll(7);
    EconPhaseResult result = ap.makeEconRoll(3);
    assertRegularFleetLaunch(result, 10);
    assertEquals(1, ap.getLevel(Technology.MOVE));
    assertCPs(0, 5, 0);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(4);
    roller.mockRoll(3);
    roller.mockRoll(3);
    roller.mockRoll(6);
    result = ap.makeEconRoll(4);
    assertNoFleetLaunch(result);
    assertCPs(15, 5, 0);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(7);
    roller.mockRoll(10);
    roller.mockRoll(10);
    roller.mockRoll(10);
    result = ap.makeEconRoll(5);
    assertNoFleetLaunch(result);
    assertCPs(15, 10, 20);
    assertEquals(0, roller.rolls.length);

    fleet = ap.fleets[0];
    roller.mockRoll(9); // ShipSize
    ap.firstCombat(fleet);
    assertEquals(2, ap.getLevel(Technology.SHIP_SIZE));
    assertGroups(fleet, [Group(ShipType.DESTROYER, 1)]);
    assertCPs(16, 0, 20);
    assertEquals(0, roller.rolls.length);

    ap.removeFleet(fleet);
    assertEquals(0, ap.fleets.length);

    roller.mockRoll(6);
    roller.mockRoll(6);
    roller.mockRoll(9);
    roller.mockRoll(7);
    roller.mockRoll(5);
    result = ap.makeEconRoll(6);
    assertNoFleetLaunch(result);
    assertCPs(26, 10, 20);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(6);
    roller.mockRoll(9);
    roller.mockRoll(8);
    roller.mockRoll(3);
    roller.mockRoll(4);
    roller.mockRoll(8);
    result = ap.makeEconRoll(7);
    assertRegularFleetLaunch(result, 31);
    assertEquals(1, ap.getLevel(Technology.MOVE));
    assertCPs(0, 25, 20);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(1);
    roller.mockRoll(4);
    roller.mockRoll(7);
    roller.mockRoll(9);
    roller.mockRoll(7);
    result = ap.makeEconRoll(8);
    assertNoFleetLaunch(result);
    assertCPs(10, 35, 20);
    assertEquals(0, roller.rolls.length);

    fleet = ap.fleets[0];
    roller.mockRoll(9); // ShipSize
    roller.mockRoll(6); // Cloaking
    ap.firstCombat(fleet);
    assertEquals(2, ap.getLevel(Technology.SHIP_SIZE));
    assertEquals(1, ap.getLevel(Technology.CLOAKING));
    assertGroups(fleet, [Group(ShipType.RAIDER, 2)]);
    assertEquals(FleetType.RAIDER_FLEET, fleet.fleetType);
    assertCPs(17, 5, 20);
    assertEquals(0, roller.rolls.length);

    roller.mockRoll(2);
    roller.mockRoll(9);
    roller.mockRoll(7);
    roller.mockRoll(7);
    roller.mockRoll(8);

    result = ap.makeEconRoll(9);
    assertNoFleetLaunch(result);
    assertCPs(22, 20, 20);
    assertEquals(0, roller.rolls.length);

    game.setSeenLevel(Technology.CLOAKING, 1);
    roller.mockRoll(1); // Scanners
    roller.mockRoll(9); // ShipSize (Ignored)
    roller.mockRoll(1); // Max number of ships
    roller.mockRoll(10); // Max bases
    ap.buildHomeDefense();
    assertEquals(2, ap.getLevel(Technology.SHIP_SIZE));
    assertEquals(1, ap.getLevel(Technology.SCANNER));
    assertGroups(
        ap.fleets[1], [Group(ShipType.DESTROYER, 1), Group(ShipType.SCOUT, 2)]);
    assertEquals(FleetType.REGULAR_FLEET, ap.fleets[1].fleetType);
    assertGroups(
        ap.fleets[2], [Group(ShipType.BASE, 1), Group(ShipType.MINE, 1)]);
    assertEquals(FleetType.DEFENSE_FLEET, ap.fleets[2].fleetType);
    assertCPs(1, 0, 3);
    assertEquals(0, roller.rolls.length);

    // TODO build raider fleet (isJustPurchasedCloaking)
  });
}
