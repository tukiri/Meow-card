part of neko;


///打印单个数据库
Future printBox(name) async {
  var box = Hive.box(name);
  var outStr = "\n——————[${box.name}]——————";
  if (box.isNotEmpty) {
    for (var i in box.keys) {
      outStr += "\n[$i]:${box.get(i)}";
    }
  } else {
    outStr += "\n不存在内容";
  }

  outStr += "\n——————[打印结束]——————";
  print(outStr);
}

///重置单个数据库
Future resetBox(name) async {
  await Hive.deleteBoxFromDisk(name);
  await Hive.openBox(name);
}

///重置所有数据库
Future resetAllBox() async {
  await Hive.deleteFromDisk();
  for (var name in boxList) {
    await Hive.openBox(name);
  }
  await initFile();
  await initConfig();
}

///初始化数据库
Future initBox() async {
  for (var name in boxList) {
    await Hive.openBox(name);
  }
}

///初始化数据库-设置
Future initConfig() async {
  var box = Hive.box("config");
  box.put('excelPath', "");
  box.put('recentPath', []);
  box.put('jsonPath', "");
  box.put("view", {});
  box.put("file", {});
  box.put("replace", {});
}

///初始化数据库-文件
Future initFile() async {
  var box = Hive.box("file");
  box.put('list', []);
  box.put('recentList', []);
}

///打印所有数据库
Future printAllBox() async {
  for (var name in boxList) {
    printBox(name);
  }
}
