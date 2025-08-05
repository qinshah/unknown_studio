import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../view/content/content_panel.dart';

enum Panel {
  content(
    '目录',
    Icons.file_copy_outlined,
    ContentPanel(),
  ),
  search(
    '搜索',
    Icons.search_outlined,
    Center(child: Text('搜索')),
  ),
  code(
    '代码管理',
    LucideIcons.gitFork,
    Center(child: Text('代码管理')),
  ),
  debug(
    '运行调试',
    LucideIcons.bugPlay,
    Center(child: Text('运行调试')),
  ),
  remote(
    '远程资源',
    RadixIcons.cardStackMinus,
    Center(child: Text('远程资源')),
  ),
  plugin(
    '插件',
    RadixIcons.dashboard,
    Center(child: Text('插件')),
  ),
  test(
    '测试',
    LucideIcons.testTubeDiagonal,
    Center(child: Text('测试')),
  ),
  ;

  final String title;
  final IconData iconData;
  final Widget view;
  const Panel(this.title, this.iconData, this.view);
}
