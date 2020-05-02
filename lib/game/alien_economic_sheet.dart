import 'alien_player.dart';
import 'dice_roller.dart';
import 'enums.dart';
import 'fleet.dart';

class EconRollResult {
  int fleetCP = 0;
  int techCP = 0;
  int defCP = 0;
  int extraEcon = 0;

  void add(EconRollResult other) {
    fleetCP += other.fleetCP;
    techCP += other.techCP;
    defCP += other.defCP;
    extraEcon += other.extraEcon;
  }
}

class EconPhaseResult extends EconRollResult {
  Fleet fleet;
  AlienPlayer alienPlayer;
  bool moveTechRolled;

  EconPhaseResult(this.alienPlayer);
}

class AlienEconomicSheet {
  static const int RESULT_FLEET = 0;
  static const int RESULT_TECH = 1;
  static const int RESULT_DEF = 2;

  //@formatter:off
  static final List<List<int>> resultTable = const[
    [ 99, 99, 99],
    [ 99, 3, 99],
    [ 2, 4, 99],
    [ 2, 5, 9],
    [ 2, 6, 9],
    [ 2, 6, 10],
    [ 2, 7, 10],
    [ 1, 6, 10],
    [ 1, 6, 10],
    [ 1, 6, 10],
    [ 1, 7, 10],
    [ 1, 7, 10],
    [ 1, 7, 10],
    [ 1, 7, 99],
    [ 1, 7, 99],
    [ 1, 8, 99],
    [ 1, 8, 99],
    [ 1, 9, 99],
    [ 1, 9, 99],
    [ 1, 10, 99],
    [ 1, 10, 99],
  ];

  static var econRolls =   const[ -99,   1,  1,  2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4,  4, 5,  5, 5,  5, 5,  5];
  static var fleetLaunch = const[ -99, -99, 10, 10, 5, 3, 4, 4, 4, 5, 5, 3, 3, 3, 10, 3, 10, 3, 10, 3, 10];

  //@formatter:on

  Difficulty difficulty;
  var fleetCP = 0;
  var techCP = 0;
  var defCP = 0;
  var extraEcon = [for(int i = 0; i < 21; i++) 0];

  AlienEconomicSheet(this.difficulty);

  EconRollResult makeRoll(int turn, DiceRoller roller) {
    EconRollResult result = EconRollResult();
    int roll = roller.roll();
    if (roll >= requiredRoll(turn, RESULT_DEF)) {
      int defCP = 2 * difficulty.cpPerEcon;
      this.defCP += defCP;
      result.defCP = defCP;
    }
    else if (roll >= requiredRoll(turn, RESULT_TECH)) {
      int techCP = difficulty.cpPerEcon;
      this.techCP += techCP;
      result.techCP = techCP;
    }
    else if (roll >= requiredRoll(turn, RESULT_FLEET)) {
      int fleetCP = difficulty.cpPerEcon;
      this.fleetCP += fleetCP;
      result.fleetCP = fleetCP;
    }
    else {
      for (int i = turn + 3; i < 21; i++)
        extraEcon[i] += 1;
      result.extraEcon = 1;
    }
    return result;
  }

  int requiredRoll(int turn, int result) {
    return AlienEconomicSheet.resultTable[getResultTableRow(turn)][result];
  }

  int getResultTableRow(int turn) {
    return turn < 20 ? turn : 20 - (turn % 2);
  }

  int getExtraEcon(int turn) => extraEcon[getResultTableRow(turn)];

  int getEconRolls(int turn) =>
      AlienEconomicSheet.econRolls[getResultTableRow(turn)];

  int getFleetLaunch(int turn) =>
      AlienEconomicSheet.fleetLaunch[getResultTableRow(turn)];

  void spendFleetCP(int amount) {
    fleetCP -= amount;
  }

  void addFleetCP(int amount) {
    fleetCP += amount;
  }

  void spendTechCP(int amount) {
    techCP -= amount;
  }

  void spendDefCP(int amount) {
    defCP -= amount;
  }
}
