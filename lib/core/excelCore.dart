part of neko;


///储存xlsx文件映射Map的Excel父类
class NekoExcel {
  Map excel;

  NekoExcel(this.excel);

  get sheetKeys {
    return excel.keys.toList();
  }

  NekoSheet operator [](String name) {

    return NekoSheet(name,excel[name]);
  }
}

///储存工作表的Excel子类
class NekoSheet {
  final List _sheet;
  final String _name;

  NekoSheet(this._name,this._sheet);

  get name {
    return _name;
  }

  int _letterOnly(int rune) {
    if (65 <= rune && rune <= 90) {
      return rune;
    } else if (97 <= rune && rune <= 122) {
      return rune - 32;
    }
    return 0;
  }

  int lettersToNumeric(String letters) {
    var sum = 0, mul = 1, n = 1;
    for (var index = letters.length - 1; index >= 0; index--) {
      var c = letters[index].codeUnitAt(0);
      n = 1;
      if (65 <= c && c <= 90) {
        n += c - 65;
      } else if (97 <= c && c <= 122) {
        n += c - 97;
      }
      sum += n * mul;
      mul = mul * 26;
    }
    return sum;
  }

  cell(String name) async {
    var lettersPart = utf8.decode(name.runes.map(_letterOnly).where((rune) {
      return rune > 0;
    }).toList(growable: false));
    int x = int.parse(name.substring(lettersPart.length)) - 2;
    int y = lettersToNumeric(lettersPart) - 1;
    if (x < _sheet.length) {
      String cell = _sheet[x][y] ?? "";
      return cell;
    } else {
      return "";
    }
  }

  read(v, int type) async {
    List list = [];
    switch (type) {
      case TableType.normal:
        list = [v[1] == null ? v[0] : await cell(v[1]), await cell(v[2])];
        if (list[0].endsWith("：")) {
          list[0] = list[0].substring(0, list[0].length - 1);
        }
        break;
      case TableType.ability:
        list = [];
        list.add(v[1] == null ? v[0] : await cell(v[1]));
        list.add(await cell(v[2]));
        if (v.length > 3) {
          list.add(v[4] == null ? v[3] : await cell(v[4]));
          list.add(await cell(v[5]));
        }
        if (list[0].endsWith("：")) {
          list[0] = list[0].substring(0, list[0].length - 1);
        }
        break;
      case TableType.equips:
        list = [];
        if (v.length > 3) {
          list.add(v[1] == null ? v[0] : await cell(v[1]));
          list.add(v[3] == null ? v[2] : await cell(v[3]));
          list.add(await cell(v[4]));
        } else {
          list.add(v[1] == null ? v[0] : await cell(v[1]));
          list.add(await cell(v[2]));
        }
        break;
      case TableType.judge:
        List vv = List.from(v);
        list = [v[1] == null ? v[0] : await cell(v[1])];
        vv.removeAt(0);
        vv.removeAt(0);
        for (var i in vv) {
          String str = await cell(i.toString());
          str = nekoEmpty(str) ? "0" : str;
          list.add(str);
        }
        break;
      case TableType.judgeName:
        for (String i in v.keys.toList()) {
          list.add(v[i][1] == null ? v[i][0] : await cell(v[i][1]));
        }
        break;
    }
    return list;
  }
}

Future<Map> nekoExcelRead(NekoExcel excel, file, replace) async {
  var list = {};

  for (var i in excel.sheetKeys) {
    if (file["file"].containsKey(i)) {
      list[i] = await nekoSheetRead(excel[i], file["file"][i],
          replace["file"].containsKey(i) ? replace["file"][i] : null);
    }
  }
  return list;
}

nekoRepalce(l, r) async {
  if (!nekoEmpty(r)) {
    for (var i = 0; i < r.length; i++) {
      if (!nekoEmpty(r[i])) {
        for (var index = 0; index < r[i].length / 2; index++) {
          l[i] = (l[i].replaceAll(r[i][index * 2], r[i][index * 2 + 1]));
        }
      }
    }
  }
  return l;
}

Future nekoSheetRead(NekoSheet sheet, Map textData, Map textReplace) async {
  var list = {};
  void replace(list, i, j) async {
    if (!nekoEmpty(textReplace)) {
      var replace = textReplace.containsKey(i) ? textReplace[i] : null;
      if (!nekoEmpty(replace)) {
        replace = replace.containsKey(j) ? replace[j] : null;
        list[i][j] = await nekoRepalce(list[i][j], replace);
      }
    }
  }

  for (String i in textData.keys.toList()) {
    var v = textData[i];

    if (v is List) {
      list[i] = await sheet.read(v, TableType.normal);
      if (!nekoEmpty(textReplace)) {
        var replace = textReplace.containsKey(i) ? textReplace[i] : null;
        list[i] = await nekoRepalce(list[i], replace);
      }
    } else {
      if (v is Map) {
        list[i] = {};
        switch (i) {
          case "公式判定":
            for (String j in v.keys.toList()) {
              list[i][j] = j != "行名"
                  ? await sheet.read(v[j], TableType.judge)
                  : await sheet.read(v[j], TableType.judgeName);
              replace(list, i, j);
            }
            break;
          case "人物能力栏":
          case "生活与学术侧技能栏":
          case "通用能力栏":
          case "主要特质":
          case "次要特质":
            for (String j in v.keys.toList()) {
              list[i][j] = await sheet.read(v[j], TableType.ability);
              replace(list, i, j);
            }
            break;
          case "人物装备栏":
            for (String j in v.keys.toList()) {
              list[i][j] = await sheet.read(v[j], TableType.equips);
              replace(list, i, j);
            }
            break;
          default:
            for (String j in v.keys.toList()) {
              list[i][j] = await sheet.read(v[j], TableType.normal);
              replace(list, i, j);
            }
        }
      }
    }
  }
  return list;
}

