import 'dart:io';

class EntityNode {
  final FileSystemEntity entity;
  List<EntityNode> children = [];
  int childrenLength = 0;

  EntityNode(this.entity);

  @override
  String toString() {
    return entity.path;
  }
}
