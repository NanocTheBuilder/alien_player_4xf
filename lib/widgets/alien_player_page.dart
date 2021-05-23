import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'alien_player_view.dart';

class AlienPlayerPage extends StatelessWidget {
  final String title;
  final AlienPlayer alienPlayer;
  final bool showDetails;

  AlienPlayerPage({Key key, this.title, this.alienPlayer, this.showDetails}) : super(key: key);

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
                child: Column(children: [
              AlienPlayerView(alienPlayer, showDetails),
              ListView.builder(
                shrinkWrap: true,
                itemCount: alienPlayer.fleets.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: PlayerColors[alienPlayer.color],
                    child: Text(
                        "${alienPlayer.fleets[index].fleetType.name} ${alienPlayer.fleets[index].name}"),
                  );
                },
              ),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"))
            ]))));
  }
}
