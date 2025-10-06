import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../state/tabs_state.dart';
import '../file/file_view.dart';

class TabsView extends StatefulWidget {
  const TabsView({super.key});

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.accent,
      child: ListenableBuilder(
        listenable: TabsState(),
        builder: (BuildContext context, _) {
          final focusedIndex = TabsState().focusedIndex;
          final fileTabs = TabsState().tabs;
          return TabPane(
            items: TabsState().tabs,
            itemBuilder: (context, item, index) => _tabView(index),
            focused: TabsState().focusedIndex,
            onFocused: (value) {
              setState(() {
                TabsState().index = value;
              });
            },
            onSort: (value) {
              setState(() {
                TabsState().tabs = value;
              });
            },
            child: fileTabs.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('从目录选择文件或'),
                      SizedBox(height: 6),
                      Button.primary(
                        onPressed: _openFile,
                        child: Text('打开单个文件'),
                      ),
                    ],
                  )
                : FileView(
                    fileTabs[focusedIndex].data,
                    key: Key(fileTabs[focusedIndex].data.path),
                  ),
          );
        },
      ),
    );
  }

  TabItem _tabView(int index) {
    final file = TabsState().tabs[index].data;
    return TabItem(
      // TODO 添加Tab hover效果
      child: GestureDetector(
        onTertiaryTapDown: (_) {
          setState(() {
            TabsState().tabs.removeAt(index);
          });
        },
        child: Row(
          children: [
            Text(file.path.split('/').last),
            IconButton.ghost(
              shape: ButtonShape.circle,
              size: ButtonSize.small,
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  TabsState().tabs.removeAt(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFile() async {
    final xFile = await openFile();
    if (xFile != null) {
      setState(() {
        TabsState().add(File(xFile.path));
      });
    }
  }
}
