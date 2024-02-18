import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure_flame/components/checkpoint.dart';
import 'package:pixel_adventure_flame/components/collision_block.dart';
import 'package:pixel_adventure_flame/components/custom_hitbox.dart';
import 'package:pixel_adventure_flame/components/fruit.dart';
import 'package:pixel_adventure_flame/components/saw.dart';
import 'package:pixel_adventure_flame/components/utils.dart';
import 'package:pixel_adventure_flame/enum/player_state_enum.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class PlayerModel extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;

  PlayerModel({
    this.character = 'Ninja Frog',
    position,
  }) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation dessapearningAnimation;

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox get hitbox => CustomHitbox(
        offsetX: 10,
        offsetY: 4,
        width: 14,
        height: 28,
      );

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true;

    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
      // anchor: Anchor.center,
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit && !reachedCheckpoint) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollision();
      _applyGravity(dt);
      _checkVerticalCollisions();
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidinWithPlayer();

      if (other is Saw) _respawn();

      if (other is Checkpoint) _reachedCheckpoint();
    }

    super.onCollision(intersectionPoints, other);
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

    jumpingAnimation = _spriteAnimation(
      state: "Jump",
      amount: 1,
    );

    fallingAnimation = _spriteAnimation(
      state: "Fall",
      amount: 1,
    );

    hitAnimation = _spriteAnimation(
      state: "Hit",
      amount: 7,
    );

    appearingAnimation = _specialSpriteAnimation(
      state: "Appearing",
      amount: 7,
    );

    dessapearningAnimation = _specialSpriteAnimation(
      state: "Desappearing",
      amount: 7,
    );

    animations = {
      PlayerStateEnum.idle: idleAnimation,
      PlayerStateEnum.running: runningAnimation,
      PlayerStateEnum.jumping: jumpingAnimation,
      PlayerStateEnum.falling: fallingAnimation,
      PlayerStateEnum.hit: hitAnimation,
      PlayerStateEnum.appearing: appearingAnimation,
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

  SpriteAnimation _specialSpriteAnimation({required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$state (96x96).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerStateEnum playerStateEnum = PlayerStateEnum.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerStateEnum = PlayerStateEnum.running;

    if (velocity.y > 0) playerStateEnum = PlayerStateEnum.falling;

    if (velocity.y < 0) playerStateEnum = PlayerStateEnum.jumping;

    current = playerStateEnum;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    // if (velocity.y > _gravity) isOnGround = false; // isso impede o personagem de pular enquanto cai

    velocity.x = horizontalMovement * moveSpeed;

    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() {
    const Duration hitDuration = Duration(milliseconds: 50 * 7); // 50ms * 7 frames
    const Duration appearingDuration = Duration(milliseconds: 50 * 7);
    const Duration canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    // position = startingPosition;
    current = PlayerStateEnum.hit;

    Future.delayed(hitDuration, () {
      scale.x = 1; // Reset the scale - Se tomar dano, independente da direção, o personagem sempre vai olhar para a direita

      position = startingPosition;
      current = PlayerStateEnum.appearing;

      Future.delayed(appearingDuration, () {
        position = startingPosition;
        _updatePlayerState();

        Future.delayed(canMoveDuration, () {
          gotHit = false;
        });
        // position = startingPosition;
        // current = PlayerStateEnum.idle;
      });
    });
  }

  void _reachedCheckpoint() {
    reachedCheckpoint = true;

    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else if (scale.x < 0) {
      position = position + Vector2(32, -32);
    }

    current = PlayerStateEnum.desappearing;
    // const Duration appearingDuration = Duration(milliseconds: 50 * 7);
    // Future.delayed(appearingDuration, () {
    //   current = PlayerStateEnum.idle;
    // });

    const Duration reachedCheckpointDuration = Duration(milliseconds: 50 * 7);

    Future.delayed(reachedCheckpointDuration, () {
      reachedCheckpoint = false;
      position = position + Vector2.all(-640);

      const Duration waitToChange = Duration(seconds: 3);
      Future.delayed(waitToChange, () {
        // switchLevel
        game.loadNextLevel();
      });
    });
  }
}
