import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_flame/components/player_model.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  bool reachedCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerModel && !reachedCheckpoint) _reachedCheckpoint();

    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    const Duration flagDurationAnimation = Duration(milliseconds: 50 * 26); // 50ms * 26 frames

    Future.delayed(flagDurationAnimation, () {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: 0.05,
          textureSize: Vector2.all(64),
        ),
      );
    });
  }
}
