part of neko;


///显示在左侧菜单的数据储存参数
SelModel select = SelModel();

///用于刷新主页面的控制器
Counter paneCounter = Counter();
const platform = EventChannel('neko.event.channel');

///用于储存列表的元素数据库
class SelModel{
  List _sel = [];

  List get list {return _sel;}
  
  remove(file) {
    if (_sel.any((e) => e["url"]==file["url"])) {
      _sel.remove(_sel.firstWhere((e) => e["url"]==file["url"]));
    }
    _sel;
    navLength = _sel.length;
    paneCounter.index = navLength;

  }

  add(file) {
    _sel;
    if (!_sel.any((e) => e["url"]==file["url"])) {
      _sel.add(file);
    }
    navLength = _sel.length;
    paneCounter.index = navLength;
  }

  clear() {
    _sel.clear();
    navLength = _sel.length;
    paneCounter.index = navLength;
    paneCounter.refresh();
  }
}



initMain(context) async {
  Directory directory = await getApplicationDocumentsDirectory();
  Directory dir = Directory("${directory.path}\\喵卡\\数据库\\");
  await dir.create(recursive: true);
  await Hive.initFlutter(dir.path);
  await initBox();
}

class  NekoMain extends StatefulWidget {
  const NekoMain({super.key});

  @override
  State<NekoMain> createState() => NekoMainState();
}

class  NekoMainState extends State<NekoMain> {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        title: "neko喵卡",
        debugShowCheckedModeBanner: false,
        home:
        Container(decoration: BoxDecoration(color: Colors.grey[20]),child:
        FutureBuilder(
                    future: initMain(context),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Center(
                              child: Text('喵卡加载中ing', style: NekoText.topTitle));
                        default: //如果_calculation执行完毕
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const NekoNav();
                          }
                      }
                    })));
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,//这里替换你选择的颜色
        ),
      );
    }
  }
}

class  NekoNav extends StatefulWidget {
  const NekoNav({super.key});

  @override
  State<NekoNav> createState() => NekoNavState();
}

int navIndex = 0;
int navLength = 0;

class  NekoNavState extends State<NekoNav> {
  List<NavigationPaneItem> resetPane(i) {
    List<NavigationPaneItem> list = [];
    for (var file in i) {
      String name = file["name"].toString();
      list.add(PaneItem(
          icon: const Icon(FluentIcons.contact),
          title: Text(name),
          trailing: IconButton(
              icon: const Icon(FluentIcons.cancel),
              onPressed: () {
                select.remove(file);
              }),
          body: CharTab(file: file)));
    }
    return list;
  }

  List<NavigationPaneItem> head = [
    PaneItem(icon: const Icon(FluentIcons.home), title: const Text("主页"), body: const MainTab())
  ];
  late List<NavigationPaneItem> items = head;
  late List<NavigationPaneItem> footItems = [];
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return
      WillPopScope(
        onWillPop: () async{
      if(navIndex!=0){

          paneCounter.index=0;
        return false;
      }else{
        return true;
      }
        }, child:
      NavigationView(
        key: nekoKey.nav,
        appBar: const NavigationAppBar(height: 0,automaticallyImplyLeading:false),
        pane: NavigationPane(
            header: Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(5),
                child: NekoRow(children: [
                  Container(
                      padding: const EdgeInsets.all(5),
                      child: IconButton(
                          icon: const Icon(FluentIcons.back, size: 16),
                          onPressed: () {
                            nekoKey.nav.currentState?.minimalPaneOpen = false;
                          })),
                  Expanded(
                      child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(5),
                          child: Text("Neko喵卡☆",
                              textAlign: TextAlign.left,
                              style: nekoFontContent)))
                ])),
            selected: navIndex,
            onChanged: (i) {
              setState(() => {navIndex = i});
            },
            displayMode: PaneDisplayMode.minimal,
            items: items,
            footerItems: [
              PaneItemSeparator(),
              PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text("设置"),
                  body: const ConfigTab())
            ])));
  }

  bool first = false;

  void _onEvent(event) async {
    print("futter端接收到信息，开始处理");
      var data = Hive.box("config");
      List list = data.get("recentPath");
      list.insert(0, event);
      if (list.length >= 7) {
        list.removeRange(7, list.length);
      }
      data.put("recentPath", list);
      await showContentDialog(nekoKey.nav.currentContext!, "cloud-open");
      print("futter端处理完毕");
      setState(() {});


  }

  void getNekoSharedUri(context) async {
    if (Platform.isAndroid) {
      print("检测为安卓设备");
      await [
        Permission.storage,
        Permission.accessMediaLocation,
        Permission.manageExternalStorage
      ].request();
      platform.receiveBroadcastStream().listen(_onEvent);
    } else {
      print("未识别到路径");
    }
  }

  @override
  void initState() {
    getNekoSharedUri(context);
    paneCounter.addListener(() {
      if (mounted) {
        setState(() {
          items = [...head, ...resetPane(select.list)];
          navIndex = paneCounter.index;
        });
      }
    });
    super.initState();
  }
}

class Counter extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  refresh() {
    notifyListeners();
  }
}
