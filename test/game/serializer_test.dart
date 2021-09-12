import 'dart:convert';

import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:test/test.dart';

void main(){
  test('Base game serialization', (){
      var orig = Game.newGame(BaseGameScenario(), BaseGameDifficulty.NORMAL, [PlayerColor.BLUE, PlayerColor.RED, PlayerColor.YELLOW]);
      var decoded = Game.fromJson(jsonDecode(jsonEncode(orig)));
      expect(decoded.runtimeType, Game);

      var yellow = orig.aliens[2];
      var sheet = yellow.economicSheet;
      sheet.defCP = 100;
      sheet.fleetCP = 200;
      sheet.extraEcon[5] = 3;
      var fleet = Fleet("1", FleetType.REGULAR_FLEET, 100);
      yellow.fleets.add(fleet);
      fleet.hadFirstCombat = true;
      fleet.groups.add(Group(ShipType.FIGHTER, 66));
      fleet.freeGroups.add(Group(ShipType.MINE, 55));
      yellow.technologyLevels[Technology.ATTACK] = 4;
      yellow.technologyLevels[Technology.DEFENSE] = 5;
      yellow.technologyLevels[Technology.MINE_SWEEPER] = 7;
      decoded = Game.fromJson(jsonDecode(jsonEncode(orig)));
      expect(decoded.aliens.length, 3);
      expect(decoded.aliens[2].economicSheet.defCP, 100);
      expect(decoded.aliens[2].economicSheet.fleetCP, 200);
      expect(decoded.aliens[2].economicSheet.extraEcon[4], 0);
      expect(decoded.aliens[2].economicSheet.extraEcon[5], 3);
      expect(decoded.aliens[2].color, PlayerColor.YELLOW);
      expect(decoded.aliens[2].fleets.length, 1);
      expect(decoded.aliens[2].fleets[0].fleetCP, 100);
      expect(decoded.aliens[2].fleets[0].name, "1");
      expect(decoded.aliens[2].fleets[0].fleetType, FleetType.REGULAR_FLEET);
      expect(decoded.aliens[2].fleets[0].groups.length, 1);
      expect(decoded.aliens[2].fleets[0].groups[0].shipType, ShipType.FIGHTER);
      expect(decoded.aliens[2].fleets[0].groups[0].size, 66);
      expect(decoded.aliens[2].fleets[0].freeGroups.length, 1);
      expect(decoded.aliens[2].fleets[0].freeGroups[0].shipType, ShipType.MINE);
      expect(decoded.aliens[2].fleets[0].freeGroups[0].size, 55);

  });
}