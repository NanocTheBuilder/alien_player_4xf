import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';

class Fleet {
  AlienPlayer ap;
  FleetType fleetType;
  String name;

  Fleet(AlienPlayer ap, FleetType fleetType){
    this.ap = ap;
    this.fleetType = fleetType;
    this.name = ap.findFleetName(fleetType);
    ap.fleets.add(this);
  }
}