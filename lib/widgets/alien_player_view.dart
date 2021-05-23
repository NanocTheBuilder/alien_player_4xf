import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AlienPlayerView extends StatelessWidget {
  final AlienPlayer alien;
  final bool showDetails;

  Widget techLabel(String label, Technology technology) {
    var labelStr = '${label} : ${alien.technologyLevels[technology]}';
    var fontWeight = alien.technologyLevels[technology] ==
            alien.game.scenario.getStartingLevel(technology)
        ? FontWeight.normal
        : FontWeight.bold;

    return Expanded(
        flex: 1,
        child: Container(
            child: Text(
          labelStr,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: fontWeight),
        )));
  }

  AlienPlayerView(this.alien, this.showDetails);
  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    if (showDetails)
      rows.add(Row(children: [
        Expanded(
            flex: 1,
            child: Container(
                child: Text(
              'Fleet CP: ${alien.economicSheet.fleetCP}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ))),
        Expanded(
            flex: 1,
            child: Container(
                child: Text(
              'Tech CP: ${alien.economicSheet.techCP}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ))),
        Expanded(
            flex: 1,
            child: Container(
                child: Text(
              'Def CP: ${alien.economicSheet.defCP}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ))),
      ]));
    rows.addAll([
      Row(children: [
        techLabel('Move', Technology.MOVE),
        techLabel('Ship Size', Technology.SHIP_SIZE),
      ]),
      Row(children: [
        techLabel('Attack', Technology.ATTACK),
        techLabel('Defense', Technology.DEFENSE),
        techLabel('Tactics', Technology.TACTICS),
      ]),
      Row(children: [
        techLabel('Fighters', Technology.FIGHTERS),
        techLabel('Cloaking', Technology.CLOAKING),
        techLabel('Scanner', Technology.SCANNER),
      ]),
      Row(children: [
        techLabel('Point Defense', Technology.POINT_DEFENSE),
        techLabel('Mine Sweep', Technology.MINE_SWEEPER),
      ]),
    ]);

    if (alien.game.scenario is Scenario4) {
      rows.addAll([
        Row(children: [
          techLabel('Ground', Technology.GROUND_COMBAT),
          techLabel('Boarding', Technology.BOARDING),
          techLabel('Security', Technology.SECURITY_FORCES),
        ]),
        Row(children: [
          techLabel('Military Academy', Technology.MILITARY_ACADEMY),
        ]),
      ]);
    }

    return Container(
        child: Card(
            color: PlayerColors[alien.color], child: Column(children: rows)));
  }
}
