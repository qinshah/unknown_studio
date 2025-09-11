import 'dart:io';

class EntityNode {
  final FileSystemEntity entity;
  List<EntityNode> children = [];
  bool isLoading = false;

  EntityNode(this.entity);

  @override
  String toString() {
    return entity.path;
  }
}
