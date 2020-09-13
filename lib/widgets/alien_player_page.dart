import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'alien_player_view.dart';

class AlienPlayerPage extends StatelessWidget {
  final String title;
  final AlienPlayer alienPlayer;

  AlienPlayerPage({Key key, this.title, this.alienPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(children: [
          AlienPlayerView(alienPlayer),
          ListView.builder(
            shrinkWrap: true,
            itemCount: alienPlayer.fleets.length,
            itemBuilder: (context, index){
              return Container(
                color: PlayerColors[alienPlayer.color],
                child: Text("${alienPlayer.fleets[index].fleetType.name} ${alienPlayer.fleets[index].name}"),
              );
            },
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"))
        ])));
  }
}
