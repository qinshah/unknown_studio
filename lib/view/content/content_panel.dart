import 'dart:io';

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../model/panel_model.dart';

// TODO 这个树组件bug有点多，换一个
class ContentPanel extends StatefulWidget {
  const ContentPanel({super.key});

  @override
  State<ContentPanel> createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  List<TreeNode<FileSystemEntity>> _fileTree = [];

  @override
  void initState() {
    super.initState();
    _initFileTree();
  }

  void _initFileTree() async {
    final rootDir = Directory('/');
    final nodes = await _getDirectoryContents(rootDir, 0, 2);
    setState(() {
      _fileTree = nodes;
    });
  }

  Future<List<TreeNode<FileSystemEntity>>> _getDirectoryContents(
      Directory directory, int currentDepth, int maxDepth) async {
    if (currentDepth >= maxDepth) {
      return [];
    }

    List<TreeNode<FileSystemEntity>> nodes = [];
    try {
      await for (var entity in directory.list()) {
        if (entity is Directory) {
          nodes.add(TreeItem(
            data: entity,
            children: await _getDirectoryContents(
                entity, currentDepth + 1, maxDepth),
          ));
        } else if (entity is File) {
          nodes.add(TreeItem(data: entity));
        }
      }
    } catch (e) {
      print('Error listing directory: $e');
    }
    return nodes;
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
          child: TreeView(
            recursiveSelection: false,
            nodes: _fileTree,
            onSelectionChanged: TreeView.defaultSelectionHandler(
              _fileTree,
              (value) {
                setState(() {
                  _fileTree = value;
                });
              },
            ),
            builder: (context, node) {
              return TreeItemView(
                onPressed: () {},
                leading: node.data is Directory
                    ? Icon(node.expanded
                        ? BootstrapIcons.folder2Open
                        : BootstrapIcons.folder2)
                    : const Icon(BootstrapIcons.fileImage),
                onExpand:
                    TreeView.defaultItemExpandHandler(_fileTree, node, (value) {
                  setState(() {
                    _fileTree = value;
                  });
                }),
                child: Text(node.data.path.split('/').last),
              );
            },
          ),
        ),
      ],
    );
  }
}
