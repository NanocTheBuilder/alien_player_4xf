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

import 'package:alienplayer4xf/game/fleet.dart';
import 'package:alienplayer4xf/game/fleet_builders.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'string_helper.dart';

class FleetBuildResultDialog extends StatelessWidget{
  FleetBuildResult result;

  FleetBuildResultDialog(this.result, {Key key}) : super(key: key);

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