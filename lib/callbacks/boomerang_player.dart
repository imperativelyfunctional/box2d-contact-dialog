import 'package:box2d_collision_rpg_style/boomerang.dart';
import 'package:box2d_collision_rpg_style/callbacks/eventargs.dart';
import 'package:box2d_collision_rpg_style/main.dart';
import 'package:box2d_collision_rpg_style/player.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BoomerangPlayerCallback extends ContactCallback<Boomerang, Player> {
  @override
  void begin(Boomerang a, Player b, Contact contact) {
    if (!a.outgoing) {
      boomerangHitPlayerEvents.broadcast(BoomerangArgs(a, false));
    }
    if (a.target == null) {
      boomerangHitPlayerEvents.broadcast(BoomerangArgs(a, true));
    }
  }
}
