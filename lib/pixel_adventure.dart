import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure_flame/enum/level_enum.dart';
import 'package:pixel_adventure_flame/enum/player_character_enum.dart';
import 'package:pixel_adventure_flame/components/level.dart';
import 'package:pixel_adventure_flame/components/player_model.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  late CameraComponent camera = CameraComponent();

  PlayerModel player = PlayerModel(
    character: PlayerCharacterEnum.maskDude.name,
  );

  late JoystickComponent joystick;
  late JoystickComponent jumpJoystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      levelName: LevelEnum.levelThree.levelName,
      player: player,
    );

    camera = CameraComponent.withFixedResolution(
      width: 640,
      height: 360,
      world: world,
    )..priority = 1;

    camera.viewfinder.anchor = Anchor.center;

    // priority para que o joystick fique por cima da camera e do mundo

    camera.moveTo(
      Vector2(320, 180),
    );

    addAll([
      camera,
      world,
    ]);

    showJoystick ? addJoystick() : null;
    // showJoystick ? addJumpJoystick() : null;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    showJoystick ? updateJoystick() : null;
    super.update(dt);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.idle:
        player.horizontalMovement = 0;
        break;
      default:
    }
  }

  void addJumpJoystick() {
    jumpJoystick = JoystickComponent(
      priority: 2,
      knob: CircleComponent(
        radius: 15,
        paint: Paint()..color = const Color.fromARGB(255, 252, 252, 252),
      ),
      background: CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color.fromARGB(255, 98, 87, 87),
      ),
      margin: const EdgeInsets.only(
        left: 42,
        bottom: 32,
      ),
    );

    add(jumpJoystick);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 2,
      knob: CircleComponent(
        radius: 15,
        paint: Paint()..color = const Color.fromARGB(255, 252, 252, 252),
      ),
      background: CircleComponent(
        radius: 25,
        paint: Paint()..color = const Color.fromARGB(255, 98, 87, 87),
      ),
      // margin: const EdgeInsets.only(
      //   right: 42,
      //   bottom: 32,
      // ),
      position: Vector2(
        size.x + 95,
        size.y - 20,
      ),
    );

    add(joystick);
  }

  // void addJoystick() {
  //   joystick = JoystickComponent(
  //     knob: SpriteComponent(
  //       sprite: Sprite(
  //         images.fromCache('HUD/knob.png'),
  //       ),
  //     ),
  //     background: SpriteComponent(
  //       sprite: Sprite(
  //         images.fromCache('HUD/joystick.png'),
  //       ),
  //     ),
  //     // margin: const EdgeInsets.only(
  //     //   left: 32,
  //     //   bottom: 32,
  //     // ),
  //     position: Vector2(
  //       120,
  //       size.y,
  //     ),
  //   );

  //   add(joystick);
  // }
}
