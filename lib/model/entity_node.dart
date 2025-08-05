import 'dart:io';

class EntityNode {
  final FileSystemEntity entity;
  List<EntityNode> children = [];
  bool childrenLoaded = false;

  EntityNode(this.entity);

  @override
  String toString() {
    return entity.path;
  }
}
