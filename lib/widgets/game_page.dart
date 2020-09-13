import 'package:alienplayer4xf/widgets/alien_player_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'alien_player_view.dart';
import 'econ_phase_result_dialog.dart';

class GamePage extends StatelessWidget {
   final String title;

   GamePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
            child: Column(
            children: [
              Consumer<GameModel>(builder: (context, game, child) {
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: game.aliens.length,
                    itemBuilder: (context, index) {
                      return new GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AlienPlayerPage(title: title, alienPlayer: game.aliens[index]))),
                        child: AlienPlayerView(game.aliens[index]),
                      );
                    },
                );
              }),
              Consumer<GameModel>(builder: (context, game, child) {
                return FlatButton(
                    child: Text("Economic Phase ${game.currentTurn}"),
                    onPressed: () {
                      var result = game.doEconomicPhase();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EconPhaseResultDialog(game.currentTurn,
                                result);
                          });
                    });
              },
              ),
            ]
        )
        )
    );
    // This trailing comma makes auto-formatting nicer for build methods.
  }
}