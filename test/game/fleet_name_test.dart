import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

void main() {
  AlienPlayer ap;

  setUp(() {
    var game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL,
        [PlayerColor.GREEN, PlayerColor.YELLOW, PlayerColor.RED]);
    ap = game.aliens[0];
  });

  test('firstFleetIsCalledOneSecondIsTwo', () {
    var fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "1");
    fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "2");
  });

  test('namesFillHoles', () {
    var fleet1 = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    var fleet2 = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    ap.removeFleet(fleet1);

    var fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "1");
  });

  test('raiderFleetsAreDifferent', () {
    var fleet1 = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    var fleet = Fleet(ap, FleetType.RAIDER_FLEET, 0);
    expect(fleet.name, "1");
  });

  test('setTypeChangesName', () {
    var fleet1 = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    var fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "2");

    fleet.fleetType = FleetType.DEFENSE_FLEET;
    expect(fleet.name, "1");
  });

  test('setTypeFromRegularToExDontChangeName', () {
    var fleet1 = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    var fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "2");

    fleet.fleetType = FleetType.EXPANSION_FLEET;
    expect(fleet.name, "2");

    fleet.fleetType = FleetType.EXTERMINATION_FLEET_HOME_WORLD;
    expect(fleet.name, "2");

    fleet.fleetType = FleetType.EXTERMINATION_FLEET_GALACTIC_CAPITAL;
    expect(fleet.name, "2");
  });

  test('setTypeFromRegularToRaiderRenames', () {
    var fleet1 = Fleet(ap, FleetType.REGULAR_FLEET, 0);

    var fleet = Fleet(ap, FleetType.REGULAR_FLEET, 0);
    expect(fleet.name, "2");

    fleet.fleetType = FleetType.RAIDER_FLEET;
    expect(fleet.name, "1");
  });
}
