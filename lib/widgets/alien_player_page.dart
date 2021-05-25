import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/main.dart';
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
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(title),
            ),
            body: Center(
                child: Consumer<GameModel>(builder: (context, game, child) {
              return Column(children: [
                AlienPlayerView(alienPlayer, showDetails, showActions: true),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: alienPlayer.fleets.length,
                  itemBuilder: (context, index) {
                    return FleetView(alienPlayer.fleets[index]);
                  },
                )
              ]);
            })),
            bottomNavigationBar: BottomAppBar(
                child: TextButton(
                    child: Padding(
                        padding: EdgeInsets.all(8.0), child: Text("OK")),
                    onPressed: () => Navigator.of(context).pop()))));
  }
}
