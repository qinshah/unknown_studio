import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/entity_node.dart';
import '../../model/panel_model.dart';
import '../../state/tabs_state.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  EntityNode? _root;
  TreeController<EntityNode>? _treeController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _openCentent() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isDenied) return;
    }
    var dirPath = await getDirectoryPath();
    if (dirPath == null) return;
    setState(() {
      _root = EntityNode(Directory(dirPath));
    });
    _treeController?.dispose();
    _treeController = TreeController<EntityNode>(
      roots: _root!.children,
      childrenProvider: (node) => node.children,
    );
    _loadChildren(_root!, loadedDepth: 0, depth: 1).then((_) {
      _treeController?.rebuild();
    });
  }

  Future<void> _loadChildren(
    EntityNode node, {
    required int loadedDepth,
    required int depth,
  }) async {
    var entity = node.entity;
    if (loadedDepth >= depth || entity is! Directory) return;
    print('加载${entity.path}目录');

    setState(() {
      node.isLoading = true;
    });

    try {
      List<EntityNode> dirChildren = [];
      List<EntityNode> fileChildren = [];
      await for (var entity in entity.list()) {
        var childNode = EntityNode(entity);
        if (entity is Directory) {
          dirChildren.add(childNode);
          if (loadedDepth + 1 < depth) {
            await _loadChildren(
              childNode,
              loadedDepth: loadedDepth + 1,
              depth: depth,
            );
          }
        } else {
          fileChildren.add(childNode);
        }
      }
      // 按字母排序后又将文件夹排在前面
      dirChildren.sort((a, b) =>
          a.entity.path.toLowerCase().compareTo(b.entity.path.toLowerCase()));
      fileChildren.sort((a, b) =>
          a.entity.path.toLowerCase().compareTo(b.entity.path.toLowerCase()));
      node.children.clear();
      node.children.addAll(dirChildren);
      node.children.addAll(fileChildren);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        node.isLoading = false;
      });
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
                    onPressed: _openCentent,
                    child: Text('打开目录'),
                  ),
                )
              : AnimatedTreeView(
                  treeController: _treeController!,
                  nodeBuilder: (context, entry) {
                    final node = entry.node;
                    final entity = node.entity;
                    final entityName = entity.path.split('/').last;

                    return m.Material(
                      color: Colors.transparent,
                      child: m.InkWell(
                        hoverColor: Colors.gray[100],
                        splashFactory: m.NoSplash.splashFactory,
                        onTap: () async {
                          if (entity is Directory && !node.isLoading) {
                            if (!entry.isExpanded) {
                              await _loadChildren(node,
                                  depth: 1, loadedDepth: 0);
                              _treeController?.rebuild();
                            }
                            _treeController?.toggleExpansion(node);
                          } else if (entity is File) {
                            TabsState().add(node);
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
                                      ? FileIcon(entityName, size: 16)
                                      : node.isLoading
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child:
                                                  m.CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : AnimatedRotation(
                                              turns:
                                                  entry.isExpanded ? 0.25 : 0.0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                              child: Icon(
                                                RadixIcons.caretRight,
                                                size: 16,
                                                color: Colors.gray[400],
                                              ),
                                            ),
                                  const SizedBox(width: 2),
                                  Text(
                                    entityName,
                                    // 隐藏文件减弱视觉效果
                                    style: TextStyle(
                                      color: entityName[0] == '.'
                                          ? Colors.gray
                                          : null,
                                    ),
                                  ),
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
