import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:pixel_adventure_flame/enum/player_direction_enum.dart';
import 'package:pixel_adventure_flame/enum/player_state_enum.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class PlayerModel extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  PlayerModel({required this.character, position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  final double stepTime = 0.05;

  PlayerDirectionEnum direction = PlayerDirectionEnum.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isLeftKeyPressed && isRightKeyPressed) {
      direction = PlayerDirectionEnum.none;
    } else if (isLeftKeyPressed) {
      direction = PlayerDirectionEnum.left;
    } else if (isRightKeyPressed) {
      direction = PlayerDirectionEnum.right;
    } else {
      direction = PlayerDirectionEnum.none;
    }
    return super.onKeyEvent(event, keysPressed);
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

  void _updatePlayerMovement(double dt) {
    double directionX = 0.0;

    switch (direction) {
      case PlayerDirectionEnum.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerStateEnum.running;
        directionX -= moveSpeed;

        break;
      case PlayerDirectionEnum.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerStateEnum.running;
        directionX += moveSpeed;

        break;
      case PlayerDirectionEnum.none:
        current = PlayerStateEnum.idle;

        break;

      default:
    }

    velocity = Vector2(
      directionX,
      0.0,
    );

    position.add(velocity * dt);
  }
}
