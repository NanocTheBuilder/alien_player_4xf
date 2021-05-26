import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:alienplayer4xf/widgets/fleet_build_dialog.dart';
import 'package:alienplayer4xf/widgets/fleet_build_result_dialog.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class FleetView extends StatelessWidget {
  final Fleet fleet;
  FleetView(this.fleet);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
            color: PlayerColors[fleet.ap.color],
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
                              onPressed: () => game.deleteFleet(fleet))
                          : IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                if (fleet.ap is Scenario4Player) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          FleetBuildDialog(fleet));
                                } else {
                                  buildFleet(context, game, fleet);
                                }
                              },
                            )),
                    )
                  ]);
                }))));
  }

  static void buildFleet(BuildContext context, GameModel game, Fleet fleet, [List<FleetBuildOption> options = const []]) {
    var result = game.firstCombat(fleet, options);
    showDialog(
        context: context,
        builder: (BuildContext context) => FleetBuildResultDialog(result)
        );
  }
}
