enum LevelEnum {
  levelOne(1, "level_01.tmx"),
  levelTwo(2, "level_02.tmx"),
  levelThree(3, "level_03.tmx"),
  levelFour(4, "level_04.tmx");

  final int id;
  final String levelName;

  const LevelEnum(this.id, this.levelName);
}
