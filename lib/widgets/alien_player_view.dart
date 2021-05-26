import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:alienplayer4xf/widgets/fleet_build_result_dialog.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class AlienPlayerView extends StatelessWidget {
  final AlienPlayer alien;
  final bool showDetails;
  final bool showActions;
  final bool showFleetCount;

  AlienPlayerView(this.alien, this.showDetails,
      {this.showActions = false, this.showFleetCount = false});

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    addDetails(rows, context);
    addLabels(rows);
    if (showFleetCount) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${alien.fleets.length} fleets"),
          const SizedBox(width: 16),
        ],
      ));
    }
    if (showActions) {
      rows.add(Consumer<GameModel>(builder: (context, game, child) {
        return Row(
          children: [
            const SizedBox(width: 16),
            TextButton(
                child: Text("Home Defense"),
                onPressed: () {
                  var result = game.buildHomeDefense(alien);
                  showDialog(
                      context: context,
                      builder: (context) => FleetBuildResultDialog(result));
                }),
            const SizedBox(width: 16),
            (alien.game.scenario is Scenario4
                ? TextButton(
                    child: Text("Colony Defense"),
                    onPressed: () {
                      var result =
                          game.buildColonyDefense(alien as Scenario4Player);
                      showDialog(
                          context: context,
                          builder: (context) => FleetBuildResultDialog(result));
                    })
                : const SizedBox(width: 0)),
            Expanded(child: Container()),
            (!alien.isEliminated)
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            confirmElimination(context, game, alien)))
                : const Text("Eliminated"),
            const SizedBox(width: 16),
          ],
        );
      }));
    }

    return Container(
        child: Card(
            color: PlayerColors[alien.color],
            child: Padding(
                padding: EdgeInsets.all(4.0), child: Column(children: rows))));
  }

  void addDetails(List<Widget> rows, BuildContext context) {
    if (showDetails) {
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
    }
  }

  void addLabels(List<Widget> rows) {
    rows.addAll([
      Row(children: [
        techLabel(Technology.MOVE),
        techLabel(Technology.SHIP_SIZE),
      ]),
      Row(children: [
        techLabel(Technology.ATTACK),
        techLabel(Technology.DEFENSE),
        techLabel(Technology.TACTICS),
      ]),
      Row(children: [
        techLabel(Technology.FIGHTERS),
        techLabel(Technology.CLOAKING),
        techLabel(Technology.SCANNER),
      ]),
      Row(children: [
        techLabel(Technology.POINT_DEFENSE),
        techLabel(Technology.MINE_SWEEPER),
      ]),
    ]);

    if (alien.game.scenario is Scenario4) {
      rows.addAll([
        Row(children: [
          techLabel(Technology.GROUND_COMBAT),
          techLabel(Technology.BOARDING),
          techLabel(Technology.SECURITY_FORCES),
        ]),
        Row(children: [
          techLabel(Technology.MILITARY_ACADEMY),
          (alien.game.scenario is VpSoloScenario
              ? Expanded(
                  flex: 1,
                  child: Container(
                      child: Text(
                    'Colonies : ${(alien as VpAlienPlayer).colonies}',
                    textAlign: TextAlign.center,
                  )))
              : const SizedBox(width: 0))
        ]),
      ]);
    }
  }

  Widget techLabel(Technology technology) {
    var labelStr =
        '${Strings.technologies[technology]} : ${alien.technologyLevels[technology]}';
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

  AlertDialog confirmElimination(
      BuildContext context, GameModel game, AlienPlayer player) {
    return AlertDialog(
      title: Text("Are You Sure?"),
      content: Text("Do you want to eliminate player ${Strings.players[player.color]}"),
      actions: [
        TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              game.eliminate(player);
            })
      ],
    );
  }
}
