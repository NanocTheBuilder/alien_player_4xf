import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AlienPlayerView extends StatelessWidget {
  final AlienPlayer alien;

  AlienPlayerView(this.alien);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: PlayerColors[alien.color],
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Fleet CP: ${alien.economicSheet.fleetCP}',
                    textAlign: TextAlign.left,
                  ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Tech CP: ${alien.economicSheet.techCP}',
                    textAlign: TextAlign.center,
                  ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Def CP: ${alien.economicSheet.defCP}',
                    textAlign: TextAlign.right,
                  ))),
            ]),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Move: ${alien.technologyLevels[Technology.MOVE]}',
                    textAlign: TextAlign.left,
                  ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Ship size: ${alien.technologyLevels[Technology.SHIP_SIZE]}',
                    textAlign: TextAlign.right,
                  ))),
            ]),
            Row(children: [
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Attack: ${alien.technologyLevels[Technology.ATTACK]}',
                    textAlign: TextAlign.left,
                  ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Defense: ${alien.technologyLevels[Technology.DEFENSE]}',
                    textAlign: TextAlign.center,
                  ))),
              Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Tactics: ${alien.technologyLevels[Technology.TACTICS]}',
                    textAlign: TextAlign.right,
                  ))),
            ]),
          ],
        ));
  }
}
