library neko;


import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';




import '../pages/configTab.dart';
import '../pages/charTab.dart';
import '../pages/mainTab.dart';
import '../widget/flow.dart';
import '../widget/dialog.dart';
import '../widget/toast.dart';

part 'core/baseCore.dart';
part 'core/dataCore.dart';
part 'core/excelCore.dart';
part 'core/fileCore.dart';
part 'core/imageCore.dart';
part 'core/keyCore.dart';
part 'core/mainCore.dart';
part 'core/styleCore.dart';
part 'core/tableCore.dart';
