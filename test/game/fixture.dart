import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:alienplayer4xf/game/fleet_launcher.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/technology_buyer.dart';
import 'package:test/test.dart';
import 'mock_roller.dart';

late Game game;
late AlienPlayer ap;
late DefenseBuilder defBuilder;
late MockRoller roller;
late AlienEconomicSheet sheet;
late FleetBuilder fleetBuilder;
late TechnologyBuyer techBuyer;
late FleetLauncher fleetLauncher;

void setupFixture(Game newGame) {
  game = newGame;
  roller = MockRoller();
  game.roller = roller;
  defBuilder = game.scenario.defenseBuilder;
  fleetBuilder = game.scenario.fleetBuilder;
  fleetLauncher = game.scenario.fleetLauncher;
  techBuyer = game.scenario.techBuyer;
  ap = game.aliens[0];
  sheet = ap.economicSheet;
}

//tearDown
void assertAllRollsUsed() {
  roller.assertAllUsed();
}

void assertLevels(Map<Technology, int> expectedLevels) {
  var errors = [];
  for (var technology in game.scenario.availableTechs) {
    var expectedLevel =
        expectedLevels[technology] ??
        game.scenario.getStartingLevel(technology);
    if (expectedLevel != ap.getLevel(technology)) {
      errors.add(
        '$technology: expected $expectedLevel but was ${ap.getLevel(technology)}',
      );
    }
  }
  if (errors.isNotEmpty) {
    fail('Level assertions failed:\n${errors.join('\n')}');
  }
}

void assertLevel(Technology technology, int expectedLevel) {
  assertLevels({technology: expectedLevel});
}

void resetLevels(Map<Technology, int> startingLevels) {
  for (var technology in game.scenario.availableTechs) {
    var resetLevel =
        startingLevels[technology] ??
        game.scenario.getStartingLevel(technology);
    ap.setLevel(technology, resetLevel);
  }
}

void setLevel(Technology technology, int level) {
  ap.technologyLevels[technology] = level;
}

void setCPs(int fleetCP, int techCP, int defCP) {
  sheet.fleetCP = fleetCP;
  sheet.techCP = techCP;
  sheet.defCP = defCP;
}

void assertCPs(int fleetCP, int techCP, int defCP) {
  expect(sheet.fleetCP, fleetCP);
  expect(sheet.techCP, techCP);
  expect(sheet.defCP, defCP);
}

void assertGroups(Fleet fleet, List<Group> expectedGroups) {
      expect(fleet.groups, expectedGroups);
}

