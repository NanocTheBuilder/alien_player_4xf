import 'package:alienplayer4xf/widgets/alien_player_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'alien_player_view.dart';
import 'econ_phase_result_dialog.dart';

class GamePage extends StatelessWidget {
  static const MAX_TURNS = 100;

  final String title;

  GamePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
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
                                title: title,
                                alienPlayer: game.aliens[index],
                                showDetails: game.showDetails,
                              ))),
                  child: AlienPlayerView(game.aliens[index], game.showDetails),
                );
              },
            );
          }),
        ),
        bottomNavigationBar:
            Consumer<GameModel>(builder: (context, game, child) {
          return BottomAppBar(
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
                      : null));
        }));
  }
}
