import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:image/image.dart';
import 'package:hive/hive.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'excelCore.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<Map> loadImg(List<int> bytes, String name) async {
  var path = await _localPath;
  path = "$path\\喵卡\\图片\\";
  Directory dir = Directory(path);
  await dir.create(recursive: true);

  path = "${path + name}\\";
  Directory imageDir = Directory(path);
  await imageDir.create(recursive: true);

  Map map = NekoImage(bytes).getMap();
  if (map.isNotEmpty) {
    for (String sheet in map.keys.toList()) {
      for (var i in map[sheet]) {
        String type = extension(i["url"]);
        var imgPath = "${imageDir.path + sheet}_ ${i["id"]} $type";

        File file = File(imgPath);
        await file.create(recursive: true);
        file = await file.writeAsBytes(i["img"]);
        i["url"] = imgPath;
        i["type"] = type;
        i.remove("img");
      }
    }
  }
  return map;
}

Future<String> FindImageById(List list, id) async {
  var url = "";
  for (var i in list) {
    var name = "rId$id";
    if (i["id"].toString() == name) {
      url = i["url"];
    }
  }
  return url;
}

Future<String> initImg(file) async {
  String type = file["from"];
  int index = file["index"];
  print("检测图片加载,当前类别:$type");
  var box = Hive.box("file");
  var data = [];
  String uri = "";
  if (type == "cloud") {
    List data = await box.get("recentList");
    if (!data[index].containsKey("imgMap")) {
      data[index]["imgMap"] =
          await loadImg(data[index]["bytes"], data[index]["name"]);
      data[index].remove("bytes");
      box.put("recentList", data);
    }
    uri = await FindImageById(data[index]["imgMap"]["基础信息"], 1);
    return uri;
  } else {
    data = box.get("list");
    if (!data[index].containsKey("imgMap")) {
      data[index]["imgMap"] =
          await loadImg(data[index]["bytes"], data[index]["name"]);
      data[index].remove("bytes");
      box.put("list", data);
    }
    uri = await FindImageById(data[index]["imgMap"]["基础信息"], 1);
    return uri;
  }
}

///图片处理
class NekoImage {
  List<int> data;
  final Map<String, List> _image = {};

  List? operator [](String name) {
    return _image[name];
  }

  Map<String, List> getMap() {
    return _image;
  }

  NekoImage(this.data) {
    var archive = ZipDecoder().decodeBytes(data);
    var workbook = archive.findFile('xl/workbook.xml');
    if (workbook != null) {
      workbook.decompress();
      var document = XmlDocument.parse(utf8.decode(workbook.content));

      Map sheets = {};

      document.findAllElements('sheet').forEach((node) {
        String name = node.getAttribute('name')!;
        String rid = node.getAttribute('r:id')!;
        sheets[rid] = name;
      });

      var relations = archive.findFile('xl/_rels/workbook.xml.rels');
      if (relations != null) {
        relations.decompress();
        var document = XmlDocument.parse(utf8.decode(relations.content));

        document.findAllElements('Relationship').forEach((node) {
          String id = node.getAttribute('Id')!;
          if (sheets[id] != null) {
            String name = sheets[id];
            String? target = node.getAttribute('Target');
            ArchiveFile? file = archive.findFile('xl/$target');
            file!.decompress();

            var worksheet = XmlDocument.parse(utf8.decode(file.content))
                .findElements('worksheet')
                .first;
            var drawing = worksheet.findAllElements('drawing').toList();

            if (drawing.isNotEmpty) {
              List image = [];

              var drawingFile = archive.findFile(
                  "xl/${target.toString().replaceAll("worksheets", "worksheets/_rels")}.rels");
              drawingFile!.decompress();

              var drawingContent =
                  XmlDocument.parse(utf8.decode(drawingFile.content));
              var drawingPath = drawingContent
                  .findAllElements('Relationship')
                  .first
                  .getAttribute('Target')
                  .toString()
                  .replaceAll("../", "xl/");

              var imageFile = archive.findFile(
                  "${drawingPath.replaceAll("drawings/", "drawings/_rels/")}.rels");
              imageFile!.decompress();

              var imageFileContent =
                  XmlDocument.parse(utf8.decode(imageFile.content));
              List imagePathList =
                  imageFileContent.findAllElements('Relationship').toList();

              for (var element in imagePathList) {
                var imgId = element.getAttribute("Id");
                var imgUrl = element
                    .getAttribute('Target')
                    .toString()
                    .replaceAll("../", "xl/");
                image.add({"id": imgId, "url": imgUrl});
              }

              List delList = [];

              var imageConfig = archive.findFile(drawingPath);
              imageConfig!.decompress();

              var imageConfigContent =
                  XmlDocument.parse(utf8.decode(imageConfig.content));

              Iterable<XmlElement> imageConfigList =
                  imageConfigContent.findAllElements("xdr:twoCellAnchor");

              for (var i in image) {
                if ((i["url"] != "NULL") | (i["url"] == null)) {
                  var imgFile = archive.findFile(i["url"]);

                  imgFile!.decompress();
                  i["img"] = imgFile.content;
                } else {
                  delList.add(i);
                }
              }
              for (var i in delList) {
                image.remove(i);
              }

              for (var e in imageConfigList) {
                var eList = {};
                var eI = e.findAllElements("xdr:pic").isEmpty
                    ? null
                    : e.findAllElements("xdr:pic").first;
                var eBlip = e.findAllElements("xdr:blipFill").isEmpty
                    ? null
                    : e.findAllElements("xdr:blipFill").first;
                if ((eI != null) & (eBlip != null)) {
                  var eId =
                      eBlip!.getElement("a:blip")!.getAttribute("r:embed");

                  var eFrom = e.getElement("xdr:from")!;

                  var eTo = e.getElement("xdr:to")!;

                  eList["from"] = {
                    "row": eFrom.getElement("xdr:row")!.text,
                    "col": eFrom.getElement("xdr:col")!.text
                  };

                  eList["to"] = {
                    "row": eTo.getElement("xdr:row")!.text,
                    "col": eTo.getElement("xdr:col")!.text
                  };

                  var eName = e
                      .getElement("xdr:pic")!
                      .getElement("xdr:nvPicPr")!
                      .getElement("xdr:cNvPr")!
                      .getAttribute("name");

                  for (var e in image) {
                    if (e["id"] == eId) {
                      e["name"] = eName;
                      e["from"] = eList["from"];
                      e["to"] = eList["to"];
                    }
                  }
                }
              }
              _image[name] = image;
            }
          }
        });
      }
    }
  }
}
