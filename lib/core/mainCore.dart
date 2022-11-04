import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:neko_cc/core/flowCore.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:hive_flutter/hive_flutter.dart';
import '../Widget/dialog.dart';
import '../pages/configTab.dart';
import '../pages/charTab.dart';
import '../pages/mainTab.dart';
import '../core/styleCore.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widget/toast.dart';
import 'dataCore.dart';

List selected = [];

Counter paneCounter = Counter();
const platform = EventChannel('neko.event.channel');
GlobalKey<NavigationViewState> navKey = GlobalKey();

SelectedRemove(file) {
  print("index:$navIndex,length:${selected.length}");
  if (selected.any((e) => e["url"]==file["url"])) {
    selected.remove(selected.firstWhere((e) => e["url"]==file["url"]));
  }
  selected ??= [];
  if(navIndex ==0){
    paneCounter.index = 0;
  }else{
    paneCounter.refresh();
  }

}

SelectedAdd(file) {
  selected ??= [];
  if (!selected.any((e) => e["url"]==file["url"])) {
    selected.add(file);
  }
  selected ??= [];
  paneCounter.refresh();
}

SelectedClear() {
  selected.clear();
  paneCounter.refresh();
}

InitBaseCore(context) async {
  Directory directory = await pathProvider.getApplicationDocumentsDirectory();
  Directory dir = Directory("${directory.path}\\喵卡\\数据库\\");
  await dir.create(recursive: true);
  await Hive.initFlutter(dir.path);
  await InitBox();
}

class ClsMain extends StatefulWidget {
  const ClsMain({super.key});

  @override
  State<ClsMain> createState() => ClsMainState();
}

class ClsMainState extends State<ClsMain> {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
        title: "neko喵卡",
        debugShowCheckedModeBanner: false,
        home:
        Container(decoration: BoxDecoration(color: Colors.grey[20]),child:
        FutureBuilder(
                    future: InitBaseCore(context),
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
                            return ClsNav();
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

class ClsNav extends StatefulWidget {
  const ClsNav({super.key});

  @override
  State<ClsNav> createState() => ClsNavState();
}

int navIndex = 0;
int navLength = 0;

class ClsNavState extends State<ClsNav> {
  List<NavigationPaneItem> ResetPane(i) {
    List<NavigationPaneItem> list = [];
    for (var file in i) {
      String name = file["name"].toString();
      list.add(PaneItem(
          icon: Icon(FluentIcons.contact),
          title: Text(name),
          trailing: IconButton(
              icon: Icon(FluentIcons.cancel),
              onPressed: () {
                SelectedRemove(file);
              }),
          body: CharTab(file: file)));
    }
    return list;
  }

  List<NavigationPaneItem> head = [
    PaneItem(icon: Icon(FluentIcons.home), title: Text("主页"), body: MainTab())
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

          paneCounter.index=-items.length +1;
        return false;
      }else{
        return true;
      }
        }, child:
      NavigationView(
        key: navKey,
        appBar: NavigationAppBar(height: 0,automaticallyImplyLeading:false),
        pane: NavigationPane(
            header: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(5),
                child: ClsRow(children: [
                  Container(
                      padding: EdgeInsets.all(5),
                      child: IconButton(
                          icon: Icon(FluentIcons.back, size: 16),
                          onPressed: () {
                            navKey.currentState?.minimalPaneOpen = false;
                          })),
                  Expanded(
                      child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(5),
                          child: Text("Neko喵卡☆",
                              textAlign: TextAlign.left,
                              style: ClsFontContent)))
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
                  icon: Icon(FluentIcons.settings),
                  title: Text("设置"),
                  body: ConfigTab())
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
      await showContentDialog(navKey.currentContext!, "cloud-open");
      print("futter端处理完毕");
      setState(() {});


  }

  void getNekoSharedUri(context) async {
    if (Platform.isAndroid) {
      print("检测为安卓设备");
      Map<Permission, PermissionStatus> statuses = await [
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
          items = [...head, ...ResetPane(selected)];
          navLength = items.length;
          navIndex = navLength - 1 + paneCounter.index;
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
