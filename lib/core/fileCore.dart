import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:neko_cc/core/imageCore.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import '../core/excelCore.dart';
import '../core/baseCore.dart';
import '../core/mainCore.dart';
import '../pages/mainTab.dart';
import '../widget/dialog.dart';

MethodChannel methodChannel = const MethodChannel('neko.method.channel');

//重置配置
Future LoadFileModel() async {
  var config = Hive.box('config');
  var jsonPath = config.get('jsonPath', defaultValue: "");
  var i;

  i = File(jsonPath + "\\" + "file.json");
  Map jsonFile = await i.exists()
      ? jsonDecode(await i.readAsString())
      : (jsonDecode(await rootBundle.loadString("assets/json/file.json")));

  i = File(jsonPath + "\\" + "replace.json");
  Map jsonReplace = await i.exists()
      ? jsonDecode(await i.readAsString())
      : (jsonDecode(await rootBundle.loadString("assets/json/replace.json")));

  i = File(jsonPath + "\\" + "view.json");
  Map jsonView = await i.exists()
      ? jsonDecode(await i.readAsString())
      : (jsonDecode(await rootBundle.loadString("assets/json/view.json")));

  config.put("view", jsonView);
  config.put("file", jsonFile);
  config.put("replace", jsonReplace);
}

Future openRecentFile() async {
  var fileData = Hive.box("file");
  List fileList = await fileData.get("recentList");
  if (fileList.isNotEmpty) {
    await SelectedAdd(fileList[0]);
  }
}

//获取文件夹内的xlsx文件，并添加到box的列表内
Future LoadConfig({type, open = false}) async {
  var config = Hive.box('config');
  List warning = [];

  loadCloudRead(l, f) async {
    List putList = [];

    for (var list in l) {
      String path = list[0];

      String fileType = extension(path);
      if ((fileType == ".xlsx")) {
        String name = basename(path).replaceAll(fileType, "");
        try {
          Uint8List bytes;
          bytes = list[1];
          Map excel = await methodChannel
              .invokeMethod('excel.read', {'name': name, 'bytes': bytes});
          var content = await nekoExcelRead(
              NekoExcel(excel), config.get("file"), config.get("replace"));
          putList.add({
            "name": name,
            "type": fileType,
            "url": path,
            "content": content,
            "bytes":bytes
          });
        } catch (e) {
          warning.add("加载名为[$name]的人物卡时遇到错误:\n${e.toString()}");
        }
      }
    }
    return putList;
  }

  loadFileRead(l, f) async {
    List putList = [];

    await for (var file in l) {
      String path = file.path;

      String fileType = extension(path);
      if ((fileType == ".xlsx")) {
        String name = basename(path).replaceAll(fileType, "");
        print("读取[$name]文件");
        // try {
          Uint8List bytes;
          File charFile = File(path);
          bytes = charFile.readAsBytesSync();
          dialogText.value = name;
          Map excel = await methodChannel
              .invokeMethod('excel.read', {'name': name, 'bytes': bytes});
          var content = await nekoExcelRead(
              NekoExcel(excel), config.get("file"), config.get("replace"));
          putList.add({
            "name": name,
            "type": fileType,
            "url": path,
            "content": content,
            "bytes":bytes
          });
        // } catch (e) {
        //   warning.add("加载名为[$name]的人物卡时遇到错误:\n${e.toString()}");
        // }
      }
    }
    return putList;
  }

  loadRead(l, t, f) async {
    List putList =
        t == "file" ? await loadFileRead(l, f) : await loadCloudRead(l, f);
    var fileData = Hive.box("file");
    if (t == "file") {
      await fileData.put("list", putList);
      await fileKey.currentState?.refresh();
    } else if (t == "cloud") {
      await fileData.put("recentList", putList);
      await cloudKey.currentState?.refresh();
    }

    Navigator.pop(navKey.currentContext!);
    if (warning.isNotEmpty) {
      for (String i in warning) {
        showWarningDialog(navKey.currentContext!, i);
      }
    }

    if (f) {

      if (open) {
        if(navIndex!=0){
          paneCounter.index = 0;
        }
        Future.delayed(Duration(seconds: 1), ()async{
          await openRecentFile();
        });
        };
    }
  }

  loadFile({t, f = false}) async {
    var excelPath = await config.get('excelPath', defaultValue: null);
    if (!nekoEmpty(excelPath)) {
      Stream<FileSystemEntity> fileList = Directory(excelPath).list();
      await loadRead(fileList, t, f);
    }
  }

  loadCloud({t, f = false}) async {
    var data = await config.get("recentPath");
    List list = [];
    if (!nekoEmpty(data)) {
      for (var i in data) {
        list.add(i);
      }
    }
    await loadRead(list, t, f);
  }

  switch (type) {
    case "file":
      await loadFile(t: type, f: true);
      break;
    case "cloud":
      await loadCloud(t: type, f: true);
      break;
  }
}

//更新设置中的路径，传入参数是文本框内的控制器
Future UpdatePath(a, b) async {
  var data = Hive.box('config');
  var excelPath = await data.get('excelPath', defaultValue: null);
  var jsonPath = await data.get('jsonPath', defaultValue: null);
  a.text = await nekoEmpty(excelPath) ? "请填入参数！" : excelPath;
  b.text = await nekoEmpty(jsonPath) ? "为空则使用默认参数" : jsonPath;
}
