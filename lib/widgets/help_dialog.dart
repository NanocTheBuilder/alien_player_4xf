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

import 'package:flutter/material.dart';


class HelpDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Help"),
      //RichText(
      //   text: TextSpan(
      //     text: 'Hello ',
      //     style: DefaultTextStyle.of(context).style,
      //     children: const <TextSpan>[
      //       TextSpan(text: 'bold', style: TextStyle(fontWeight: FontWeight.bold)),
      //       TextSpan(text: ' world!'),
      //     ],
      //   ),
      // )
      content: SingleChildScrollView(

        child:
          RichText(
            text: TextSpan(
              text:
                  """
This is not a game. This is a companion app for Space Empires 4X board game.
If you don't have Space Empires 4X, you can't use this app.
If you do have Space Empires 4X, you can use this app to help running the Alien Players in Solitaire and Co-op scenarios. You won't need the Alien Economic Sheets and the Alien Player Flow Charts, the app will calculate everything for you.
""",
        children: const <TextSpan>[
          TextSpan( text:"""

Starting a new game
            """,style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan( text:"""

On the main menu, select "New Game". Select the scenario you want to play, then the difficulty. Finally, select which colors should be used by the Alien Players, then click "Start"
            """),
          TextSpan( text:"""

Resuming an old game
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

If the previous game was not finished, you can continue it by clicking "Resume"
            """),
          TextSpan( text:"""

Settings
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

There is one setting in the app: Hide CPs. If you uncheck it, then the app will show the current CP values of each Alien Player, and the CP sizes of the fleets. If you check "Hide CPs", then the CP values will be hidden, adding an extra layer of uncertainty to the game.
            """),
          TextSpan( text:"""

Main view
            """,style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan( text:"""

The app is currently optimized to phones. The main view shows a list of the Alien Players, with their current technology levels, the number of fleets they have, and the number of colonies the occupy. You can click on the list to go to the Player Details view, where you can see the details of the Alien Player's fleets, and the buttons to interact with them.
            """),
          TextSpan( text:"""

Economic Phase button
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

At the bottom of the main view is the Economic Phase button. You must click on this at the end of the game round, after your economic phase. The app will make the economic rolls and fleet launch rolls for each Alien Player, and display the Economic Phase dialog.
            """),
          TextSpan( text:"""

Economic Phase dialog
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

If you unchecked "Hide CPs" in the settings, the dialog will show the added CP values for each Alien Player, and the number and size of newly launched fleets. Otherwise the dialog will only show the number of new fleets.
            """),
          TextSpan( text:"""

Fleets
            """,style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan( text:"""

Fleets are identified by fleet type and fleet number, i.e. REGULAR FLEET 1, EXPANSION FLEET 2. I suggest you use counters with the same number as the fleet number. There is a separate numbering for Regular/Expansion/Extermination fleets, one for Rider fleets and one for Defense fleets.
In case of Extermination Fleets, the fleet's target is added after the fleet name.
The app does not track individual counters. It does not take into account the number of available counters, though it is not likely to cause problems during game.
It is possible that a group has more than 6 units. In this case, you should still use the correct number of counters on the table (max 6 units in a group).
Ground units can appear in both Regular fleets and Defense fleets. If the fleet number is the same, you should use different counters for one of the fleets.
            """),
          TextSpan( text:"""

First combat
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

Before a fleet's first combat, you should click the "First combat" button (👁). The app will buy technologies and/or ships for the fleet, depending on the available CP values. In some scenarios, there will be a dialog where you must specify if the combat is above a planet, or if the enemy is a Non-player Alien fleet.
            """),
          TextSpan( text:"""

Remove fleet
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

After the last unit of a fleet is destroyed, you should click the "Remove fleet" button (🗑). This makes the fleet's number available for new fleets. You can click on the button at other times too, if you remove the counters for any reason.
            """),
          TextSpan( text:"""

Technology levels
            """,style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan( text:"""

You should always track in the app your technologies that the Alien Players has seen in combat. If the "Seen technology" box is visible in the main view, you can change the values any time. If the "Set Seen Technology Levels" button is visible on the main view, you can click on this to open the "Seen technologies" dialog.
In some scenarios, the Alien Player can steal technology from the player(s). In these scenarios, there will be a small triangle beside the Alien Player's Technology value. In this case, you can click on the technology to change the current value.
            """),
          TextSpan( text:"""

Colonies
            """, style: TextStyle(fontStyle: FontStyle.italic)),
          TextSpan( text:"""

In Victory Point scenarios you must track the number of colonies occupied by each Alien Player. You can click on the "Colonies" label to set the current number of colonies.
            """),
          TextSpan( text:"""

Defense
            """,style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan( text:"""

Click on the "Home Defense" button when you attack the home planet of an Alien Player. Click on the "Colony Defense" button when you attack an Alien Player colony. The app will buy the defense forces and/or technologies for the Alien Player.
            """),
          TextSpan( text:"""

Alien Player Elimination
            """,style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan( text:"""

Click on the "Eliminate" button (🗑) when the Alien Player is eliminated. The app will ignore the Alien in upcoming Economic Phases. The Alien Player's fleets will still be visible in the app. You can ignore them, depending on the scenario.
              """),
             ]
         ),
      ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
