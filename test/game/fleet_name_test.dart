import 'package:alienplayer4xf/game/alien_player.dart';
import 'package:alienplayer4xf/game/enums.dart';
import 'package:alienplayer4xf/game/fleet.dart';
import 'package:test/test.dart';

void main(){
  var ap = AlienPlayer();

  test('First fleet is called One, second is two', () {
    var fleet = Fleet(ap, FleetType.REGULAR_FLEET);
    expect(fleet.name, "1");
    fleet = Fleet(ap, FleetType.REGULAR_FLEET);
    expect(fleet.name, "2");
  });
}
