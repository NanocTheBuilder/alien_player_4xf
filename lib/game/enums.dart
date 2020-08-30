abstract class Difficulty {
  final String name;
  final int cpPerEcon;
  final int numberOfAlienPlayers;

  const Difficulty(this.name, this.cpPerEcon, this.numberOfAlienPlayers);
}

class FleetType {
  static const FleetType REGULAR_FLEET =
      FleetType("REGULAR_FLEET", FleetNameSequence.BASIC);
  static const FleetType RAIDER_FLEET =
      FleetType("RAIDER_FLEET", FleetNameSequence.RAIDER);
  static const FleetType DEFENSE_FLEET =
      FleetType("DEFENSE_FLEET", FleetNameSequence.DEFENSE);
  static const FleetType EXPANSION_FLEET =
      FleetType("EXPANSION_FLEET", FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_GALACTIC_CAPITAL = FleetType(
      "EXTERMINATION_FLEET_GALACTIC_CAPITAL", FleetNameSequence.BASIC);
  static const FleetType EXTERMINATION_FLEET_HOME_WORLD =
      FleetType("EXTERMINATION_FLEET_HOME_WORLD", FleetNameSequence.BASIC);

  final String name;
  final FleetNameSequence sequence;

  const FleetType(this.name, this.sequence);

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
  static const ShipType RAIDER = ShipType("RAIDER", 12, 2, 99);
  static const ShipType CARRIER = ShipType("CARRIER", 12, 1, 99);
  static const ShipType FIGHTER = ShipType("FIGHTER", 5, 1, 99);
  static const ShipType BASE = ShipType("BASE", 12, 3, 99);
  static const ShipType MINE = ShipType("MINE", 5, 1, 99);
  static const ShipType SCOUT = ShipType("SCOUT", 6, 1, 1);
  static const ShipType DESTROYER = ShipType("DESTROYER", 9, 1, 2);
  static const ShipType CRUISER = ShipType("CRUISER", 12, 2, 3);
  static const ShipType BATTLECRUISER = ShipType("BATTLECRUISER", 15, 2, 4);
  static const ShipType BATTLESHIP = ShipType("BATTLESHIP", 20, 3, 5);
  static const ShipType DREADNAUGHT = ShipType("DREADNAUGHT", 24, 3, 6);
  static const ShipType TITAN = ShipType("TITAN", 32, 5, 7);

  static const ShipType TRANSPORT = ShipType("TRANSPORT", 6, 1, 99);
  static const ShipType INFANTRY = ShipType("INFANTRY", 2, 1, 99);
  static const ShipType MARINE = ShipType("MARINE", 3, 2, 99);
  static const ShipType HEAVY_INFANTRY = ShipType("HEAVY_INFANTRY", 3, 2, 99);
  static const ShipType GRAV_ARMOR = ShipType("GRAV_ARMOR", 4, 2, 99);
  static const ShipType BOARDING_SHIP = ShipType("BOARDING_SHIP", 12, 2, 99);

  static const List<ShipType> cheapToExpensive = [
    SCOUT,
    DESTROYER,
    CRUISER,
    BATTLECRUISER,
    BATTLESHIP,
    DREADNAUGHT,
    TITAN
  ];

  final String name;
  final int cost;
  final int hullSize;
  final int requiredShipSize;

  const ShipType(this.name, this.cost, this.hullSize, this.requiredShipSize);

  @override
  String toString() {
    return name;
  }

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
