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