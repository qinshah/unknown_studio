import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/entity_node.dart';

class TabsState extends ChangeNotifier {
  TabsState._();
  static final TabsState _instance = TabsState._();
  factory TabsState() => _instance;

  List<TabPaneData<EntityNode>> tabs = [];
  int index = 0;

  late int maxIndex = tabs.length;

  int get focused {
    if (tabs.isEmpty) return 0;
    index = index.clamp(0, tabs.length - 1);
    return index;
  }

  // TODO 区分单击临时添加和双击永久添加
  void add(EntityNode node) {
    maxIndex;
    if (tabs.isNotEmpty) {
      index++;
    }
    tabs.insert(index, TabPaneData(node));
    notifyListeners(); // 通知监听器状态已更改
  }
}
