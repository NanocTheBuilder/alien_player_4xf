import 'package:alienplayer4xf/game/alien_economic_sheet.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/main.dart';
import 'package:flutter/material.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';

class EconPhaseResultDialog extends StatelessWidget {
  final int currentTurn;
  final List<EconPhaseResult> results;
  final bool showDetails;

  EconPhaseResultDialog(this.currentTurn, this.results, this.showDetails, {Key key}) : super(key: key);

  Widget resultCard(
      EconPhaseResult result, BuildContext context, bool showDetails) {
    List<Widget> rows = [];
    //CPs
    if (showDetails) {
      if (result.fleetCP != 0) rows.add(Text("Fleet CP +${result.fleetCP}"));
      if (result.techCP != 0) rows.add(Text("Technology CP +${result.techCP}"));
      if (result.defCP != 0) rows.add(Text("Defense CP +${result.defCP}"));
      if (result.extraEcon != 0)
        rows.add(Text("Extra Econ Rolls +${result.extraEcon}"));
    }
    //fleet
    if (result.fleet != null) {
      rows.add(Text(Strings.fleetTypes[result.fleet.fleetType.name] +
          " " +
          result.fleet.name +
          (showDetails ? " (${result.fleet.fleetCP} CP)" : "")));
      if (result.moveTechRolled) {
        rows.add(Text(
            "${Strings.technologies[Technology.MOVE]}: ${result.alienPlayer.technologyLevels[Technology.MOVE]}"));
      }
    }
    return Container(
        child: Card(
      color: PlayerColors[result.alienPlayer.color],
      child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
            children: rows,
          )),
    ));
  }

  Widget resultList(
      List<EconPhaseResult> results, BuildContext context, bool showDetails) {
    List<Widget> resultCards = results
        .where((element) => showDetails || element.fleet != null)
        .map((result) => resultCard(result, context, showDetails))
        .toList();
    if (resultCards.isNotEmpty) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: resultCards.length,
          itemBuilder: (context, index) {
            return resultCards[index];
          });
    } else {
      return Text("No new fleets.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Economic Phase ${currentTurn - 1}"),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        content: Container(
          width: double.maxFinite,
          child: resultList(results, context, showDetails),
        ));
  }
}
