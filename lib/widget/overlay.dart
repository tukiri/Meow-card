import 'package:fluent_ui/fluent_ui.dart';
import '../part.dart';

IconButton menuButton = IconButton(
              icon: const Icon(FluentIcons.collapse_menu, size: 16),
              onPressed: () {
                nekoKey.nav.currentState?.minimalPaneOpen = true;
              });

