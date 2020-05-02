import 'alien_economic_sheet.dart';
import 'alien_player.dart';
import 'enums.dart';
import 'fleet.dart';
import 'game.dart';

class FleetLauncher {
    Game game;
    
    FleetLauncher(this.game);

    Fleet rollFleetLaunch(AlienPlayer ap, int turn) {
        int roll = getFleetLaunchRoll(ap);
        if (roll <= ap.economicSheet.getFleetLaunch(turn)) {
            return launchFleet(ap, turn);
        }
        return null;
    }

    Fleet launchFleet(AlienPlayer ap, int turn, [List<FleetBuildOption> options]) {
        if (ap.economicSheet.fleetCP >= ShipType.SCOUT.cost) {
            Fleet fleet = Fleet(ap, FleetType.REGULAR_FLEET, ap.economicSheet.fleetCP);
            if (shouldLaunchRaiderFleet(ap, options)) {
                fleet.fleetType = FleetType.RAIDER_FLEET;
                game.scenario.buildFleet(fleet);
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

    bool shouldLaunchRaiderFleet(AlienPlayer ap, [List<FleetBuildOption> options = const []]) {
        if(options.contains(FleetBuildOption.HOME_DEFENSE))
            return false;
        return ap.economicSheet.fleetCP >= ShipType.RAIDER.cost
                && ap.getLevel(Technology.CLOAKING) > game.getSeenLevel(Technology.SCANNER);
    }

}