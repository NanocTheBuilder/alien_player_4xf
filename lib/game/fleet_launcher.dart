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

import 'alien_player.dart';
import 'enums.dart';
import 'fleet.dart';
import 'game.dart';

class FleetLauncher {
    Game game;
    
    FleetLauncher(this.game);

    Fleet? rollFleetLaunch(AlienPlayer ap, int turn) {
        int roll = getFleetLaunchRoll(ap);
        if (roll <= ap.economicSheet.getFleetLaunch(turn)) {
            return launchFleet(ap, turn);
        }
        return null;
    }

    Fleet? launchFleet(AlienPlayer ap, int turn, [List<FleetBuildOption> options = const[]]) {
        if (ap.economicSheet.fleetCP >= ShipType.SCOUT.cost) {
            Fleet fleet = Fleet.ofAlienPlayer(ap, FleetType.REGULAR_FLEET, ap.economicSheet.fleetCP);
            if (shouldLaunchRaiderFleet(ap, options)) {
                fleet.setFleetType(ap, FleetType.RAIDER_FLEET);
                game.scenario.buildFleet(ap, fleet);
            }
            int cpSpent = fleet.fleetType == FleetType.RAIDER_FLEET ? fleet.buildCost : fleet.fleetCP;
            ap.economicSheet.spendFleetCP(cpSpent);
            return fleet;
        }
        return null;
    }

    int getFleetLaunchRoll(AlienPlayer ap) {
        int roll = game.roller.roll();
        if ((ap.economicSheet.fleetCP >= 27
                && ap.getLevel(Technology.FIGHTERS) > game.getSeenLevel(Technology.POINT_DEFENSE))
                || shouldLaunchRaiderFleet(ap))
            roll -= 2;
        return roll;
    }

    bool shouldLaunchRaiderFleet(AlienPlayer ap, [List<FleetBuildOption> options = const[]]) {
        if(options.contains(FleetBuildOption.HOME_DEFENSE))
            return false;
        return ap.economicSheet.fleetCP >= ShipType.RAIDER.cost
                && ap.getLevel(Technology.CLOAKING) > game.getSeenLevel(Technology.SCANNER);
    }

}