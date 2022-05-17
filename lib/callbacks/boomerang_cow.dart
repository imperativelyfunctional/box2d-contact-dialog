import 'package:box2d_collision_rpg_style/boomerang.dart';
import 'package:box2d_collision_rpg_style/callbacks/eventargs.dart';
import 'package:box2d_collision_rpg_style/cow.dart';
import 'package:box2d_collision_rpg_style/main.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class BoomerangCowCallback extends ContactCallback<Boomerang, Cow> {
  @override
  void begin(Boomerang a, Cow b, Contact contact) {
    if (a.outgoing) {
      boomerangHitCowEvents.broadcast(CowArgs(b));
    }
  }
}
