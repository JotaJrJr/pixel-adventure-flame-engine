import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure_flame/enum/player_character_enum.dart';
import 'package:pixel_adventure_flame/models/player_model.dart';

class Level extends World {
  final String levelName;
  late TiledComponent level;

  Level({required this.levelName});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2.all(16));

    add(level);

    // Esse getLayer é para pegar de acordo com um Object Layer criado no Tile com o nome 'Spawnpoint'
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoint');

    // Esse for é para pegar todos os objetos que estão dentro do Object Layer
    for (final spawnPoints in spawnPointLayer!.objects) {
      switch (spawnPoints.class_) {
        case 'PlayerModel':
          final player = PlayerModel(
            character: PlayerCharacterEnum.virtualGuy.name,
            position: Vector2(
              spawnPoints.x,
              spawnPoints.y,
            ),
          );
          add(player);
          break;
        default:

        // E assim o jogador é simplesmente adicionado, de acordo com o class especificado no Tile e assimilado aqui
      }
    }

    // add(PlayerModel(character: PlayerCharacterEnum.ninjaFrog.name));

    return super.onLoad();
  }
}
