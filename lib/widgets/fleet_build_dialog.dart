import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/scenarios/vp_scenarios.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'fleet_view.dart';

class FleetBuildDialog extends StatefulWidget {
  final Fleet fleet;

  FleetBuildDialog(this.fleet);

  @override
  FleetBuildOptionsState createState() => FleetBuildOptionsState(fleet);
}

class FleetBuildOptionsState extends State<FleetBuildDialog> {
  final Fleet fleet;
  bool combatAbovePlanet = false;
  bool enemyIsNpa = false;

  FleetBuildOptionsState(this.fleet);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    rows.add(Row(children: [
      Checkbox(
          value: combatAbovePlanet,
          onChanged: (value) {
            setState(() => combatAbovePlanet = value);
          }),
      Text("Combat above planet"),
    ]));
    if (fleet.ap is VpAlienPlayer) {
      rows.add(Row(children: [
        Checkbox(
            value: enemyIsNpa,
            onChanged: (value) {
              setState(() => enemyIsNpa = value);
            }),
        Text("Enemy is NPA"),
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
                FleetView.buildFleet(context, game, fleet, options);
              },
            ),
          ],
          content: Container(
            width: double.maxFinite,
            child: Card(
                color: PlayerColors[fleet.ap.color],
                child: Column(mainAxisSize: MainAxisSize.min, children: rows)),
          ));
    });
  }
}
