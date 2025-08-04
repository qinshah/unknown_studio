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
  t.TreeNode<FileSystemEntity> _root = t.TreeNode.root(data: Directory('/'));
  late t.TreeNode<FileSystemEntity> _hoverNode = _root;

  @override
  void initState() {
    super.initState();
    _initFileTree();
  }

  void _initFileTree() async {
    final root = t.TreeNode.root(data: Directory('/'));
    await _getChildren(root, startDepth: 0, endDepth: 2);
    setState(() {
      _root = root;
    });
  }

  Future<void> _getChildChildren(t.TreeNode<FileSystemEntity> node) async {
    for (var child in node.children.values) {
      if (child.children.isEmpty) {
        final entity = (child as t.TreeNode<FileSystemEntity>).data;
        final newChild = t.TreeNode(data: entity);
        await _getChildren(newChild, startDepth: 1, endDepth: 2);
        setState(() {
          child = child as t.TreeNode<FileSystemEntity>;
          child.addAll(newChild.childrenAsList);
        });
      }
    }
  }

  Future<void> _getChildren(
    t.TreeNode<FileSystemEntity> node, {
    required int startDepth,
    required int endDepth,
  }) async {
    if (startDepth >= endDepth || node.data is! Directory) return;
    var dir = node.data as Directory;
    try {
      for (var entity in await dir.list().toList()) {
        var childNode = t.TreeNode(data: entity);
        childNode.expansionNotifier.value = false;
        node.add(childNode);
        await _getChildren(
          childNode,
          startDepth: startDepth + 1,
          endDepth: endDepth,
        );
      }
    } catch (_) {}
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
            tree: _root,
            expansionBehavior: t.ExpansionBehavior.snapToTop,
            onItemTap: (node) {
              _hoverNode = node;
              _getChildChildren(node);
            },
            expansionIndicatorBuilder: (context, node) =>
                t.ChevronIndicator.rightDown(
              tree: node,
              alignment: Alignment.centerLeft,
              // padding: const EdgeInsets.all(8),
            ),
            indentation: const t.Indentation(style: t.IndentStyle.roundJoint),
            builder: (context, node) {
              final hoverNotify = ValueNotifier(node == _hoverNode);
              return MouseRegion(
                onHover: (event) => hoverNotify.value = true,
                onExit: (event) => hoverNotify.value = false,
                cursor: SystemMouseCursors.click,
                child: ValueListenableBuilder(
                    valueListenable: hoverNotify,
                    builder: (context, value, _) {
                      return ColoredBox(
                        color: value ? Colors.blue[50] : Colors.transparent,
                        child: Padding(
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
                        ),
                      );
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}
