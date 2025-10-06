import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:open_file/open_file.dart'
    if (Platform.isOhos) 'package:open_file_ohos/open_file_ohos.dart';

import '../../model/entity_node.dart';
import '../../model/panel_model.dart';
import '../../state/tabs_state.dart';
import '../../state/content_state.dart';

class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  final _contentState = ContentState();
  TapDownDetails _tapDownDetails = TapDownDetails();

  Future<void> _openCentent() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isDenied) return;
    }
    try {
      _contentState.loadContent(await getDirectoryPath());
    } on Exception catch (e) {
      print('打开目录失败：$e');
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
            const Spacer(),
            IconButton.ghost(
              icon: const Icon(BootstrapIcons.folder2Open),
              size: ButtonSize.small,
              onPressed: _openCentent,
            ),
            IconButton.ghost(
              icon: const Icon(LucideIcons.folderX),
              size: ButtonSize.small,
              onPressed: _contentState.clearContent,
            ),
          ]),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _contentState,
            builder: (context, _) {
              final root = _contentState.root;
              final treeController = _contentState.treeController;
              if (root == null || treeController == null) {
                return m.Center(
                  child: Button.primary(
                    onPressed: null,
                    child: const Text('打开目录(暂不支持鸿蒙)'),
                  ),
                );
              }
              // TODO 第一次显示时会很卡顿
              return AnimatedTreeView<EntityNode>(
                key: PageStorageKey('TreeView'),
                treeController: treeController,
                nodeBuilder: (context, entry) {
                  final node = entry.node;
                  final entity = node.entity;
                  final pathEnd =
                      entity.path.split(Platform.pathSeparator).last;
                  final entityName = pathEnd.isEmpty ? entity.path : pathEnd;
                  return m.Material(
                    color: m.Colors.transparent,
                    child: m.InkWell(
                      hoverColor: Colors.gray.shade200,
                      splashFactory: m.NoSplash.splashFactory,
                      onTap: () async {
                        if (entity is Directory) {
                          if (!entry.isExpanded && node.children.isEmpty) {
                            await _contentState.loadChildren(
                              node,
                              depth: 1,
                              loadedDepth: 0,
                            );
                          }
                          _contentState.treeController?.toggleExpansion(node);
                        } else if (entity is File) {
                          TabsState().add(entity);
                        }
                      },
                      onTapDown: (details) => _tapDownDetails = details,
                      onSecondaryTapDown: (details) =>
                          _tapDownDetails = details,
                      onSecondaryTap: () => _showContextMenu(entity),
                      onLongPress: () => _showContextMenu(entity),
                      child: SizedBox(
                        height: 25,
                        child: TreeIndentation(
                          entry: entry,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              children: [
                                if (entity is File)
                                  FileIcon(entityName, size: 16)
                                else if (node.children.length <
                                    node.childrenLength)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    width: 16,
                                    height: 16,
                                    child: m.CircularProgressIndicator(
                                      value: node.children.length /
                                          node.childrenLength,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  AnimatedRotation(
                                    turns: entry.isExpanded ? 0.25 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Icon(
                                      RadixIcons.caretRight,
                                      size: 16,
                                      color: Colors.gray,
                                    ),
                                  ),
                                const SizedBox(width: 2),
                                Text(
                                  entityName,
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
              );
            },
          ),
        ),
      ],
    );
  }

  void _showContextMenu(FileSystemEntity entity) {
    m.showMenu(
      context: context,
      position: m.RelativeRect.fromRect(
        _tapDownDetails.globalPosition & const Size(40, 40),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: [
        m.PopupMenuItem(
          onTap: () => OpenFile.open(entity.path),
          child: const Text('默认应用打开'),
        ),
      ],
    );
  }
}
