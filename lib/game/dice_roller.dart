import 'dart:math';

class DiceRoller{
  final Random random = Random();

  int roll([int bound=10]) => random.nextInt(bound) + 1;

}