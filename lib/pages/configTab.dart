import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neko_cc/widget/overlay.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../widget/flow.dart';
import '../Widget/dialog.dart';
import '../part.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  TextEditingController jsonPathController = TextEditingController();
  TextEditingController excelPathController = TextEditingController();

  nekoFolderSearch(value, controller,String type) {
    return
      Container(padding:const EdgeInsets.only(top: 10,bottom: 10),child:
      NekoRow(
      children: [
        Expanded(child:
        TextBox(controller:controller)),
        const SizedBox(width: 10),
        Button(
          child: const Text('浏览'),
          onPressed: () async {
            //选择文件夹
            var data = Hive.box('config');
            String? path = await FilePicker.platform.getDirectoryPath();
            await data.put(value, path);
            //获取文件列表
            await updatePath(excelPathController, jsonPathController);
            if(type =="json"){
              await showContentDialog(nekoKey.nav.currentContext!, "config");
            }
          },
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    updatePath(excelPathController, jsonPathController);
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
                              padding: const EdgeInsets.all(20),
                              child: NekoCol(
                                  children: [
                                    NekoCard(child:
                                    NekoCol(
                                        children: [
                                          Text("开发人员选项", style: NekoText.topTitle),
                                          const SizedBox(height: 10),
                                          NekoRow(
                                              children: [
                                                Button(
                                                  child: Text('重置数据库',
                                                      style: nekoFontContent),
                                                  onPressed: () async {
                                                    await resetAllBox();
                                                    await updatePath(
                                                        excelPathController,
                                                        jsonPathController);
                                                    await showContentDialog(nekoKey.nav.currentContext!, "config");
                                                  },
                                                ),
                                                const SizedBox(width: 10),
                                                Button(
                                                    child: Text('清空缓存',
                                                        style: nekoFontContent),
                                                    onPressed: () async {
                                                      Directory directory = await getApplicationDocumentsDirectory();
                                                      Directory dir = Directory(
                                                          "${directory
                                                              .path}\\喵卡\\图片\\");
                                                      await dir.delete(
                                                          recursive: true);
                                                      await dir.create(
                                                          recursive: true);
                                                    })
                                              ]),
                                          const SizedBox(height: 10),
                                          NekoRow(
                                              children: [
                                                Button(
                                                    child: Text('清空最近列表',
                                                        style: nekoFontContent),
                                                    onPressed: () async {
                                                      var fileData = Hive.box("file");
                                                      await fileData.put("recentList", []);
                                                      var data = Hive.box("config");
                                                      await data.put("recentPath",[]);
                                                      await select.clear();
                                                      await nekoKey.cloud.currentState?.refresh();
                                                    })
                                              ])
                                        ])),
                                    const SizedBox(height: 10),
                                    NekoCard(child: NekoCol(children: [
                                      Text("文件路径",style: NekoText.topTitle),
                                      nekoFolderSearch("excelPath",
                                          excelPathController,"file"),
                                      Text("模板路径",style: NekoText.topTitle),
                                      nekoFolderSearch("jsonPath",
                                          jsonPathController,"json")
                                    ]))
                                  ])))
                    ])));
  }
}
