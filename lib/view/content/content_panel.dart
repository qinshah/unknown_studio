import 'dart:io';

import 'package:flutter/material.dart' as m;
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart'
    as t;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/panel_model.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  List<t.TreeViewNode<FileSystemEntity>>? _tree;

  var _treeController = t.TreeViewController();
  @override
  void initState() {
    super.initState();
    _initTree();
  }

  void _initTree() async {
    var root = t.TreeViewNode<FileSystemEntity>(Directory('/'));
    await _getTree(root, currentDepth: 1, depth: 3);
    setState(() {
      _tree = root.children;
    });
  }

  Future<void> _getTree(
    t.TreeViewNode<FileSystemEntity> root, {
    required int currentDepth,
    required int depth,
  }) async {
    var content = root.content;
    if (currentDepth >= depth || content is! Directory) return;
    try {
      await for (var entity in content.list()) {
        var child = t.TreeViewNode(entity);
        root.children.add(child);
        if (entity is Directory) {
          await _getTree(
            child,
            currentDepth: currentDepth + 1,
            depth: depth,
          );
        }
      }
    } catch (e) {
      print(e);
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
          child: _tree == null
              ? Center(child: Text('空'))
              : t.TreeView(
                  controller: _treeController,
                  tree: _tree!,
                  addRepaintBoundaries: false,
                  treeNodeBuilder: (context, node, _) {
                    return SizedBox(
                      height: 2,
                      width: MediaQuery.of(context).size.width,
                      child: m.Material(
                        color: Colors.transparent,
                        child: m.InkWell(
                          onTap: () => _treeController.toggleNode(node),
                          child: Row(
                            children: <Widget>[
                              AnimatedRotation(
                                turns: node.isExpanded ? 0.25 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  RadixIcons.caretRight,
                                  size: 16,
                                  color: node.children.isEmpty
                                      ? Colors.transparent
                                      : null,
                                ),
                              ),
                              Text(node.content.path.split('/').last),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
