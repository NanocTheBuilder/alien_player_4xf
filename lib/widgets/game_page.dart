/*
 *  Copyright (C) 2021 Balázs Péter
 *
 *  This file is part of Alien Player 4XF.
 *
 *  Alien Player 4XF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Alien Player 4XF is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Alien Player 4XF.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:alienplayer4xf/widgets/alien_player_page.dart';
import 'package:alienplayer4xf/widgets/new_game_dialog.dart';
import 'package:alienplayer4xf/widgets/settings_dialog.dart';
import 'package:alienplayer4xf/widgets/seen_techs_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_model.dart';
import '../main.dart';
import 'alien_player_view.dart';
import 'econ_phase_result_dialog.dart';

class GamePage extends StatelessWidget {
  static const MAX_TURNS = 100;
  final String title;

  GamePage(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, game, child) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          actions: [
            PopupMenuButton<MenuActions>(
                onSelected: (MenuActions action) {
                  if (action == MenuActions.settings) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            SettingsDialog(game));
                  } else if (action == MenuActions.new_game) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => NewGameDialog(game));
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MenuActions>>[
                      const PopupMenuItem<MenuActions>(
                        value: MenuActions.new_game,
                        child: Text("New Game"),
                      ),
                      const PopupMenuItem<MenuActions>(
                        value: MenuActions.settings,
                        child: Text("Settings"),
                      ),
                    ])
          ],
        ),
        body: Center(
          child: Consumer<GameModel>(builder: (context, game, child) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: game.aliens.length,
              itemBuilder: (context, index) {
                return new GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlienPlayerPage(
                                title,
                                game.aliens[index],
                                game.showDetails,
                              ))),
                  child: AlienPlayerView(game.aliens[index], game.showDetails,
                      showFleetCount: true),
                );
              },
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_chart),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext) => SeenTechsDialog(game)),
        ),
        bottomNavigationBar: BottomAppBar(
            child: TextButton(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Economic Phase ${game.currentTurn}",
                    )),
                onPressed: game.currentTurn < MAX_TURNS
                    ? () {
                        var result = game.doEconomicPhase();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EconPhaseResultDialog(
                                  game.currentTurn, result, game.showDetails);
                            });
                      }
                    : null)),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      );
    });
  }
}
