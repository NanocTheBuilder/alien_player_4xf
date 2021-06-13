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
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/widgets/fleet_build_dialog.dart';
import 'package:alienplayer4xf/widgets/fleet_build_result_dialog.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_model.dart';
import '../main.dart';

class FleetView extends StatelessWidget {
  final AlienPlayer ap;
  final Fleet fleet;
  FleetView(this.ap, this.fleet, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            color: PlayerColors[ap.color],
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Consumer<GameModel>(builder: (context, game, child) {
                  return Column(children: [
                    ListTile(
                      title: Text(
                          "${Strings.fleetTypes[fleet.fleetType.name]} ${fleet.name}"),
                      subtitle: (fleet.hadFirstCombat
                          ? Text(Strings.groups(fleet))
                          : game.showDetails ? Text("${fleet.fleetCP} CP") : const SizedBox(width: 0)),
                      trailing: (fleet.hadFirstCombat
                          ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => game.deleteFleet(ap, fleet))
                          : IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                if (ap is Scenario4Player) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          FleetBuildDialog(ap, fleet));
                                } else {
                                  buildFleet(context, game, ap, fleet);
                                }
                              },
                            )),
                    )
                  ]);
                }))));
  }

  static void buildFleet(BuildContext context, GameModel game, AlienPlayer ap, Fleet fleet, [List<FleetBuildOption> options = const []]) {
    var result = game.firstCombat(ap, fleet, options);
    showDialog(
        context: context,
        builder: (BuildContext context) => FleetBuildResultDialog(result)
        );
  }
}
