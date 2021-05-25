import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'string_helper.dart';

class FleetBuildResultDialog extends StatelessWidget{
  FleetBuildResult result;

  FleetBuildResultDialog(this.result);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("New Fleets & Technologies"),
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
            child: cardList(result),
        ));
  }    

  Widget cardList(FleetBuildResult result){
    List<Widget> cards = [];
    if(result.newFleets.isNotEmpty){
      cards.add(techCard(result));
    }
    cards.addAll(result.newFleets.map((fleet) => fleetCard(fleet)));
    return ListView.builder(
        shrinkWrap: true,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return cards[index];
        });
  }

  Widget techCard(FleetBuildResult result){
    return Container(
      child: Card(
        color: PlayerColors[result.alienPlayer.color],
        child: Column(
          children: result.newTechs.entries.map((e) => Text("${Strings.technologies[e.key]}: ${e.value}")).toList(),
        )
    ),
    );
  }

  Widget fleetCard(Fleet fleet){
    return Container(
        child: Card(
          color: PlayerColors[result.alienPlayer.color],
          child: Column(
            children: [
              Text("${Strings.fleetTypes[fleet.fleetType.name]} ${fleet.name}"),
              Text(Strings.groups(fleet))
            ],
          ),
        )
    );
  }
}