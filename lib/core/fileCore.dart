part of neko;


///初始化通信组件
MethodChannel methodChannel = const MethodChannel('neko.method.channel');

///加载文件模型
Future loadFileModel() async {
  Box config = Hive.box('config');
  String jsonPath = config.get('jsonPath');
  List data = ["file","view","replace"];

  for(String i in data){
    File file = File("$jsonPath\\$i.json");
    Map map = await file.exists()
        ? jsonDecode(await file.readAsString())
        : (jsonDecode(await rootBundle.loadString("assets/json/$i.json")));
    config.put(i, map);
  }
}

///打开最近文件
Future openRecentFile() async {
  var fileData = Hive.box("file");
  List fileList = await fileData.get("recentList");
  if (fileList.isNotEmpty) {
    await select.add(fileList[0]);
  }
}

///获取文件夹内的xlsx文件，并添加到box的列表内
Future loadConfig({type, open = false}) async {
  var config = Hive.box('config');
  List warning = [];

  loadCloudRead(l, f) async {
    List putList = [];
    int index = 0;
    for (List list in l) {
      String path = list[0];
      String type = extension(path);
      if ((type == ".xlsx")) {
        String name = basename(path).replaceAll(type, "");
        try {
          Uint8List bytes = list[1];
          Map excel = await methodChannel
              .invokeMethod('excel.read', {'name': name, 'bytes': bytes});
          var content = await nekoExcelRead(
              NekoExcel(excel), config.get("file"), config.get("replace"));
          putList.add({
            "name": name,
            "type": type,
            "url": path,
            "content": content,
            "bytes":bytes,
            "from":"cloud",
            "index":index
          });
          index++;
        } catch (e) {
          warning.add("加载名为[$name]的人物卡时遇到错误:\n${e.toString()}");
        }
      }
    }
    return putList;
  }

  loadFileRead(l, f) async {
    List putList = [];
    int index = 0;
    await for (var file in l) {
      String path = file.path;
      String type = extension(path);
      if ((type == ".xlsx")) {
        String name = basename(path).replaceAll(type, "");
        print("读取文件[$name]");
        try {
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
            "type": type,
            "url": path,
            "content": content,
            "bytes":bytes,
            "from":"file",
            "index":index
          });
        index++;
        } catch (e) {
          warning.add("加载名为[$name]的人物卡时遇到错误:\n${e.toString()}");
        }
      }
    }
    return putList;
  }

  loadRead(l, t, f) async {
    List putList = [];
    if(t=="file"){
      putList = await loadFileRead(l, f);
      Box fileData = Hive.box("file");
      await fileData.put("list", putList);
      await nekoKey.file.currentState?.refresh();
    }else{
      putList = await loadCloudRead(l, f);
      Box fileData = Hive.box("file");
      await fileData.put("recentList", putList);
      await nekoKey.cloud.currentState?.refresh();
    }

    Navigator.pop(nekoKey.nav.currentContext!);
    if (warning.isNotEmpty) {
      for (String i in warning) {
        showWarningDialog(nekoKey.nav.currentContext!, i);
      }
    }

    if (f && open) {
        Future.delayed(const Duration(seconds: 1), ()async{
          await openRecentFile();
        });
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

///更新设置中的路径，传入参数是文本框内的控制器
Future updatePath(a, b) async {
  var data = Hive.box('config');
  var excelPath = await data.get('excelPath');
  var jsonPath = await data.get('jsonPath');
  a.text = nekoEmpty(excelPath) ? "请填入参数！" : excelPath;
  b.text = nekoEmpty(jsonPath) ? "为空则使用默认参数" : jsonPath;
}
