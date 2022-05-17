import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Boomerang extends BodyComponent {
  final Vector2 position;
  final double distance;
  final Vector2 velocity;
  final BodyComponent? target;
  bool outgoing = true;

  Boomerang(this.position, this.distance, this.velocity, this.target);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    var spriteComponent = SpriteComponent(
        anchor: Anchor.center,
        sprite: await gameRef.loadSprite('bmr.png',
            srcPosition: Vector2.zero(), srcSize: Vector2(23, 24)))
      ..size = Vector2(23 / (scaleFactor * 3), 24 / (scaleFactor * 3));
    await add(spriteComponent);
    body.setFixedRotation(true);
    if (target == null) {
      spriteComponent.add(SequenceEffect([
        ColorEffect(Colors.amberAccent, const Offset(0.3, 0.7),
            EffectController(duration: 1, infinite: true, reverseDuration: 1)),
        ColorEffect(Colors.lightGreenAccent, const Offset(0.1, 0.4),
            EffectController(duration: 1, infinite: true, reverseDuration: 1))
      ], infinite: true));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (target != null) {
      var first = children.first;
      if (first.children.isEmpty) {
        first.add(RotateEffect.by(
            2 * pi,
            EffectController(
              infinite: true,
              duration: 0.3,
            )));
      }
      if (outgoing && body.position.distanceTo(position) < distance) {
        body.linearVelocity = velocity;
      } else {
        outgoing = false;
        moveAlongLine(body.position, target!.body.position, 16);
      }
    }
  }

  moveAlongLine(Vector2 source, Vector2 target, double speed) {
    var v = target.y - source.y;
    var h = target.x - source.x;
    var distance = sqrt(pow(v, 2) + pow(h, 2));
    body.linearVelocity = Vector2(h / distance, v / distance) * speed;
  }

  @override
  Body createBody() {
    var bodyDef = BodyDef();
    bodyDef.position.setFrom(position);
    bodyDef.type = BodyType.dynamic;
    bodyDef.userData = this;

    var bodyFixtureDef = FixtureDef(PolygonShape()
      ..setAsBox(
          4 / scaleFactor, 4 / scaleFactor, Vector2(0, 0) / scaleFactor, 0))
      ..restitution = 0
      ..friction = 0
      ..isSensor = true
      ..density = 0;
    var body = world.createBody(bodyDef);
    body.createFixture(bodyFixtureDef);
    return body;
  }
}
