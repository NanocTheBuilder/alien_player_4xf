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

import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

void main() {
  late AlienPlayer ap;

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
