import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';

import '../part.dart';

class NekoCol extends Column {
  NekoCol({
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

class NekoRow extends Row {
  NekoRow({
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

class NekoCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final Color borderColor;
  final Color color;

  const NekoCard(
      {super.key,
      required this.child,
      this.width,
      this.color = Colors.white,
      this.borderColor = Colors.grey});

  @override
  State<NekoCard> createState() => _NekoCardState();
}

class _NekoCardState extends State<NekoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border.all(
              color: widget.borderColor.withOpacity(.4), width: 0.5),
          borderRadius: BorderRadius.circular((4)),
        ),
        child: widget.child);
  }
}

class  nekoCharImg extends StatefulWidget {
  const nekoCharImg({
    super.key,
    required this.file,
  });

  final Map? file;


  @override
  State<nekoCharImg> createState() => _nekoCharImgState();
}

class _nekoCharImgState extends State<nekoCharImg> {
  @override
  Widget build(BuildContext context) {
    return NekoCol(children: [
      NekoRow(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: Colors.grey.withOpacity(.4), width: 0.5),
                borderRadius: BorderRadius.circular((4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.4),
                    offset: const Offset(0.0, 1.0),
                    blurRadius: 5.0,
                    spreadRadius: -5,
                    blurStyle: BlurStyle.outer,
                  )
                ]),
            child: FutureBuilder(
                future:initImg(widget.file),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      return Image.file(
                        File(snapshot.data.toString()),
                        alignment:Alignment.topCenter,
                        fit: BoxFit.fitWidth,
                        width: 300,
                        height: 400,
                      );
                    default:
                      return const Icon(
                        FluentIcons.sync_occurence,
                      );
                  }
                }))
      ])
    ]);
  }
}

class  nekoTextTitle extends StatefulWidget {
  const nekoTextTitle({
    super.key,
    this.text,
  });

  final String? text;

  @override
  State<nekoTextTitle> createState() => _nekoTextTitleState();
}

class _nekoTextTitleState extends State<nekoTextTitle> {
  @override
  Widget build(BuildContext context) {
    return NekoRow(children: [
      Container(
          padding: const EdgeInsets.only(top: 5, bottom: 5, right: 5),
          child: Container(
              decoration: BoxDecoration(color: Colors.teal.lightest),
              padding: const EdgeInsets.only(left: 5))),
      Expanded(
          child: Container(
              padding: const EdgeInsets.only(top: 5),
              decoration: const BoxDecoration(color: Colors.white),
              child: Text(widget.text.toString(),
                  overflow: TextOverflow.ellipsis, style:NekoText.topTitle)))
    ]);
  }
}

