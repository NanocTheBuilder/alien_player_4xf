import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/main.dart';
import 'package:flutter/material.dart';

class EconPhaseResultDialog extends StatelessWidget {
  final int currentTurn;
  final List<EconPhaseResult> results;

  EconPhaseResultDialog(this.currentTurn, this.results);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Economic Phase ${currentTurn - 1}"),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                var ap = results[index];
                return Container(
                  color: PlayerColors[ap.alienPlayer.color],
                  child: Text("TechCP:${ap.techCP}, FleetCP:${ap.fleetCP}, DefCP:${ap.defCP}, ExtraEcon: ${ap.extraEcon}, Fleet:${ap.fleet}"),
                );
              }),
        ));
  }
}
