import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'tabs/tabs_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _expanded = false;
  int _selected = 0;
  bool _showLeft = true;
  bool _showRight = true;
  bool _showBottom = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Column(
        children: [
          _appBar(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  labelType: NavigationLabelType.expanded,
                  labelPosition: NavigationLabelPosition.bottom,
                  alignment: NavigationRailAlignment.start,
                  expanded: _expanded,
                  index: _selected,
                  onSelected: (value) {
                    setState(() {
                      _selected = value;
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
                    NavigationDivider(color: Colors.slate[200]),
                    _buildButton('目录', Icons.file_copy_outlined),
                    _buildButton('搜索', Icons.search_outlined),
                    _buildButton('代码管理', LucideIcons.gitFork),
                    _buildButton('运行调试', LucideIcons.bugPlay),
                    _buildButton('远程资源', RadixIcons.cardStackMinus),
                    NavigationDivider(color: Colors.slate[200]),
                    _buildButton('插件', RadixIcons.dashboard),
                    _buildButton('测试', LucideIcons.testTubeDiagonal),
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
                            child: Center(child: Text('左侧面板')),
                          ),
                        ),
                      ResizablePane.flex(
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
                                initialSize: 200,
                                child: Card(
                                  padding: EdgeInsets.zero,
                                  child: Center(child: Text('底部面板')),
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
                            padding: EdgeInsets.zero,
                            child: Center(child: Text('右侧面板')),
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

  Widget _appBar() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
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
              _showRight ? LucideIcons.panelRightClose : LucideIcons.panelRight,
            ),
            onPressed: () {
              setState(() {
                _showRight = !_showRight;
              });
            },
          ),
        ],
      ),
    );
  }

  NavigationItem _buildButton(String text, IconData icon) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.center,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: Icon(icon),
    );
  }
}
