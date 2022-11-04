class TableType {
  static const normal = 0;
  static const attr = 1;
  static const judge = 2;
  static const judgeName = 3;
  static const ability = 4;
  static const title = 5;
  static const studyAbility = 6;
  static const equips = 7;
}

bool nekoEmpty(i) {
  return ((i == null) | (i == "null")) ? true : (i.isEmpty ? true : false);
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final int y;
}
