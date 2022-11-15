import 'package:fluent_ui/fluent_ui.dart';
import 'package:neko_cc/widget/flow.dart';
import '../widget/charTable.dart';
import '../widget/overlay.dart';
import '../part.dart';

class CharTab extends StatefulWidget {
  final Map? file;

  const CharTab({super.key, this.file});

  @override
  State<CharTab> createState() => _CharTabState();
}

class _CharTabState extends State<CharTab> {
  Map? file;
  ValueNotifier<int> index = ValueNotifier<int>(0);

  _CharTabState();

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
              PaneItemHeader(header: NekoRow(children: [
                IconButton(icon: const Icon(FluentIcons.chevron_left), onPressed:(){
                  for (var i in nekoKey.exp.list) {
                    if (i.currentState != null) {
                      i.currentState.updateOpen(false);
                    }}}),
                IconButton(icon: const Icon(FluentIcons.chevron_right), onPressed:(){
                  for (var i in nekoKey.exp.list) {
                    if (i.currentState != null) {
                      i.currentState.updateOpen(true);
                    }}}),
              ]))
            ]));
  }
}
