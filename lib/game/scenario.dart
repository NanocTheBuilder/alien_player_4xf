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

import 'package:alienplayer4xf/game/technology_buyer.dart';

import 'alien_player.dart';
import 'enums.dart';
import 'fleet.dart';
import 'fleet_builders.dart';
import 'fleet_launcher.dart';
import 'game.dart';

abstract class Scenario{
    TechnologyBuyer techBuyer;
    TechnologyPrices techPrices;
    FleetBuilder fleetBuilder;
    DefenseBuilder defenseBuilder;
    FleetLauncher fleetLauncher;

    void init(Game game);

    AlienPlayer newPlayer(Game game, Difficulty difficulty, PlayerColor color);

    //List<Difficulty> get difficulties;

    List<Technology> get availableTechs => techPrices.availableTechs;

    int getStartingLevel(Technology technology) {
        return techPrices.getStartingLevel(technology);
    }

    void buildFleet(Fleet fleet, [List<FleetBuildOption> options]) {
        fleetBuilder.buildFleet(fleet, options);
    }

    Fleet buildHomeDefense(AlienPlayer alienPlayer) {
        return defenseBuilder.buildHomeDefense(alienPlayer);
    }

    void buyNextLevel(AlienPlayer alienPlayer, Technology technology) {
        techBuyer.buyNextLevel(alienPlayer, technology);
    }

    void buyTechs(Fleet fleet, [List<FleetBuildOption> options]) {
        techBuyer.buyTechs(fleet, options);
    }

    int getCost(Technology technology, int level) {
        return techPrices.getCost(technology, level);
    }

    int getMaxLevel(Technology technology) {
        return techPrices.getMaxLevel(technology);
    }

    Fleet rollFleetLaunch(AlienPlayer alienPlayer, int turn){
        return fleetLauncher.rollFleetLaunch(alienPlayer, turn);
    }
}