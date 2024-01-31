bool checkCollision(player, block) {
  final hitbox = player.hitbox;

  final playerX = player.position.x;
  final playerY = player.position.y;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedX = player.scale.x < 0 ? playerX - (hitbox.x * 2) - playerWidth : playerX;
  final fixedY = block.isPlatform ? playerY + playerHeight : playerY;

  return (fixedX < blockX + blockWidth && fixedX + playerWidth > blockX && fixedY < blockY + blockHeight && playerY + playerHeight > blockY);
}
