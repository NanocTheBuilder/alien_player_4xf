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
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_model.dart';
import '../main.dart';
import 'fleet_view.dart';

class FleetBuildDialog extends StatefulWidget {
  final AlienPlayer ap;
  final Fleet fleet;

  FleetBuildDialog(this.ap, this.fleet, {Key? key}) : super(key: key);

  @override
  FleetBuildOptionsState createState() => FleetBuildOptionsState(ap, fleet);
}

class FleetBuildOptionsState extends State<FleetBuildDialog> {
  final AlienPlayer ap;
  final Fleet fleet;
  bool combatAbovePlanet = false;
  bool enemyIsNpa = false;

  FleetBuildOptionsState(this.ap, this.fleet);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(Row(children: [
      Expanded(child:
      CheckboxListTile(
          title: Text("Combat above planet"),
          value: combatAbovePlanet,
          onChanged: (value) {
            setState(() => combatAbovePlanet = value as bool);
          })),
    ]));
    if (ap is VpAlienPlayer) {
      rows.add(Row(children: [
        Expanded(child:
        CheckboxListTile(
          title: Text("Enemy is NPA"),
            value: enemyIsNpa,
            onChanged: (value) {
              setState(() => enemyIsNpa = value as bool);
            })),
      ]));
    }
    return Consumer<GameModel>(builder: (context, game, child) {
      return AlertDialog(
          title: Text("First Combat"),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop()
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                List<FleetBuildOption> options = [];
                if(combatAbovePlanet) options.add(FleetBuildOption.COMBAT_IS_ABOVE_PLANET);
                if(enemyIsNpa) options.add(FleetBuildOption.COMBAT_WITH_NPAS);
                Navigator.of(context).pop();
                FleetView.buildFleet(context, game, ap, fleet, options);
              },
            ),
          ],
          content: Container(
            width: double.maxFinite,
            child: Card(
                color: PlayerColors[ap.color],
                child: Column(mainAxisSize: MainAxisSize.min, children: rows)),
          ));
    });
  }
}
