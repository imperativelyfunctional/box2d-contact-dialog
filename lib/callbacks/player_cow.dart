import 'package:box2d_collision_rpg_style/callbacks/eventargs.dart';
import 'package:box2d_collision_rpg_style/cow.dart';
import 'package:box2d_collision_rpg_style/main.dart';
import 'package:box2d_collision_rpg_style/player.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class PlayerCowCallback extends ContactCallback<Player, Cow> {
  @override
  void begin(Player a, Cow b, Contact contact) {
    playerHitCowEvents.broadcast(CowDialogArgs(a.hasWeapon, b));
  }
}
