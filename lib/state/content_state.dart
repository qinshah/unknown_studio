import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_fancy_tree_view2/flutter_fancy_tree_view2.dart';
import '../main.dart';
import '../model/entity_node.dart';

class ContentState extends ChangeNotifier {
  ContentState._();
  static final ContentState i = ContentState._();
  factory ContentState() => i;

  EntityNode? root;
  TreeController<EntityNode>? treeController;

  Future<void> loadContent(String? dirPath) async {
    if (dirPath == null) return;
    root = EntityNode(Directory(dirPath));
    treeController?.dispose();
    treeController = TreeController<EntityNode>(
      roots: [root!],
      childrenProvider: (node) => node.children,
    );
    notifyListeners();
    await _loadChildren(root!, loadedDepth: 0, depth: 1);
    treeController!.expand(root!);
  }

  void clearContent() {
    root = null;
    treeController?.dispose();
    treeController = null;
    notifyListeners();
  }

  Future<void> loadChildren(
    EntityNode node, {
    required int loadedDepth,
    required int depth,
  }) async {
    await _loadChildren(node, loadedDepth: loadedDepth, depth: depth);
    treeController?.rebuild();
    notifyListeners();
  }

  Future<void> _loadChildren(
    EntityNode node, {
    required int loadedDepth,
    required int depth,
  }) async {
    var entity = node.entity;
    if (loadedDepth >= depth || entity is! Directory) return;

    final childCount = await entity.list().length;
    node.children.clear();
    node.childrenLength = childCount;
    notifyListeners();

    try {
      List<EntityNode> dirChildren = [];
      List<EntityNode> fileChildren = [];
      await for (var entity in entity.list()) {
        var childNode = EntityNode(entity);
        if (kDebugMode && MainApp.enableSlowSimulation) {
          // 调试模式耗时模拟
          await Future.delayed(const Duration(milliseconds: 5));
        }
        node.children.add(childNode);
        notifyListeners();

        if (entity is Directory) {
          dirChildren.add(childNode);
        } else {
          fileChildren.add(childNode);
        }
      }

      dirChildren.sort((a, b) =>
          a.entity.path.toLowerCase().compareTo(b.entity.path.toLowerCase()));
      fileChildren.sort((a, b) =>
          a.entity.path.toLowerCase().compareTo(b.entity.path.toLowerCase()));
      node.children.clear();
      node.children.addAll(dirChildren);
      node.children.addAll(fileChildren);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    treeController?.dispose();
    super.dispose();
  }
}
