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

import 'enum/player_direction_enum.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  late CameraComponent camera = CameraComponent();

  PlayerModel player = PlayerModel(
    character: PlayerCharacterEnum.virtualGuy.name,
  );

  late JoystickComponent joystick;
  bool showJoystick = true;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    final world = Level(
      levelName: LevelEnum.levelTwo.levelName,
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

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 2,
      // knob: CircleComponent(
      //   radius: 15,
      //   paint: Paint()..color = Color.fromARGB(255, 252, 252, 252),
      // ),

      knob: RectangleComponent(
        size: Vector2(30, 30),
        paint: Paint()..color = Color.fromARGB(255, 214, 44, 44),
      ),
      background: CircleComponent(
        radius: 25,
        paint: Paint()..color = Color.fromARGB(255, 98, 87, 87),
      ),
      margin: const EdgeInsets.only(
        left: 42,
        bottom: 32,
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
