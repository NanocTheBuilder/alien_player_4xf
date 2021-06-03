import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenario.dart';
import 'package:alienplayer4xf/main.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';

class NewGameDialog extends StatefulWidget {
  final GameModel game;

  const NewGameDialog(this.game, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewGameDialogState(game);
}

class NewGameDialogState extends State<NewGameDialog> {
  final GameModel game;
  Type scenario;
  //Function<Scenario>() constuctor;
  Difficulty difficulty;
  List<PlayerColor> playerColors;
  bool green, yellow, red, blue;

  NewGameDialogState(this.game);
  @override
  void initState() {
    super.initState();
    scenario = game.scenario.runtimeType;
    difficulty = game.difficulty;
    initCheckboxes();
  }

  void initCheckboxes() {
    green = game.aliens.where((a) => a.color == PlayerColor.GREEN).isNotEmpty;
    yellow = game.aliens.where((a) => a.color == PlayerColor.YELLOW).isNotEmpty;
    red = game.aliens.where((a) => a.color == PlayerColor.RED).isNotEmpty;
    blue = game.aliens.where((a) => a.color == PlayerColor.BLUE).isNotEmpty;
  }

  void updateCheckboxes(Difficulty difficulty) {
    green = difficulty.numberOfAlienPlayers > 0;
    yellow = difficulty.numberOfAlienPlayers > 1;
    red = difficulty.numberOfAlienPlayers > 2;
    blue = difficulty.numberOfAlienPlayers > 3;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //insetPadding: EdgeInsets.symmetric(horizontal: 4.0),
      title: Text("Start New Game"),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton(
              value: scenario,
              items: Strings.scenarioBuildData.entries
                  .map((entry) => DropdownMenuItem(
                        child: Text(entry.value.name),
                        value: entry.key,
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                scenario = value;
                updateDifficulty(
                    Strings.scenarioBuildData[value].normalDifficulty);
              }),
            ),
            DropdownButton(
              value: difficulty,
              items: Strings.scenarioBuildData[scenario].difficulties
                  .map((e) => DropdownMenuItem(
                        child: Text(Strings.difficulties[e.name]),
                        value: e,
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                updateDifficulty(value);
              }),
            ),
            Row(
              children: [
                playerCheckbox(PlayerColor.GREEN, green, () => green = !green),
                playerCheckbox(
                    PlayerColor.YELLOW, yellow, () => yellow = !yellow),
                playerCheckbox(PlayerColor.RED, red, () => red = !red),
                playerCheckbox(PlayerColor.BLUE, blue, () => blue = !blue),
              ],
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: Text('OK'),
          onPressed: valid()
              ? () {
                  Navigator.of(context).pop();
                  game.newGame(
                      Strings.scenarioBuildData[scenario].constructor.call(),
                      difficulty,
                      selectedPlayers());
                }
              : null,
        ),
      ],
    );
  }

  void updateDifficulty(value) {
    difficulty = value;
    updateCheckboxes(difficulty);
  }

  bool valid() {
    return selectedPlayers().length == difficulty.numberOfAlienPlayers;
  }

  List<PlayerColor> selectedPlayers(){
    List<PlayerColor> selectedPlayers = [];
    if(green) selectedPlayers.add(PlayerColor.GREEN);
    if(yellow) selectedPlayers.add(PlayerColor.YELLOW);
    if(red) selectedPlayers.add(PlayerColor.RED);
    if(blue) selectedPlayers.add(PlayerColor.BLUE);
    return selectedPlayers;
  }

  Widget playerCheckbox(
      PlayerColor playerColor, bool value, bool setStateFn()) {
    return Expanded(
        child: InkWell(
            onTap: () {
              return setState(setStateFn);
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? PlayerColors[playerColor] : Colors.grey),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: value
                    ? Icon(
                        Icons.check,
                        size: 30.0,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.block,
                        size: 30.0,
                        color: PlayerColors[playerColor],
                      ),
              ),
            )));
  }
}
