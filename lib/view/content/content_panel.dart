import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import 'package:open_file_ohos/open_file_ohos.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/panel_model.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  Node? _root;
  TreeController<Node>? _treeController;

  @override
  void initState() {
    super.initState();
  }

  _openCentent() async {
    var dirPath = await getDirectoryPath();
    if (dirPath == null) return;
    setState(() {
      _root = Node(Directory(dirPath));
    });
    _treeController?.dispose();
    _treeController = TreeController<Node>(
      roots: _root!.children,
      childrenProvider: (node) => node.children,
    );
    _loadChildren(_root!, loadedDepth: 0, depth: 1).then((_) {
      _treeController?.rebuild();
    });
  }

  Future<void> _loadChildren(
    Node node, {
    required int loadedDepth,
    required int depth,
  }) async {
    var entity = node.entity;
    if (loadedDepth >= depth || entity is! Directory) return;
    print('加载${entity.path}目录');
    try {
      await for (var entity in entity.list()) {
        var childNode = Node(entity);
        node.children.add(childNode);
        if (entity is Directory) {
          await _loadChildren(
            childNode,
            loadedDepth: loadedDepth + 1,
            depth: depth,
          );
        }
      }
      node.childrenLoaded = true;
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
              icon: Icon(BootstrapIcons.folder2Open),
              size: ButtonSize.small,
              onPressed: _openCentent,
            ),
            IconButton.ghost(
              icon: Icon(LucideIcons.folderX),
              size: ButtonSize.small,
              onPressed: () => setState(() => _root = null),
            ),
          ]),
        ),
        Expanded(
          child: _root == null || _treeController == null
              ? Center(
                  child: Button.primary(
                      onPressed: _openCentent, child: Text('打开目录')),
                )
              : AnimatedTreeView(
                  treeController: _treeController!,
                  nodeBuilder: (context, entry) {
                    final node = entry.node;
                    if (!node.childrenLoaded) {
                      _loadChildren(node, depth: 1, loadedDepth: 0).then((_) {
                        node.childrenLoaded = true;
                        _treeController?.rebuild();
                      });
                    }
                    final entity = entry.node.entity;
                    return m.Material(
                      color: Colors.transparent,
                      child: m.InkWell(
                        hoverColor: Colors.gray[100],
                        splashFactory: m.NoSplash.splashFactory, // 禁用涟漪效果
                        onTap: () => _treeController?.toggleExpansion(node),
                        onLongPress: () {
                          if (entity is File) {
                            OpenFile.open(entity.path);
                          }
                        },
                        child: SizedBox(
                          height: 25,
                          child: TreeIndentation(
                            entry: entry,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              child: Row(
                                children: [
                                  entity is File
                                      ? Icon(
                                          LucideIcons.dot,
                                          size: 16,
                                          color: Colors.gray[400],
                                        )
                                      : AnimatedRotation(
                                          turns: entry.isExpanded ? 0.25 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: Icon(
                                            RadixIcons.caretRight,
                                            size: 16,
                                            color: Colors.gray[400],
                                          ),
                                        ),
                                  switch (entity is File
                                      ? null
                                      : entry.isExpanded) {
                                    null => Icon(
                                        BootstrapIcons.fileEarmarkTextFill,
                                        color: Colors.gray[400],
                                      ),
                                    true => Icon(LucideIcons.folderOpen),
                                    false => Icon(LucideIcons.folder),
                                  },
                                  const SizedBox(width: 2),
                                  Text(entity.path.split('/').last),
                                ],
                              ),
                            ),
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

class Node {
  final FileSystemEntity entity;
  List<Node> children = [];
  bool childrenLoaded = false;

  Node(this.entity);

  @override
  String toString() {
    return entity.path;
  }
}
