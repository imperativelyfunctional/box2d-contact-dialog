import 'package:box2d_collision_rpg_style/boomerang.dart';
import 'package:event/event.dart';

import '../cow.dart';

class BoomerangArgs extends EventArgs {
  final Boomerang boomerang;
  final bool pickupWeapon;

  BoomerangArgs(this.boomerang, this.pickupWeapon);
}

class CowArgs extends EventArgs {
  final Cow cow;

  CowArgs(this.cow);
}

class CowDialogArgs extends EventArgs {
  final bool hasWeapon;
  final Cow cow;

  CowDialogArgs(this.hasWeapon, this.cow);
}
