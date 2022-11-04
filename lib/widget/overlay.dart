import 'dart:io';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../core/baseCore.dart';
import '../core/mainCore.dart';
import '../core/flowCore.dart';
import '../core/styleCore.dart';
import '../pages/mainTab.dart';
import 'dialog.dart';


IconButton menuButton = IconButton(
              icon: Icon(FluentIcons.collapse_menu, size: 16),
              onPressed: () {
                navKey.currentState?.minimalPaneOpen = true;
              });

