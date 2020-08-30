import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';

class Group {
  int size;
  ShipType shipType;

  Group(this.shipType, this.size);

  int addShips(int ships) {
    return size += ships;
  }

  int get cost => size * shipType.cost;

  @override
  bool operator ==(other) {
    return other?.shipType == shipType && other?.size == size;
  }

  @override
  int get hashCode => size.hashCode * shipType.hashCode;

  @override
  String toString() {
    return 'Group{size: $size, shipType: $shipType}';
  }

//
}

class Fleet {
  FleetType _fleetType;
  String _name;

  int fleetCP;
  List<Group> groups = [];
  List<Group> freeGroups = [];
  AlienPlayer ap;
  var hadFirstCombat = false;

  Fleet(this.ap, this._fleetType, this.fleetCP) {
    this._name = ap.findFleetName(fleetType);
    ap.fleets.add(this);
  }

  int get buildCost => allGroupCost - freeGroupCost;

  int get allGroupCost => sumGroupCost(groups);

  int get freeGroupCost => sumGroupCost(freeGroups);

  int get remainingCP => fleetCP - buildCost;

  bool get canBuyMoreShips => remainingCP >= ShipType.SCOUT.cost;

  String get name => _name;

  FleetType get fleetType => _fleetType;

  set fleetType(FleetType fleetType) {
    if (!_fleetType.isSameNameSequence(fleetType)) {
      _name = ap.findFleetName(fleetType);
    }
    _fleetType = fleetType;
  }

  void addFleetCp(int amount) {
    fleetCP += amount;
  }

  void addFreeGroup(Group group) {
    addGroup(group);
    freeGroups.add(group);
  }

  void addGroup(Group group) {
    if (group.size > 0) {
      Group existingGroup = findGroup(group.shipType);
      if (existingGroup != null)
        existingGroup.addShips(group.size);
      else
        groups.add(group);
    }
  }

  Group findGroup(ShipType shipType) {
    for (Group group in groups) {
      if (group.shipType == shipType) return group;
    }
    return null;
  }

  int sumGroupCost(List<Group> groups) {
    return groups.fold(0, (prev, group) => prev + group.cost);
  }

  int get index => ap.fleets.indexOf(this);
}
