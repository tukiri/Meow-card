import 'package:hive/hive.dart';

var boxList = ["config", "file"];

Future PrintBox(name) async {
  var box = Hive.box(name);
  var outStr = "\n——————[${box.name}]——————";
  if (!box.isEmpty) {
    for (var i in box.keys) {
      outStr += "\n[${i}]:${box.get(i)}";
    }
  } else {
    outStr += "\n不存在内容";
  }

  outStr += "\n——————[打印结束]——————";
  print(outStr);
}

Future ResetBox(name) async {
  await Hive.deleteBoxFromDisk(name);
  await Hive.openBox(name);
}

Future ResetAllBox() async {
  await Hive.deleteFromDisk();
  for (var name in boxList) {
    await Hive.openBox(name);
  }
  ;
  await InitFile();
  await InitConfig();
}

Future InitBox() async {
  for (var name in boxList) {
    await Hive.openBox(name);
  }
  ;
}

Future InitConfig() async {
  var box = Hive.box("config");
  box.put('excelPath', "");
  box.put('recentPath', []);
  box.put('jsonPath', "");
  box.put("view", {});
  box.put("file", {});
  box.put("replace", {});
}

Future InitFile() async {
  var box = Hive.box("file");
  box.put('list', []);
  box.put('recentList', []);
}

Future PrintAllBox() async {
  for (var name in boxList) {
    await {PrintBox(name)};
  }
  ;
}
