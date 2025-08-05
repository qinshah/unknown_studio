import 'dart:io';

import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/entity_node.dart';
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
          return TabPane<EntityNode>(
            items: TabsState().tabs,
            itemBuilder: (context, item, index) => _tabView(index),
            focused: TabsState().focused,
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
            child: TabsState().tabs.isEmpty
                ? Center(child: Text('从目录选择文件'))
                : FileView(
                    TabsState().tabs[TabsState().focused].data.entity as File,
                  ),
          );
        },
      ),
    );
  }

  TabItem _tabView(int index) {
    final entityNode = TabsState().tabs[index].data;
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
            Text(entityNode.entity.path.split('/').last),
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
}
