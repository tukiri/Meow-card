part of neko;

///app首次打开参数
bool appStart = false;

///所有页面的key检索类
NekoKey nekoKey = NekoKey();

///数据库列表
List boxList = ["config", "file"];

///判断单元格是否为空的函数
bool nekoEmpty(i) {
  return ((i == null) | (i == "null")) ? true : (i.isEmpty ? true : false);
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final int y;
}
