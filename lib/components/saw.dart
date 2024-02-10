import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final bool isVertical;
  final double offNet;
  final double offPos;

  Saw({
    this.isVertical = false,
    this.offNet = 0,
    this.offPos = 0,
    position,
    size,
  }) : super(
          position: position,
          size: size,
        );

  static const double stepTime = 0.3; // Velocidade da animação

  @override
  FutureOr<void> onLoad() {
    priority = -1;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }
}
