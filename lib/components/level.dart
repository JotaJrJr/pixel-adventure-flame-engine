import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure_flame/components/background_tile.dart';
import 'package:pixel_adventure_flame/components/collision_block.dart';
import 'package:pixel_adventure_flame/components/fruit.dart';
import 'package:pixel_adventure_flame/components/player_model.dart';
import 'package:pixel_adventure_flame/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  final String levelName;
  final PlayerModel player;
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(levelName, Vector2.all(16));

    add(level);

    _scrollingBackground();

    _spawningObjects();

    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    const tileSize = 64;

    final numberOfTilesInY = (game.size.y / tileSize).floor();
    final numberOfTilesInX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < numberOfTilesInY; y++) {
        for (double x = 0; x < numberOfTilesInX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Blue',
            position: Vector2(x * tileSize, y * tileSize),
          );

          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    // Esse getLayer é para pegar de acordo com um Object Layer criado no Tile com o nome 'Spawnpoint'
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoint');

    if (spawnPointLayer != null) {
      // Esse for é para pegar todos os objetos que estão dentro do Object Layer
      for (final spawnPoints in spawnPointLayer.objects) {
        switch (spawnPoints.class_) {
          case 'PlayerModel':
            player.position = Vector2(
              spawnPoints.x,
              spawnPoints.y,
            );
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoints.name,
              position: Vector2(
                spawnPoints.x,
                spawnPoints.y,
              ),
              size: Vector2(spawnPoints.width, spawnPoints.height),
            );

            add(fruit);

          default:

          // E assim o jogador é simplesmente adicionado, de acordo com o class especificado no Tile e assimilado aqui
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collisions in collisionsLayer.objects) {
        switch (collisions.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(
                collisions.x,
                collisions.y,
              ),
              size: Vector2(
                collisions.width,
                collisions.height,
              ),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(
                collisions.x,
                collisions.y,
              ),
              size: Vector2(
                collisions.width,
                collisions.height,
              ),
            );
            collisionBlocks.add(block);
        }
      }
    }

    player.collisionBlocks = collisionBlocks;
  }
}
