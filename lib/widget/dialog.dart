import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:neko_cc/widget/toast.dart';
import 'package:scoped_model/scoped_model.dart';
import 'flow.dart';

import '../part.dart';

class DialogModel extends Model {
  //这里也可以使用with来进行实现
}

DialogModel dialogModel = DialogModel();
ValueNotifier<String> dialogText = ValueNotifier("");
ValueNotifier<String> warningText = ValueNotifier("");

showContentDialog(BuildContext context, String type) async {
  dialogText.value = "";
  showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
          content: Container(
              width: 400,
              height: 50,
              child: ScopedModel<DialogModel>(
                  model: dialogModel,
                  child: ScopedModelDescendant<DialogModel>(
                      builder: (context, child, model) => NekoCol(children: [
                            Container(
                                width: double.infinity,
                                child: const ProgressBar()),
                            Expanded(
                                child: ValueListenableBuilder(
                                    valueListenable: dialogText,
                                    builder: (context, value, widget) {
                                      return Center(
                                          child: Text(value,
                                              overflow: TextOverflow.ellipsis,
                                              style: nekoFontContent));
                                    }))
                          ]))))));
  Future.delayed(const Duration(microseconds: 100), () async {
    switch (type) {
      case "config":
        await loadFileModel();
        Navigator.pop(nekoKey.nav.currentContext!);
        break;
      case "cloud":
        await loadConfig(type: "cloud");
        break;
      case "cloud-open":
        await loadConfig(type: "cloud", open: true);
        break;
      case "file":
        await loadConfig(type: "file");
        break;
      default:
        break;
    }
    ;
  });
}

showWarningDialog(BuildContext context, String str) async {
  showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
              content: Container(
                  width: 400,
                  child: Text(str, style: nekoFontContent)),
              actions: [
                Button(
                  child: Text('返回', style: nekoFontContent),
                  onPressed: () {
                    Navigator.pop(nekoKey.nav.currentContext!);
                    // Delete file here
                  },
                ),
                FilledButton(
                    child: Text('复制', style: nekoFontContent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: str));
                      Toast.show("结果已复制",  gravity: Toast.bottom);
                    })
              ]));
}
