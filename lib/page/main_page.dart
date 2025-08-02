import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'tabs/tabs_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _expanded = false;
  int? _index = 0;
  bool _showLeft = true;
  bool _showRight = true;
  bool _showBottom = true;
  DateTime _lastTapTime = DateTime(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Column(
        children: [
          _windowBar(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  padding: EdgeInsets.all(4),
                  labelType: NavigationLabelType.expanded,
                  labelPosition: NavigationLabelPosition.bottom,
                  alignment: NavigationRailAlignment.start,
                  expanded: _expanded,
                  index: _index,
                  onSelected: (value) {
                    setState(() {
                      if (value == _index) {
                        _index = null;
                        _showLeft = !_showLeft;
                      } else {
                        _index = value;
                        _showLeft = true;
                      }
                    });
                  },
                  children: [
                    NavigationButton(
                      alignment: Alignment.center,
                      label: const Text('收起'),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      child: const Icon(Icons.menu),
                    ),
                    NavigationDivider(color: Colors.slate[300]),
                    _buildButton(_NavItem.values[0]),
                    _buildButton(_NavItem.values[1]),
                    _buildButton(_NavItem.values[2]),
                    _buildButton(_NavItem.values[3]),
                    _buildButton(_NavItem.values[4]),
                    NavigationDivider(color: Colors.slate[300]),
                    _buildButton(_NavItem.values[5]),
                    _buildButton(_NavItem.values[6]),
                  ],
                ),
                Expanded(
                  child: ResizablePanel.horizontal(
                    draggerBuilder: (context) {
                      return const HorizontalResizableDragger();
                    },
                    dividerBuilder: (context) => _divider(
                      context,
                      Axis.vertical,
                    ),
                    children: [
                      if (_showLeft)
                        ResizablePane(
                          minSize: 100,
                          initialSize: 200,
                          child: Card(
                            padding: EdgeInsets.zero,
                            child: Center(
                              child: Text(_NavItem.values[_index ?? 0].title),
                            ),
                          ),
                        ),
                      ResizablePane.flex(
                        minSize: 100,
                        key: Key('MainPane'), // 不加key会导致关闭左侧面板后右侧面板占主要尺寸
                        child: ResizablePanel.vertical(
                          draggerBuilder: (context) {
                            return const HorizontalResizableDragger();
                          },
                          dividerBuilder: (context) => _divider(
                            context,
                            Axis.horizontal,
                          ),
                          children: [
                            ResizablePane.flex(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: TabsView(),
                              ),
                            ),
                            if (_showBottom)
                              ResizablePane(
                                minSize: 50,
                                initialSize: 150,
                                child: Card(
                                  padding: EdgeInsets.all(4),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text('底部面板'),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton.ghost(
                                              size: ButtonSize.small,
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  _showBottom = false;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_showRight)
                        ResizablePane(
                          minSize: 100,
                          initialSize: 200,
                          child: Card(
                            padding: EdgeInsets.all(4),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text('右侧面板'),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton.ghost(
                                        size: ButtonSize.small,
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          setState(() {
                                            _showRight = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _divider(context, direction) {
    return direction == Axis.horizontal
        ? const SizedBox(height: 2)
        : const SizedBox(width: 2);
  }

  Widget _windowBar() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onTap: () async {
        var now = DateTime.now();
        // 计时器判断双击，解决单击响应慢的问题
        if (now.difference(_lastTapTime).inMilliseconds < 300) {
          // TODO 鸿蒙不支持窗口管理
          try {
            bool isMaximized = await windowManager.isMaximized();
            if (!isMaximized) {
              windowManager.maximize();
            } else {
              windowManager.unmaximize();
            }
          } catch (e) {
            print(e);
          }
        } else {
          _lastTapTime = now;
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Row(
          children: [
            SizedBox(width: 80),
            Text('Studio'),
            Spacer(),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                _showLeft ? LucideIcons.panelLeftClose : LucideIcons.panelLeft,
              ),
              onPressed: () {
                setState(() {
                  _showLeft = !_showLeft;
                });
              },
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                _showBottom
                    ? LucideIcons.panelBottomClose
                    : LucideIcons.panelBottom,
              ),
              onPressed: () {
                setState(() {
                  _showBottom = !_showBottom;
                });
              },
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                _showRight
                    ? LucideIcons.panelRightClose
                    : LucideIcons.panelRight,
              ),
              onPressed: () {
                setState(() {
                  _showRight = !_showRight;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  NavigationItem _buildButton(_NavItem nav) {
    return NavigationItem(
      label: Text(nav.title),
      alignment: Alignment.center,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: nav.icon,
    );
  }
}

enum _NavItem {
  contents('目录', Icon(Icons.file_copy_outlined)),
  search('搜索', Icon(Icons.search_outlined)),
  code('代码管理', Icon(LucideIcons.gitFork)),
  debug('运行调试', Icon(LucideIcons.bugPlay)),
  remote('远程资源', Icon(RadixIcons.cardStackMinus)),
  plugin('插件', Icon(RadixIcons.dashboard)),
  test('测试', Icon(LucideIcons.testTubeDiagonal)),
  ;

  final String title;
  final Widget icon;
  const _NavItem(this.title, this.icon);
}
