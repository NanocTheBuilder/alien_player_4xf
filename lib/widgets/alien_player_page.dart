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
