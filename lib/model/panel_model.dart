import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../view/content_panel/content_panel.dart';
import '../view/scratch/mc_launch_panel.dart';
import '../view/scratch/web_panel.dart';

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
  plugin(
    '插件',
    RadixIcons.dashboard,
    Center(child: Text('插件')),
  ),
  webview(
    '网页(测试)',
    BootstrapIcons.browserChrome,
    WebPanel(),
  ),
  mcLaunch(
    'MC启动',
    BootstrapIcons.boxes,
    McLaunchPanel(),
  ),
  ;

  final String title;
  final IconData iconData;
  final Widget view;
  const Panel(this.title, this.iconData, this.view);
}

