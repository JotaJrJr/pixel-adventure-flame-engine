import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_flame/enum/player_state_enum.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class PlayerModel extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure> {
  String character;

  PlayerModel({required this.character, position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation(
      state: "Idle",
      amount: 11,
    );

    runningAnimation = _spriteAnimation(
      state: "Run",
      amount: 12,
    );

    animations = {
      PlayerStateEnum.idle: idleAnimation,
      PlayerStateEnum.running: runningAnimation,
    };

    current = PlayerStateEnum.idle;
  }

  SpriteAnimation _spriteAnimation({required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
