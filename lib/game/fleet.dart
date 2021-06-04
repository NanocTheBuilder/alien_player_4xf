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
