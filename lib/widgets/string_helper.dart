import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';

class Strings {
  static const Map<PlayerColor, String> players = {
    PlayerColor.GREEN : "Green",
    PlayerColor.YELLOW : "Yellow",
    PlayerColor.RED : "Red",
    PlayerColor.BLUE : "Blue",
  } ;

  static const Map<String, String> shipTypes = {
    "RAIDER": "R",
    "CARRIER": "CV",
    "FIGHTER": "F",
    "BASE": "Base",
    "MINE": "Mine",
    "SCOUT": "SC",
    "DESTROYER": "DD",
    "CRUISER": "CA",
    "BATTLECRUISER": "BC",
    "BATTLESHIP": "BB",
    "DREADNAUGHT": "DN",
    "TITAN": "Titan",
    "TRANSPORT": "T",
    "INFANTRY": "Inf",
    "MARINE": "Mar",
    "HEAVY_INFANTRY": "HI",
    "GRAV_ARMOR": "Grav",
    "BOARDING_SHIP": "BD",
  };

  static const Map<String, String> fleetTypes = {
    "REGULAR_FLEET": "Regular Fleet",
    "RAIDER_FLEET": "Raider Fleet",
    "DEFENSE_FLEET": "Defense Fleet",
    "EXPANSION_FLEET": "Expansion Fleet",
    "EXTERMINATION_FLEET": "Extermination Fleet",
    "EXTERMINATION_FLEET_GALACTIC_CAPITAL":
        "Extermination Fleet (Galactic Capital)",
    "EXTERMINATION_FLEET_HOME_WORLD": "Extermination Fleet (Player Home World)",
  };

  static const Map<Technology, String> technologies = {
    Technology.MOVE: "Move",
    Technology.SHIP_SIZE : "Ship Size",
    Technology.ATTACK : "Attack",
    Technology.DEFENSE : "Defense",
    Technology.TACTICS : "Tactics",
    Technology.CLOAKING : "Cloaking",
    Technology.SCANNER : "Scanner",
    Technology.FIGHTERS : "Fighters",
    Technology.POINT_DEFENSE : "Point Defense",
    Technology.MINE_SWEEPER : "Mine Sweep",
    Technology.SECURITY_FORCES : "Security",
    Technology.MILITARY_ACADEMY : "Military Academy",
    Technology.BOARDING : "Boarding",
    Technology.GROUND_COMBAT : "Ground",
  };

  static String groups(Fleet fleet) {
    StringBuffer sb = StringBuffer();
    fleet.groups.forEach((element) {
      sb.write("[${element.size} ${shipTypes[element.shipType.name]}] ");
    });
    return sb.toString().trimRight();
  }
}
