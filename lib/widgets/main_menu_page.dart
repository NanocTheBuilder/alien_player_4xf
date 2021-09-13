import 'package:alienplayer4xf/widgets/settings_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_model.dart';
import 'game_page.dart';
import 'new_game_dialog.dart';

class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/smc_wing_full_2560.png",
                    bundle: DefaultAssetBundle.of(context)),
                fit: BoxFit.cover)),
        child: Consumer<GameModel>(builder: (context, game, child) {
          return Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  TextButton(
                      child: Text("Resume"),
                      onPressed: game.started
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute( //TODO NAMED ROUTE
                                  builder: (context) =>
                                      GamePage('Alien Player 4X')));
                            }
                          : null),
                  TextButton(
                      child: Text("New Game"),
                      onPressed: game.started
                          ? () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      NewGameDialog(game));
                            }
                          : null),
                  TextButton(
                      child: Text("Settings"),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                SettingsDialog(game));
                      }),
                ],
              ));
        }));
  }
}
