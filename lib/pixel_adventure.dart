import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure_flame/enum/level_enum.dart';
import 'package:pixel_adventure_flame/levels/level.dart';

class PixelAdventure extends FlameGame {
  @override
  late CameraComponent camera = CameraComponent();

  @override
  final world = Level(levelName: LevelEnum.levelTwo.levelName);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    camera = CameraComponent.withFixedResolution(width: 640, height: 360, world: world);

    camera.moveTo(
      Vector2(320, 180),
    );

    addAll([
      camera,
      world,
    ]);

    return super.onLoad();
  }
}
