import 'dart:io';

import 'package:animated_tree_view/animated_tree_view.dart' as t;
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/panel_model.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  t.TreeNode<FileSystemEntity> _tree = t.TreeNode.root(data: Directory('/'));

  @override
  void initState() {
    super.initState();
    _initFileTree();
  }

  void _initFileTree() async {
    final tree = t.TreeNode.root(data: Directory('/'));
    await _getNodeChildren(node: tree, currentDepth: 0);
    setState(() {
      _tree = tree;
    });
  }

  Future<void> _getNodeChildren({
    required t.TreeNode<FileSystemEntity> node,
    required int currentDepth,
    int maxDepth = 3,
  }) async {
    if (currentDepth >= maxDepth || node.data is! Directory) return;
    var dir = node.data as Directory;
    try {
      for (var entity in await dir.list().toList()) {
        var childNode = t.TreeNode(data: entity);
        node.add(childNode);
        await _getNodeChildren(node: childNode, currentDepth: currentDepth + 1);
      }
    } catch (e) {
      print('Error listing directory: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            Text(Panel.content.title),
            Spacer(),
            IconButton.ghost(
              icon: Icon(Icons.more_horiz),
              size: ButtonSize.small,
              onPressed: () {},
            )
          ]),
        ),
        Expanded(
          child: t.TreeView.simple<FileSystemEntity>(
            showRootNode: false,
            scrollController: t.AutoScrollController(),
            tree: _tree,
            expansionIndicatorBuilder: (context, node) =>
                t.ChevronIndicator.rightDown(
              tree: node,
              alignment: Alignment.centerLeft,
              // padding: const EdgeInsets.all(8),
            ),
            indentation: const t.Indentation(style: t.IndentStyle.roundJoint),
            builder: (context, node) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
                child: material.Row(
                  children: [
                    Icon(node.data is File
                        ? Icons.insert_drive_file
                        : node.isExpanded
                            ? Icons.folder_open
                            : Icons.folder),
                    Expanded(
                      child: Text(
                        node.data?.path.split('/').last ?? '',
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
