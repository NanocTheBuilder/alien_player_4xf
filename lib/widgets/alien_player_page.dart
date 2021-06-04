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
import 'package:alienplayer4xf/main.dart';
import 'package:alienplayer4xf/widgets/seen_techs_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'alien_player_view.dart';
import 'fleet_view.dart';

class AlienPlayerPage extends StatelessWidget {
  final String title;
  final AlienPlayer alienPlayer;
  final bool showDetails;

  AlienPlayerPage({Key key, this.title, this.alienPlayer, this.showDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/smc_wing_full_2560.png",
                    bundle: DefaultAssetBundle.of(context)),
                fit: BoxFit.cover)),
        child: Consumer<GameModel>(builder: (context, game, child) {
          return Scaffold(
              backgroundColor: Colors.transparent,
              //appBar: AppBar(
              //  title: Text(title),
              //),
              body: Center(
                  child: Column(children: [
                AlienPlayerView(alienPlayer, showDetails, showActions: true),
                Expanded(
                    child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: alienPlayer.fleets.length,
                  itemBuilder: (context, index) {
                    return FleetView(alienPlayer.fleets[index]);
                  },
                ))
              ])),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add_chart),
                onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext) => SeenTechsDialog(game)),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
              bottomNavigationBar: BottomAppBar(
                  child: TextButton(
                      child: Padding(
                          padding: EdgeInsets.all(8.0), child: Text("OK")),
                      onPressed: () => Navigator.of(context).pop())));
        }));
  }
}
