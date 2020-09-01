import 'package:alienplayer4xf/game/dice_roller.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/game.dart';
import 'package:alienplayer4xf/game/scenarios/base_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alien Player 4X App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(title: 'Alien Player 4X Main'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Game _game = Game(BaseGameScenario(), BaseGameDifficulty.NORMAL, [PlayerColor.RED, PlayerColor.YELLOW, PlayerColor.GREEN]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _game.aliens.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 150,
              child: Row(
                  children: [
                    Expanded(flex: 1, child: Container(child: Text('Fleet CP: ${_game.aliens[index].economicSheet.fleetCP}', textAlign: TextAlign.left,))),
                    Expanded(flex: 1, child: Container(child: Text('Tech CP: ${_game.aliens[index].economicSheet.techCP}', textAlign: TextAlign.center,))),
                    Expanded(flex: 1, child: Container(child: Text('Def CP: ${_game.aliens[index].economicSheet.defCP}', textAlign: TextAlign.right,))),
                ]
              )
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){setState(() {
          _game.roller = DiceRoller();
          _game.doEconomicPhase();
        });},
        tooltip: 'Egy gomb',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
