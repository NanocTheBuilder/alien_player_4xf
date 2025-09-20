/*
 *  Copyright (C) 2021 Balázs Péter
 *
 *  This file is part of Alien Player 4X.
 *
 *  Alien Player 4XF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Alien Player 4X is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Alien Player 4X.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/widgets/main_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game_model.dart';

const Map PlayerColors = {
  PlayerColor.RED: Color.fromARGB(255, 255, 98, 56),
  PlayerColor.GREEN: Color.fromARGB(255, 33, 227, 47),
  PlayerColor.BLUE: Color.fromARGB(255, 41, 222, 255),
  PlayerColor.YELLOW: Color.fromARGB(255, 255, 255, 0),
};

enum MenuActions { new_game, settings }

void main() {
  runApp(ChangeNotifierProvider<GameModel>(
      create: (context) => GameModel(), child: MyApp()));

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Alien Player 4X App',
        theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              bodyMedium: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium!.fontSize! * 1.3),
              labelLarge: TextStyle(
                  fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! * 1.3),
            )),
        home: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/smc_wing_full_2560.png",
                      bundle: DefaultAssetBundle.of(context)),
                  fit: BoxFit.cover)),
          child: MainMenuPage(),
        ));
  }
}
