/*
 *  Copyright (C) 2021 Balázs Péter
 *
 *  This file is part of Alien Player 4XF.
 *
 *  Alien Player 4XF is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Alien Player 4XF is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Alien Player 4XF.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/scenarios/scenario_4.dart';
import 'package:alienplayer4xf/widgets/string_helper.dart';
import 'package:flutter/material.dart';

import '../game_model.dart';

class SeenTechsDialog extends StatefulWidget {
  final GameModel game;

  const SeenTechsDialog(this.game, {Key? key}) : super(key: key);

  @override
  SeenTechsState createState() => SeenTechsState(game);
}

class SeenTechsState extends State<SeenTechsDialog> {
  late GameModel game;
  //base
  late int cloaking, scanner, pointDefense;
  late bool fighters, mines;
  //scenario4
  late bool boardingShips, size3Ships, veterans;

  SeenTechsState(this.game);

  @override
  void initState() {
    super.initState();
    cloaking = game.getSeenLevel(Technology.CLOAKING);
    scanner = game.getSeenLevel(Technology.SCANNER);
    pointDefense = game.getSeenLevel(Technology.POINT_DEFENSE);
    fighters = game.isSeenThing(Seeable.FIGHTERS);
    mines = game.isSeenThing(Seeable.MINES);
    boardingShips = game.isSeenThing(Seeable.BOARDING_SHIPS);
    size3Ships = game.isSeenThing(Seeable.SIZE_3_SHIPS);
    veterans = game.isSeenThing(Seeable.VETERANS);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [
      Row(
        children: [
          Expanded(
              child: techDropdown(Technology.CLOAKING, cloaking,
                  (value) => setState(() => cloaking = value))),
          Expanded(
              child: techDropdown(Technology.SCANNER, scanner,
                  (value) => setState(() => scanner = value))),
        ],
      ),
      Row(
        children: [
          Expanded(
              child: seenCheckbox(Seeable.FIGHTERS, fighters,
                  (value) => setState(() => fighters = value))),
          Expanded(
              child: techDropdown(Technology.POINT_DEFENSE, pointDefense,
                  (value) => setState(() => pointDefense = value))),
        ],
      )
    ];
    if (game.scenario is Scenario4) {
      rows.add(Row(
        children: [
          Expanded(
              child: seenCheckbox(Seeable.BOARDING_SHIPS, boardingShips,
                  (value) => setState(() => boardingShips = value))),
          Expanded(
              child: seenCheckbox(Seeable.SIZE_3_SHIPS, size3Ships,
                  (value) => setState(() => size3Ships = value))),
        ],
      ));
    }
    rows.add(Row(
      children: [
        Expanded(
            child: seenCheckbox(Seeable.MINES, mines,
                (value) => setState(() => mines = value))),
        (!(game.scenario is Scenario4)
            ? Expanded(child : SizedBox(width: 0))
            : Expanded(
                child: seenCheckbox(Seeable.VETERANS, veterans,
                    (value) => setState(() => veterans = value)))),
      ],
    ));
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4.0),
      title: Text("Tech Levels & Ships Seen by AP"),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            game.setSeenLevel(Technology.CLOAKING, cloaking);
            game.setSeenLevel(Technology.SCANNER, scanner);
            game.setSeenLevel(Technology.POINT_DEFENSE, pointDefense);
            game.setSeenThing(Seeable.FIGHTERS, fighters);
            game.setSeenThing(Seeable.MINES, mines);
            game.setSeenThing(Seeable.BOARDING_SHIPS, boardingShips);
            game.setSeenThing(Seeable.SIZE_3_SHIPS, size3Ships);
            game.setSeenThing(Seeable.VETERANS, veterans);
            game.finishUpdate();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget techDropdown(
      Technology technology, int value, Function(dynamic) setStateFn) {
    return ListTile(
      title: Text(Strings.technologies[technology]!),
      trailing: DropdownButton(
        items: values(technology),
        value: value,
        onChanged: setStateFn,
      ),
    );
  }

  List<DropdownMenuItem> values(Technology technology) {
    return List.generate(game.getMaxLevel(technology) + 1, (i) => i)
        .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
        .toList();
  }

  Widget seenCheckbox(
      Seeable seeable, bool value, Function(dynamic) setStateFn) {
    return CheckboxListTile(
        title: Text(Strings.seeables[seeable]!),
        value: value,
        onChanged: setStateFn);
  }
}
