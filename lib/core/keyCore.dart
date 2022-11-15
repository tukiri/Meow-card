part of neko;


class NekoKey {

  ///导航菜单key
  final GlobalKey<NavigationViewState> _nav = GlobalKey();
  ///云端文件人物卡key
  final GlobalKey<FileTabState> _cloud = GlobalKey();
  ///本地文件人物卡key
  final GlobalKey<FileTabState> _file = GlobalKey();
  ///人物卡页面的展开key
  final NekoKeyExp _exp = NekoKeyExp();

  GlobalKey<FileTabState> get cloud {return _cloud;}
  GlobalKey<FileTabState> get file {return _file;}
  GlobalKey<NavigationViewState> get nav {return _nav;}
  NekoKeyExp get exp {return _exp;}
  ///提供人物卡中选项卡的key列表，没有则生成到指定数字长度并返回key

}

class NekoKeyExp {
  final List _exp = [];

  operator [] (i){
    if (_exp.length < i + 1) {
      _exp.addAll(List.filled(i + 1 -_exp.length,GlobalKey()));
    }
    return _exp[i];
  }

  get list{
    return _exp;
}
}