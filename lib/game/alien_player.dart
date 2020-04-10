import 'enums.dart';
import 'fleet.dart';

class AlienPlayer{
  List<Fleet> fleets;

  AlienPlayer(){
    this.fleets = <Fleet>[];
  }

  String findFleetName(FleetType fleetType) {
    for (int i = 1; i < 100; i++) {
      if (findFleetByName(i.toString(), fleetType) == null) {
        return i.toString();
      }
    }
    return "?";
  }

  Fleet findFleetByName(String name, FleetType fleetType) {
    return fleets.firstWhere((fleet) =>
    fleet.name == name && fleet.fleetType.isSameNameSequence(fleetType),
        orElse: () => null);
  }
}
