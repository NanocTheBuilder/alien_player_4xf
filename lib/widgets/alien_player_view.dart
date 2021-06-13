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
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:alienplayer4xf/widgets/fleet_build_result_dialog.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_model.dart';
import '../main.dart';

class AlienPlayerView extends StatelessWidget {
  final AlienPlayer alien;
  final bool showDetails;
  final bool showActions;
  final bool showFleetCount;

  AlienPlayerView(this.alien, this.showDetails,
      {this.showActions = false, this.showFleetCount = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, game, child) {
      List<Widget> rows = [];
      addDetails(rows, context);
      addLabels(context, rows, game);
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
        rows.add(Row(
          children: [
            Expanded(
                child: TextButton(
                    style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple.shade400)),
                    child: Text("Home Defense"),
                    onPressed: () {
                      var result = game.buildHomeDefense(alien);
                      showDialog(
                          context: context,
                          builder: (context) => FleetBuildResultDialog(result));
                    })),
            (alien.game!.scenario is Scenario4
                ? Expanded(
                    child: TextButton(
                        style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple.shade400)),
                        child: Text("Colony Defense"),
                        onPressed: () {
                          var result =
                              game.buildColonyDefense(alien as Scenario4Player);
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  FleetBuildResultDialog(result));
                        }))
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
          ],
        ));
      }
      return Container(
          child: Card(
              color: PlayerColors[alien.color],
              child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Column(children: rows))));
    });
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

  void addLabels(BuildContext context, List<Widget> rows, GameModel game) {
    rows.addAll([
      Row(children: [
        techLabel(context, Technology.MOVE),
        techLabel(context, Technology.SHIP_SIZE),
      ]),
      Row(children: [
        techLabel(context, Technology.ATTACK),
        techLabel(context, Technology.DEFENSE),
        techLabel(context, Technology.TACTICS),
      ]),
      Row(children: [
        techLabel(context, Technology.FIGHTERS),
        techLabel(context, Technology.CLOAKING),
        techLabel(context, Technology.SCANNER),
      ]),
      Row(children: [
        techLabel(context, Technology.POINT_DEFENSE),
        techLabel(context, Technology.MINE_SWEEPER),
      ]),
    ]);

    if (alien.game!.scenario is Scenario4) {
      rows.addAll([
        Row(children: [
          techLabel(context, Technology.GROUND_COMBAT),
          techLabel(context, Technology.BOARDING),
          techLabel(context, Technology.SECURITY_FORCES),
        ]),
        Row(children: [
          techLabel(context, Technology.MILITARY_ACADEMY),
          (alien.game!.scenario is VpSoloScenario
              ? Expanded(
                  flex: 1,
                  child: InkWell(
                      child: Text(
                        'Colonies : ${(alien as VpAlienPlayer).colonies}',
                        textAlign: TextAlign.center,
                      ),
                      onTap: showActions
                          ? () => showDialog(
                              context: context,
                              builder: (context) => changeValue(
                                  context,
                                  "Colonies",
                                  values(10),
                                  (alien as VpAlienPlayer).colonies,
                                  (value) => game.setColonies(alien, value)))
                          : null))
              : const SizedBox(width: 0))
        ]),
      ]);
    }
  }

  Widget techLabel(BuildContext context, Technology technology) {
    var labelStr =
        '${Strings.technologies[technology]} : ${alien.technologyLevels[technology]}';
    var fontWeight = alien.technologyLevels[technology] ==
            alien.game!.scenario.getStartingLevel(technology)
        ? FontWeight.normal
        : FontWeight.bold;

    return Expanded(
        flex: 1,
        child: InkWell(
          child: Text(
            labelStr,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: fontWeight),
          ),
          onTap: showActions
              ? () => showDialog(
                  context: context,
                  builder: (context) =>
                      changeTechnologyLevel(context, technology))
              : null,
        ));
  }

  AlertDialog confirmElimination(
      BuildContext context, GameModel game, AlienPlayer player) {
    return AlertDialog(
      title: Text("Are You Sure?"),
      content: Text(
          "Do you want to eliminate player ${Strings.players[player.color]}"),
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

  Widget changeTechnologyLevel(BuildContext context, Technology technology) {
    return Consumer<GameModel>(builder: (context, game, child) {
      return changeValue(
          context,
          Strings.technologies[technology]!,
          technologyLevels(game, technology),
          alien.technologyLevels[technology]!,
          (value) => game.setLevel(alien, technology, value));
    });
  }

  AlertDialog changeValue(
      BuildContext context,
      String label,
      List<DropdownMenuItem<int>> items,
      int initValue,
      Function commitValue) {
    var intValue = initValue;
    return AlertDialog(
      title: Text("Select value"),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return ListTile(
          title: Text(label),
          trailing: DropdownButton<int>(
              items: items,
              value: intValue,
              onChanged: (value) => setState(() => intValue = value as int)),
        );
      }),
      actions: [
        TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
            child: Text("OK"),
            onPressed: () {
              commitValue.call(intValue);
              Navigator.of(context).pop();
            })
      ],
    );
  }

  List<DropdownMenuItem<int>> technologyLevels(
      GameModel game, Technology technology) {
    return values(game.getMaxLevel(technology) + 1);
  }

  List<DropdownMenuItem<int>> values(int maxValue) {
    return List.generate(maxValue, (i) => i)
        .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
        .toList();
  }
}
