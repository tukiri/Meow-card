import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:neko_cc/widget/toast.dart';

import '../core/flowCore.dart';
import '../core/baseCore.dart';
import '../core/styleCore.dart';

class ClsTable extends StatefulWidget {
  final map;
  final String value;
  final int type;
  final Widget? header;
  TableColumnWidth? headerColWidth;

  ClsTable(
      {super.key,
      required this.map,
      required this.value,
      this.type = TableType.normal,
      this.headerColWidth,
      this.header});

  @override
  State<ClsTable> createState() => _ClsTableState();
}

class _ClsTableState extends State<ClsTable> {
  @override
  Widget build(BuildContext context) {
    ClsTableChildren(map, value) {
      var box = Hive.box("config");
      var boxData = box.get("view");
      var data = boxData["char"][value];
      List l = [];
      switch (widget.type) {
        case TableType.attr:
          l = ClsSource(data, map).attr;
          break;
        case TableType.judge:
          l = ClsSource(data, map).judge;
          break;
        case TableType.studyAbility:
          l = ClsSource(data, map).studyAbility;
          break;
        case TableType.ability:
          l = ClsSource(data, map).ability;
          break;
        case TableType.title:
          l = ClsSource(data, map).title;
          break;
        default:
          for (var a in data) {
            l.add([map[a[2]][0], map[a[2]][1]]);
          }
      }
      List<TableRow> list = [];
      switch (widget.type) {
        case TableType.judge:
          l.removeAt(0);
          for (var i in l) {
            list.add(ClsJudgeTableRow(i));
          }
          break;
        case TableType.studyAbility:
        case TableType.ability:
          l.removeAt(0);
          for (var i in l) {
            list.add(ClsAbilityTableRow(i));
          }
          break;
        case TableType.title:
          list.add(ClsTitleTableRow(l[0], l[1]));
          break;
        default:
          for (var i in l) {
            list.add(ClsTableRow(i));
          }
      }

      return list;
    }

    if (widget.header != null) {
      return ClsCard(
          child: ClsCol(children: [
        Container(width: double.infinity, child: widget.header),
        Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: <int, TableColumnWidth>{
              0: widget.headerColWidth == null
                  ? FixedColumnWidth(120)
                  : widget.headerColWidth!,
              1: FlexColumnWidth()
            },
            children: ClsTableChildren(widget.map, widget.value))
      ]));
    } else {
      return ClsCard(
          child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: <int, TableColumnWidth>{
                0: widget.headerColWidth == null
                    ? FixedColumnWidth(120)
                    : widget.headerColWidth!,
                1: FlexColumnWidth()
              },
              children: ClsTableChildren(widget.map, widget.value)));
    }
  }

  ClsTableRow(List i) {
    var name = i[0];
    List<Widget> list = [];
    i.removeAt(0);
    for (var a in i) {
      list.add(SizedBox(width: 5));
      list.add(Expanded(
          child: Container(
        padding: EdgeInsets.only(right: 5),
        child: Text(a.toString(), style: ClsFontContent),
      )));
    }

    return TableRow(children: [
      ClsRow(children: [
        Expanded(
            child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.teal.lightest.withOpacity(0.6),
            border: new Border.all(color: Colors.white, width: 0.5),
          ),
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
          child: Text(name.toString(), style: ClsFontContentBold),
        )),
        SizedBox(width: 10)
      ]),
      Container(
        decoration: BoxDecoration(
          border: new Border(
              bottom:
                  BorderSide(color: Colors.grey.withOpacity(0.4), width: 0.8)),
        ),
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 8, right: 10),
        child: ClsRow(children: list),
      )
    ]);
  }

  ClsJudgeTableRow(List i) {
    ButtonStyle button = ButtonStyle(
        elevation: ButtonState.all(0),
        shadowColor: ButtonState.all(Colors.transparent),
        foregroundColor: ButtonState.resolveWith((states) {
          return Colors.black;
        }),
        backgroundColor: ButtonState.all(Colors.transparent),
        border:
            ButtonState.all(BorderSide(color: Colors.transparent, width: 0)),
        shape: ButtonState.all(RoundedRectangleBorder(side: BorderSide.none)),
        padding: ButtonState.all(EdgeInsets.all(0)));

    var name = i[0];
    List<Widget> list = [];
    i.removeAt(0);
    list.add(Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 5),
        width: double.infinity,
        child: Text(i[0], textAlign: TextAlign.left, style: ClsFontContent)));
    list.add(ClsRow(children: [
      ClsCard(child: Text(i[1], style: ClsFontContent)),
      ClsCard(child: Text(i[2], style: ClsFontContent)),
      Expanded(child: ClsCard(child: Text(i[3], style: ClsFontContent))),
    ]));

    return TableRow(children: [
      ClsRow(children: [
        Expanded(
            child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.teal.lightest.withOpacity(0.6),
            border: new Border.all(color: Colors.white, width: 0.5),
          ),
          padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
          child: Text(name.toString(), style: ClsFontContentBold),
        )),
        SizedBox(width: 10)
      ]),
      Container(
          padding: EdgeInsets.only(left: 0, top: 10, bottom: 8, right: 0),
          child: Button(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: i[3]));
                Toast.show("结果已复制", gravity: Toast.bottom);
              },
              style: button,
              child: ClsCol(children: list)))
    ]);
  }
}

ClsTitleTableRow(List title, List titleContent) {
  return TableRow(children: [
    ClsCard(
        child: ClsCol(children: [
      ClsRow(children: [
        Expanded(child: SizedBox()),
        IconButton(
            icon: const Icon(FluentIcons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: title[1]));
              Toast.show("结果已复制", gravity: Toast.bottom);
            })
      ]),
      Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          padding: EdgeInsets.only(left: 10, bottom: 5),
          child: Text(title[1],
              textAlign: TextAlign.left, style: NekoText.nromalContent)),
      Container(
          width: double.infinity,
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.2), width: 1)),
          child: SelectableText(titleContent[1],
              style: NekoText.nromalContent, textAlign: TextAlign.start))
    ]))
  ]);
}

ClsAbilityTableRow(List i) {
  return TableRow(children: [
    Container(
        width: double.infinity,
        padding: EdgeInsets.all(5),
        child: ClsCol(children: [
          ClsRow(children: [
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: Text(
                  i[0],
                  style: NekoText.topContent,
                  textAlign: TextAlign.start,
                  strutStyle: const StrutStyle(
                    fontSize: 12,
                    leading: 0,
                    height: 1.1,
                    // 1.1更居中
                    forceStrutHeight: true, // 关键属性 强制改为文字高度
                  ),
                )),
            Expanded(child: SizedBox()),
            IconButton(
                icon: const Icon(FluentIcons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: i[1]));
                  Toast.show("结果已复制", gravity: Toast.bottom);
                })
          ]),
          SizedBox(height: 10),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[20]),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: SelectableText(i[1],
                  style: NekoText.nromalContent, textAlign: TextAlign.start)),
        ]))
  ]);
}

class ClsSource {
  var data;
  var map;

  ClsSource(this.data, this.map);

  get attr {
    List list = [];

    List l = [];
    List ll = [];
    for (var a = 0; a < data[0].length; a++) {
      ll.add(map[data[data.length - 1][a][2]][data[data.length - 1][a][3]][0]);
    }
    l.add(ll);
    for (var a in data) {
      ll = [];
      for (var b = 0; b < a.length; b++) {
        ll.add(map[a[b][2]][a[b][3]][1]);
      }
      l.add(ll);
    }

    var c = l.reversed.toList();
    l = [];
    for (var a = 0; a < c[0].length; a++) {
      l.add([]);
    }
    for (var a = 0; a < c.length; a++) {
      for (var b = 0; b < c[0].length; b++) {
        l[b].add(c[a][b]);
      }
    }
    for (var a = 0; a < l.length; a++) {
      l[a] = l[a].reversed.toList();
    }
    for (var a = 1; a < l.length; a++) {
      list.add(l[a]);
    }
    l[0][0] = "类别";
    list.insert(0, l[0]);

    return list;
  }

  get judge {
    var mapName = map["公式判定"]["行名"];
    List name = List.from(data[0]);
    List list = [];
    List l = [];
    List judgeData = List.from(data);
    judgeData.removeAt(0);
    for (var i in judgeData) {
      l.add(map[i[2]][i[3]]);
    }

    for (var a = 0; a < l.length; a++) {
      list.add([]);
      for (var b in name) {
        var c = mapName.indexOf(b);
        if (c != -1) {
          list[a].add(l[a][c]);
        }
      }
    }
    list.insert(0, name);
    return list;
  }

  get ability {
    List list = [];
    List judgeData = List.from(data);
    for (var i in judgeData) {
      list.add(map[i[2]][i[3]]);
    }
    return list;
  }

  get title {
    List list = [];
    List titleData = List.from(data);
    for (var i in titleData) {
      list.add(map[i[2]]);
    }
    return list;
  }

  get studyAbility {
    List list = [];
    List judgeData = List.from(data);
    for (var i in judgeData) {
      list.add(map[i[2]][i[3]]);
    }
    return list;
  }
}
