import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'dialog/game_dialog.dart';
import 'main.dart';

enum CowState {
  idle,
  walk,
}

class Cow extends BodyComponent {
  final Vector2 position;
  late CowSprite cowSprite;

  Cow(this.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    cowSprite = CowSprite(size: Vector2(32, 32) / scaleFactor)
      ..anchor = Anchor.center;
    add(cowSprite);
    body.setFixedRotation(true);
  }

  showDialog(bool hasWeapon) {
    var message = '''不要碰我，我是瘋牛！''';
    if (hasWeapon) {
      message = '''老牛跪謝，不殺之恩！''';
    }
    gameRef.add(GameDialog(message, Colors.deepPurpleAccent.withOpacity(0.4),
        Colors.lightGreenAccent.withOpacity(0.8), 1)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2((body.position.x - camera.position.x),
              (body.position.y - camera.position.y - 10 / scaleFactor)) *
          scaleFactor
      ..positionType = PositionType.viewport);
  }

  @override
  Body createBody() {
    var bodyDef = BodyDef();
    bodyDef.position.setFrom(position);
    bodyDef.type = BodyType.kinematic;
    bodyDef.userData = this;

    var bodyFixtureDef = FixtureDef(PolygonShape()
      ..setAsBox(
          12 / scaleFactor, 10 / scaleFactor, Vector2(0, 4) / scaleFactor, 0))
      ..restitution = 0
      ..friction = 0
      ..density = 0;
    var body = world.createBody(bodyDef);
    body.createFixture(bodyFixtureDef);
    return body;
  }
}

class CowSprite extends SpriteAnimationGroupComponent<CowState>
    with HasGameRef {
  CowSprite({
    required Vector2 size,
  }) : super(size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    final idle = await gameRef.loadSpriteAnimation(
      'cow.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 0),
        amount: 3,
        textureSize: Vector2(32, 32),
        stepTime: 0.3,
        loop: true,
      ),
    );

    final walk = await gameRef.loadSpriteAnimation(
      'cow.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 32),
        amount: 2,
        textureSize: Vector2(32, 32),
        stepTime: 0.3,
        loop: true,
      ),
    );

    animations = {
      CowState.idle: idle,
      CowState.walk: walk,
    };
    current = CowState.idle;
    return super.onLoad();
  }
}
