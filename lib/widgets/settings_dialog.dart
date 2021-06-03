import 'package:alienplayer4xf/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final GameModel game;

  const SettingsDialog(this.game, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsState(game);
}

class SettingsState extends State<SettingsDialog> {
  final GameModel game;
  bool hideCps;

  SettingsState(this.game);

  @override
  void initState() {
    super.initState();
    hideCps = !game.showDetails;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Settings"),
      content: CheckboxListTile(
            title: Text("Hide CPs"),
            subtitle: Text(
                "Hide the AP's current CPs and the CP values of unrevealed fleets"),
            value: hideCps,
            onChanged: (value) => setState(() => hideCps = value),

          //         ),
          ),
      actions: <Widget>[
        TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            game.showDetails = !hideCps;
            game.finishUpdate();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
