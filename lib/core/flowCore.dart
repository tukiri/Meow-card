
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import 'package:hive/hive.dart';
import '../core/baseCore.dart';
import '../core/imageCore.dart';
import '../core/styleCore.dart';

class ClsCol extends Column {
  ClsCol({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.children,
  });

  @override
  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.start;
}

class ClsRow extends Row {
  ClsRow({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.children,
  });

  @override
  CrossAxisAlignment get crossAxisAlignment => CrossAxisAlignment.start;
}

class ClsCard extends StatefulWidget {
  final Widget? child;
  final double? width;
  Color borderColor;
  Color color;

  ClsCard(
      {super.key,
      this.child,
      this.width,
      this.color = Colors.white,
      this.borderColor = Colors.grey});

  @override
  State<ClsCard> createState() => _ClsCardState();
}

class _ClsCardState extends State<ClsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          // 背景色
          color: widget.color,
          border: new Border.all(
              color: widget.borderColor.withOpacity(.4), width: 0.5),
          // border
          borderRadius: BorderRadius.circular((4)),
        ),
        child: widget.child);
  }
}

class ClsCharImg extends StatefulWidget {
  const ClsCharImg({
    super.key,
    required this.file,
  });

  final Map? file;


  @override
  State<ClsCharImg> createState() => _ClsCharImgState();
}

class _ClsCharImgState extends State<ClsCharImg> {
  @override
  Widget build(BuildContext context) {
    return ClsCol(children: [
      ClsRow(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                // 背景色
                color: Colors.white,
                border: new Border.all(
                    color: Colors.grey.withOpacity(.4), width: 0.5),
                // border
                borderRadius: BorderRadius.circular((4)),
                // 圆角
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.4),
                    offset: Offset(0.0, 1.0),
                    //阴影xy轴偏移量
                    blurRadius: 5.0,
                    //阴影模糊程度
                    spreadRadius: -5,
                    //阴影扩散程度
                    blurStyle: BlurStyle.outer,
                  )
                ]),
            child: FutureBuilder(
                future: RecallImg(widget.file),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      return Image.file(
                        new File(snapshot.data.toString()),
                        fit: BoxFit.fitWidth,
                        width: 300,
                        height: 400,
                      );
                    default:
                      return Icon(
                        FluentIcons.sync_occurence,
                      );
                  }
                }))
      ])
    ]);
  }
}

class ClsTextTitle extends StatefulWidget {
  const ClsTextTitle({
    super.key,
    this.text,
  });

  final String? text;

  @override
  State<ClsTextTitle> createState() => _ClsTextTitleState();
}

class _ClsTextTitleState extends State<ClsTextTitle> {
  @override
  Widget build(BuildContext context) {
    return ClsRow(children: [
      Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
          child: Container(
              decoration: BoxDecoration(color: Colors.teal.lightest),
              padding: EdgeInsets.only(left: 5))),
      Expanded(
          child: Container(
              padding: const EdgeInsets.only(top: 5),
              decoration: const BoxDecoration(color: Colors.white),
              child: Text(widget.text.toString(),
                  overflow: TextOverflow.ellipsis, style:NekoText.topTitle)))
    ]);
  }
}

