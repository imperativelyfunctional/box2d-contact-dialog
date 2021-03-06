import 'dart:async' as async;
import 'dart:math';

import 'package:box2d_collision_rpg_style/boomerang.dart';
import 'package:box2d_collision_rpg_style/border.dart';
import 'package:box2d_collision_rpg_style/callbacks/boomerang_player.dart';
import 'package:box2d_collision_rpg_style/callbacks/eventargs.dart';
import 'package:box2d_collision_rpg_style/cow.dart';
import 'package:box2d_collision_rpg_style/dialog/game_dialog.dart';
import 'package:box2d_collision_rpg_style/player.dart';
import 'package:event/event.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/forge2d_camera.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiled/tiled.dart';

import 'callbacks/boomerang_cow.dart';
import 'callbacks/player_cow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(GameWidget(
    game: Box2dCollisionDemo(),
  ));
}

const scaleFactor = 10.0;
const double mapHeight = 320;
const double velocity = 20;

final boomerangHitPlayerEvents = Event<BoomerangArgs>();
final boomerangHitCowEvents = Event<CowArgs>();
final playerHitCowEvents = Event<CowDialogArgs>();

class Box2dCollisionDemo extends Forge2DGame
    with HasKeyboardHandlerComponents, HasTappables {
  Box2dCollisionDemo() : super(gravity: Vector2(0, 0), zoom: scaleFactor);

  late Player player;
  double x = 0;
  double y = 160;

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (player.hasWeapon) {
      var current2 = player.playerSprite.current;
      switch (current2) {
        case PlayerDirection.down:
          {
            add(Boomerang(player.body.position, 10, Vector2(0, 20), player));
            break;
          }
        case PlayerDirection.up:
          {
            add(Boomerang(player.body.position, 10, Vector2(0, -20), player));
            break;
          }
        case PlayerDirection.left:
          {
            add(Boomerang(player.body.position, 10, Vector2(-20, 0), player));
            break;
          }
        default:
          {
            add(Boomerang(player.body.position, 10, Vector2(20, 0), player));
            break;
          }
      }
    }
    super.onTapDown(pointerId, info);
  }

  @override
  Future<void> onLoad() async {
    boomerangHitPlayerEvents.subscribe((BoomerangArgs? args) {
      var boomerang = args!.boomerang;
      if (args.pickupWeapon) {
        player.hasWeapon = true;
        player.showFoundBoomerangDialog();
        boomerang.removeFromParent();
      } else {
        boomerang.removeFromParent();
      }
    });

    boomerangHitCowEvents.subscribe((CowArgs? args) {
      var cow = args!.cow;
      cow.removeFromParent();
    });

    playerHitCowEvents.subscribe((args) {
      args!.cow.showDialog(player.hasWeapon);
    });

    addContactCallback(BoomerangPlayerCallback());
    addContactCallback(BoomerangCowCallback());
    addContactCallback(PlayerCowCallback());
    var effectiveSize = camera.viewport.effectiveSize;
    camera.viewport = FixedResolutionViewport(
        Vector2(effectiveSize.x * mapHeight / effectiveSize.y, mapHeight));
    var map =
        await TiledComponent.load('level.tmx', Vector2.all(16 / scaleFactor));
    add(map);
    var positions = (map.tileMap.getLayer('positions') as ObjectGroup).objects;
    for (var element in positions) {
      if (element.type == 'spawn') {
        var position = Vector2(element.x, element.y) / scaleFactor;
        player = Player(position)..priority = 1;
        await add(player);
        camera.followBodyComponent(player);
      } else if (element.type == 'cow_spawn_small') {
        add(Cow(Vector2(element.x, element.y) / scaleFactor));
      } else if (element.type == 'cow_moving') {
        add(Cow(Vector2(element.x, element.y) / scaleFactor));
      } else if (element.type == 'boomerang') {
        add(Boomerang(Vector2(element.x, element.y) / scaleFactor, 0,
            Vector2.zero(), null));
      } else {
        add(Cow(Vector2(element.x, element.y) / scaleFactor));
      }
    }

    var borders = (map.tileMap.getLayer('borders') as ObjectGroup).objects;
    for (var element in borders) {
      var width = element.width / scaleFactor;
      var height = element.height / scaleFactor;
      var x = element.x / scaleFactor;
      var y = element.y / scaleFactor;
      final start = Vector2(x, y);
      var paint = Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2;
      element.type.split('_').forEach((side) {
        switch (side) {
          case 'top':
            {
              add(Boundary(start, Vector2(x + width, y), paint: paint));
              break;
            }
          case 'bottom':
            {
              add(Boundary(
                  start + Vector2(0, height), Vector2(x + width, y + height),
                  paint: paint));
              break;
            }
          case 'left':
            {
              add(Boundary(start, Vector2(x, y + height), paint: paint));
              break;
            }
          case 'right':
            {
              add(Boundary(
                  start + Vector2(width, 0), Vector2(x + width, y + height),
                  paint: paint));
              break;
            }
          default:
            {
              break;
            }
        }
      });
    }
    Random random = Random();
    async.Timer.periodic(const Duration(seconds: 1), (timer) {
      add(ParticleSystemComponent(
          particle: Particle.generate(
              count: 100,
              lifespan: 10,
              generator: (i) {
                return TranslatedParticle(
                    offset: Vector2(random.nextInt(1760).toDouble(),
                            random.nextInt(320).toDouble()) /
                        scaleFactor,
                    child: AcceleratedParticle(
                      speed: Vector2(0, random.nextInt(10).toDouble()),
                      child: CircleParticle(
                          radius: random.nextDouble().clamp(0.2, 0.23),
                          paint: Paint()
                            ..color = Colors.white.withAlpha(
                                (255 * random.nextDouble()).toInt())),
                    ));
              }))
        ..position = Vector2.zero());
    });

    async.Timer(const Duration(seconds: 1), () {
      player.showInitialDialog();
    });
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    var playerSprite = player.playerSprite;
    if (keysPressed.isNotEmpty) {
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        playerSprite.current = PlayerDirection.left;
        player.body.linearVelocity = Vector2(-velocity, 0);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        playerSprite.current = PlayerDirection.right;
        player.body.linearVelocity = Vector2(velocity, 0);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        playerSprite.current = PlayerDirection.up;
        player.body.linearVelocity = Vector2(0, -velocity);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        playerSprite.current = PlayerDirection.down;
        player.body.linearVelocity = Vector2(0, velocity);
      }
    } else {
      player.body.linearVelocity = Vector2(0, 0);
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
