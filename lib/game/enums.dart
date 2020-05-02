abstract class Difficulty {
  final String name;
  final int cpPerEcon;
  final int numberOfAlienPlayers;

  const Difficulty(this.name, this.cpPerEcon, this.numberOfAlienPlayers);
}

class FleetType {
  static const FleetType REGULAR_FLEET = FleetType(FleetNameSequence.BASIC);
  static const FleetType RAIDER_FLEET = FleetType(FleetNameSequence.RAIDER);
  static const FleetType DEFENSE_FLEET = FleetType(FleetNameSequence.DEFENSE);
  static const FleetType EXPANSION_FLEET = FleetType(FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_GALACTIC_CAPITAL =
      FleetType(FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_HOME_WORLD =
      FleetType(FleetNameSequence.BASIC);

  const FleetType(this.sequence);

  final FleetNameSequence sequence;

  bool isSameNameSequence(FleetType other) => sequence == other.sequence;
}

enum FleetNameSequence { BASIC, DEFENSE, RAIDER }

enum PlayerColor { GREEN, YELLOW, RED, BLUE }

enum Seeable { FIGHTERS, MINES, BOARDING_SHIPS, VETERANS, SIZE_3_SHIPS }

enum Technology {
  MOVE,
  SHIP_SIZE,
  ATTACK,
  DEFENSE,
  TACTICS,
  CLOAKING,
  SCANNER,
  FIGHTERS,
  POINT_DEFENSE,
  MINE_SWEEPER,
  SECURITY_FORCES,
  MILITARY_ACADEMY,
  BOARDING,
  GROUND_COMBAT
}

enum FleetBuildOption { COMBAT_IS_ABOVE_PLANET, HOME_DEFENSE, COMBAT_WITH_NPAS }

class ShipType {
  static const ShipType RAIDER = ShipType(12, 2, 99);
  static const ShipType CARRIER = ShipType(12, 1, 99);
  static const ShipType FIGHTER = ShipType(5, 1, 99);
  static const ShipType BASE = ShipType(12, 3, 99);
  static const ShipType MINE = ShipType(5, 1, 99);
  static const ShipType SCOUT = ShipType(6, 1, 1);
  static const ShipType DESTROYER = ShipType(9, 1, 2);
  static const ShipType CRUISER = ShipType(12, 2, 3);
  static const ShipType BATTLECRUISER = ShipType(15, 2, 4);
  static const ShipType BATTLESHIP = ShipType(20, 3, 5);
  static const ShipType DREADNAUGHT = ShipType(24, 3, 6);
  static const ShipType TITAN = ShipType(32, 5, 7);

  static const ShipType TRANSPORT = ShipType(6, 1, 99);
  static const ShipType INFANTRY = ShipType(2, 1, 99);
  static const ShipType MARINE = ShipType(3, 2, 99);
  static const ShipType HEAVY_INFANTRY = ShipType(3, 2, 99);
  static const ShipType GRAV_ARMOR = ShipType(4, 2, 99);
  static const ShipType BOARDING_SHIP = ShipType(12, 2, 99);

  static const List<ShipType> cheapToExpensive = [
    SCOUT,
    DESTROYER,
    CRUISER,
    BATTLECRUISER,
    BATTLESHIP,
    DREADNAUGHT,
    TITAN
  ];

  final int cost;
  final int hullSize;
  final int requiredShipSize;

  const ShipType(this.cost, this.hullSize, this.requiredShipSize);

  bool canBeBuilt(int availableCP, int shipSizeLevel) =>
      availableCP >= cost && shipSizeLevel >= requiredShipSize;

  static ShipType findCheapest(int minHullSize) {
    return cheapToExpensive.firstWhere((type) => type.hullSize >= minHullSize,
        orElse: () => null);
  }

  static Iterable<ShipType> getBiggerTypesInReverse(ShipType type) {
    return cheapToExpensive.reversed.where((t) => t.cost > type.cost);
  }

  static ShipType findBiggest(int availableCP, int shipSizeLevel) {
    return cheapToExpensive.reversed.firstWhere(
        (type) => type.canBeBuilt(availableCP, shipSizeLevel),
        orElse: () => null);
  }
}
