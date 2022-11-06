import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neko_cc/widget/overlay.dart';
import '../Widget/dialog.dart';
import '../core/flowCore.dart';
import '../core/imageCore.dart';
import '../core/mainCore.dart';
import '../core/styleCore.dart';

GlobalKey<_FileTabState> cloudKey = GlobalKey();
GlobalKey<_FileTabState> fileKey = GlobalKey();
ValueNotifier<int> FileTabindex = ValueNotifier<int>(0);
bool haveRefreshButton =false;

class MainTab extends StatefulWidget {
  const MainTab({super.key});

  @override
  State<MainTab> createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  @override
  Widget build(BuildContext context) {

    List<NavigationPaneItem> list = [
      PaneItem(
          icon: const Icon(FluentIcons.cloud_weather),
          title: const Text("最近"),
          body: FileTab(key:cloudKey,type: "cloud")),
      PaneItem(
          icon: const Icon(FluentIcons.fabric_folder),
          title: const Text("本地"),
          body: FileTab(key:fileKey,type: "file")),
    ];

    return ValueListenableBuilder<int>(
      builder: (content, value, child) => NavigationView(
          pane: NavigationPane(
            header: menuButton,
              selected: FileTabindex.value,
              onChanged: (i) {
                FileTabindex.value = i;
              },
              displayMode: PaneDisplayMode.top,
              items: list,
          footerItems: [
            PaneItemHeader(header: IconButton(
                icon: const Icon(FluentIcons.refresh, size: 16),
                onPressed: () async{
                  await showContentDialog(navKey.currentContext!, FileTabindex.value==0?"cloud":"file");
                }))
          ])),
      valueListenable: FileTabindex,
    );
  }
}



class FileTab extends StatefulWidget {
  FileTab({super.key,required this.type});
  final String type;

  @override
  State<FileTab> createState() => _FileTabState();
}

class _FileTabState extends State<FileTab> {
   refresh(){
     setState(() {});
   }

  @override
  Widget build(BuildContext context) {

    var box = Hive.box("file");
    List data = [];
    switch (widget.type) {
      case "cloud":
        data = box.get("recentList");
        break;
      case "file":
        data = box.get("list");
        break;
    }

    List listBrief = [];

    //加载列表
    for (var i in data) {
      if (i != null) {
        var content = i["content"]["基础信息"];
        listBrief
            .add("积分数值: ${content["积分数值"][1]}\n序列碎片: ${content["序列碎片"][1]}");
      }
    }

//卡片列表
    var listView = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final file = data[index];
          final type = widget.type;
          card(file, index) {
            return Button(
                style: ButtonTranStyle,
                onPressed: () {
                  if(selected.any((e) => e["url"]==file["url"])) {
                    paneCounter.index = 1+selected.indexWhere((e) => e["url"]==file["url"])  ;
                  }else{
                    SelectedAdd(file);
                }},
                child: Container(
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 5),
                          blurRadius: 5,
                          spreadRadius: 0,
                          color: Colors.grey.withOpacity(0.2))
                    ]),
                    child: Card(
                        padding: const EdgeInsets.all(0),
                        child: IntrinsicHeight(
                            child: ClsRow(children: [
                              FutureBuilder(
                                  future: initImg(file),
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.done:
                                        return Image.file(
                                          File(snapshot.data.toString()),
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.topCenter,
                                          width: 150,
                                          height: 150,
                                        );
                                      default:
                                        return const Icon(
                                            FluentIcons.sync_occurence);
                                    }
                                  }),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: ClsCol(children: [
                                    Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  width: 1)),
                                        ),
                                        child: Text(file["name"],
                                            style: NekoText.nromalTitle,
                                            textAlign: TextAlign.left)),
                                    Text(listBrief[index], style: brief)
                                  ]))
                            ])))));
          }

          return Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: card(file, index));
        });

//主界面
    return listView;
  }
}
