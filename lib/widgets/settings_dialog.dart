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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../game_model.dart';

class SettingsDialog extends StatefulWidget {
  final GameModel game;

  const SettingsDialog(this.game, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SettingsState(game);
}

class SettingsState extends State<SettingsDialog> {
  late final GameModel game;
  late bool hideCps;

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
            onChanged: (value) => setState(() => hideCps = value!),

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
