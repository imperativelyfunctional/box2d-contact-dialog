import 'package:box2d_collision_rpg_style/dialog/game_dialog.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/particles.dart' as fp;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'main.dart';

enum PlayerDirection {
  up,
  down,
  left,
  right,
}

const halfBodyWidth = 8;
const halfBodyHeight = 9;

class Player extends BodyComponent {
  final Vector2 position;
  late PlayerSprite playerSprite;
  bool hasWeapon = false;

  Player(this.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    playerSprite = PlayerSprite(size: Vector2(48, 48) / scaleFactor)
      ..anchor = Anchor.center;
    add(playerSprite);
    body.setFixedRotation(true);
  }

  void showInitialDialog() {
    gameRef.add(GameDialog('''大雪紛飛，飢腸轆轆。
肥牛遍野，供我享用。''', Colors.black.withOpacity(0.4),
        Colors.amberAccent.withOpacity(0.8), 4)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(
              (body.position.x - camera.position.x),
              (body.position.y -
                  camera.position.y -
                  halfBodyHeight / scaleFactor)) *
          scaleFactor
      ..positionType = PositionType.viewport);
  }

  void showFoundBoomerangDialog() {
    gameRef.add(GameDialog('''庖丁解牛時應該用的就是這把刀！''', Colors.black.withOpacity(0.4),
        Colors.amberAccent.withOpacity(0.8), 2)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(
              (body.position.x - camera.position.x),
              (body.position.y -
                  camera.position.y -
                  halfBodyHeight / scaleFactor)) *
          scaleFactor
      ..positionType = PositionType.viewport);
  }

  @override
  Body createBody() {
    var bodyDef = BodyDef();
    bodyDef.position.setFrom(position);
    bodyDef.type = BodyType.dynamic;
    bodyDef.userData = this;

    var bodyFixtureDef = FixtureDef(PolygonShape()
      ..setAsBox(halfBodyWidth / scaleFactor, halfBodyHeight / scaleFactor,
          Vector2(0, 0) / scaleFactor, 0))
      ..restitution = 0
      ..friction = 0
      ..density = 0;
    var body = world.createBody(bodyDef);
    body.createFixture(bodyFixtureDef);
    return body;
  }

  @override
  void update(double dt) async {
    super.update(dt);
    var linearVelocity = body.linearVelocity;
    var horizontalVelocity = linearVelocity.x;
    var verticalVelocity = linearVelocity.y;
    if (horizontalVelocity > 0) {
      await _addFollowers(PlayerDirection.right);
    }
    if (horizontalVelocity < 0) {
      await _addFollowers(PlayerDirection.left);
    }
    if (verticalVelocity > 0) {
      await _addFollowers(PlayerDirection.down);
    }
    if (verticalVelocity < 0) {
      await _addFollowers(PlayerDirection.up);
    }
  }

  _addFollowers(PlayerDirection direction) async {
    final Sprite sprite;
    switch (direction) {
      case PlayerDirection.down:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 0), srcSize: Vector2(48, 48));
          break;
        }
      case PlayerDirection.up:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48), srcSize: Vector2(48, 48));
          break;
        }
      case PlayerDirection.left:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48 * 2), srcSize: Vector2(48, 48));
          break;
        }
      default:
        {
          sprite = await gameRef.loadSprite('main.png',
              srcPosition: Vector2(0, 48 * 2), srcSize: Vector2(48, 48));
          break;
        }
    }
    sprite.paint = Paint()
      ..color = Colors.amber.withOpacity(0.4)
      ..blendMode = BlendMode.darken;

    gameRef.add(
        ParticleSystemComponent(particle: trailParticles(sprite, direction))
          ..position = body.position);
  }

  fp.Particle trailParticles(Sprite sprite, PlayerDirection direction) {
    const count = 3;
    const rowHeight = 0.3;
    const columnWidth = 0.3;

    return fp.Particle.generate(
      count: count,
      lifespan: 0.1,
      generator: (i) => TranslatedParticle(
        offset: Vector2(
          (direction == PlayerDirection.left ||
                  direction == PlayerDirection.right)
              ? (i % count) *
                  columnWidth *
                  ((direction == PlayerDirection.right) ? -1 : 1)
              : 0,
          (direction == PlayerDirection.up || direction == PlayerDirection.down)
              ? (i % count) *
                  rowHeight *
                  ((direction == PlayerDirection.down) ? -1 : 1)
              : 0,
        ),
        child: SpriteParticle(
          size: Vector2(2.8, 3.2),
          sprite: sprite,
        ),
      ),
    );
  }
}

class PlayerSprite extends SpriteAnimationGroupComponent<PlayerDirection>
    with HasGameRef {
  PlayerSprite({
    required Vector2 size,
  }) : super(size: size);

  @override
  Future<void>? onLoad() async {
    anchor = Anchor.center;
    final down = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 0),
        amount: 4,
        textureSize: Vector2(48, 48),
        stepTime: 0.3,
        loop: true,
      ),
    );

    final up = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        texturePosition: Vector2(0, 48),
        amount: 4,
        textureSize: Vector2(48, 48),
        stepTime: 0.3,
        loop: true,
      ),
    );

    final left = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(48, 48),
        texturePosition: Vector2(0, 96),
        stepTime: 0.3,
      ),
    );

    final right = await gameRef.loadSpriteAnimation(
      'character.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(48, 48),
        texturePosition: Vector2(0, 144),
        stepTime: 0.3,
        loop: true,
      ),
    );

    animations = {
      PlayerDirection.up: up,
      PlayerDirection.down: down,
      PlayerDirection.left: left,
      PlayerDirection.right: right,
    };
    current = PlayerDirection.right;
    return super.onLoad();
  }
}
