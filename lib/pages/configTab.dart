import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neko_cc/widget/overlay.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'package:hive/hive.dart';
import '../core/flowCore.dart';
import '../core/dataCore.dart';
import '../core/fileCore.dart';
import '../Widget/dialog.dart';
import '../core/mainCore.dart';
import '../core/styleCore.dart';
import 'mainTab.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  TextEditingController jsonPathController = TextEditingController();
  TextEditingController excelPathController = TextEditingController();

  ClsFolderSearch(value, controller,String type) {
    return
      Container(padding:EdgeInsets.only(top: 10,bottom: 10),child:
      ClsRow(
      children: [
        Expanded(child:
        TextBox(controller:controller)),
        SizedBox(width: 10),
        Button(
          child: Text('浏览'),
          onPressed: () async {
            //选择文件夹
            var data = Hive.box('config');
            String? path = await FilePicker.platform.getDirectoryPath();
            await data.put(value, path);
            //获取文件列表
            await UpdatePath(excelPathController, jsonPathController);
            if(type =="json"){
              await showContentDialog(navKey.currentContext!, "config");
            }
          },
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    UpdatePath(excelPathController, jsonPathController);
    ValueNotifier<int> index = ValueNotifier<int>(0);

    return ValueListenableBuilder<int>(
        valueListenable: index,
        builder: (content, value, child) =>
            NavigationView(
                pane: NavigationPane(
                    header: menuButton,
                    selected: index.value,
                    onChanged: (i) {
                      index.value = i;
                    },
                    displayMode: PaneDisplayMode.top,
                    items: [
                      PaneItem(
                          icon: const Icon(FluentIcons.settings),
                          title: const Text("设置"),
                          body: Container(
                              padding: EdgeInsets.all(20),
                              child: ClsCol(
                                  children: [
                                    ClsCard(child:
                                    ClsCol(
                                        children: [
                                          Text("开发人员选项", style: NekoText.topTitle),
                                          SizedBox(height: 10),
                                          ClsRow(
                                              children: [
                                                Button(
                                                  child: Text('重置数据库',
                                                      style: ClsFontContent),
                                                  onPressed: () async {
                                                    await ResetAllBox();
                                                    await UpdatePath(
                                                        excelPathController,
                                                        jsonPathController);
                                                    await showContentDialog(navKey.currentContext!, "config");
                                                  },
                                                ),
                                                SizedBox(width: 10),
                                                Button(
                                                    child: Text('清空缓存',
                                                        style: ClsFontContent),
                                                    onPressed: () async {
                                                      Directory directory = await pathProvider
                                                          .getApplicationDocumentsDirectory();
                                                      Directory dir = Directory(
                                                          "${directory
                                                              .path}\\喵卡\\图片\\");
                                                      await dir.delete(
                                                          recursive: true);
                                                      await dir.create(
                                                          recursive: true);
                                                    })
                                              ]),
                                          SizedBox(height: 10),
                                          ClsRow(
                                              children: [
                                                Button(
                                                    child: Text('清空最近列表',
                                                        style: ClsFontContent),
                                                    onPressed: () async {
                                                      var fileData = Hive.box("file");
                                                      await fileData.put("recentList", []);
                                                      var data = Hive.box("config");
                                                      await data.put("recentPath",[]);
                                                      await SelectedClear();
                                                      await cloudKey.currentState?.refresh();
                                                    })
                                              ])
                                        ])),
                                    SizedBox(height: 10),
                                    ClsCard(child: ClsCol(children: [
                                      Text("文件路径",style: NekoText.topTitle),
                                      ClsFolderSearch("excelPath",
                                          excelPathController,"file"),
                                      Text("模板路径",style: NekoText.topTitle),
                                      ClsFolderSearch("jsonPath",
                                          jsonPathController,"json")
                                    ]))
                                  ])))
                    ])));
  }
}
