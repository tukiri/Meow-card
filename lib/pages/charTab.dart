import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:neko_cc/core/flowCore.dart';
import '../core/mainCore.dart';
import '../core/styleCore.dart';
import '../widget/charTable.dart';
import '../widget/overlay.dart';

class CharTab extends StatefulWidget {
  final Map? file;

  const CharTab({this.file});

  @override
  State<CharTab> createState() => _CharTabState(file);
}

class _CharTabState extends State<CharTab> {
  Map? file;
  ValueNotifier<int> index = ValueNotifier<int>(0);

  _CharTabState(this.file);

  @override
  Widget build(BuildContext context) {
    return
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
              icon: const Icon(FluentIcons.contact),
              title: const Text("基础信息"),
              body: CharTable(file: file)
              )
        ],
            footerItems: [
              PaneItemHeader(header: ClsRow(children: [
                IconButton(icon: Icon(FluentIcons.chevron_left), onPressed:(){
                  for (var i in expanderKey) {
                    if (i.currentState != null) {
                      i.currentState.updateOpen(false);
                    }}}),
                IconButton(icon: Icon(FluentIcons.chevron_right), onPressed:(){
                  for (var i in expanderKey) {
                    if (i.currentState != null) {
                      i.currentState.updateOpen(true);
                    }}}),
              ]))
            ]));
  }
}
