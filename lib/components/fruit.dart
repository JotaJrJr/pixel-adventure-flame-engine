import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_flame/components/custom_hitbox.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final String fruit;

  Fruit({
    this.fruit = 'Apple',
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  final double stepTime = 0.05;

  final CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 10,
    width: 12,
    height: 12,
  );

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    priority = -1;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
    return super.onLoad();
  }
}