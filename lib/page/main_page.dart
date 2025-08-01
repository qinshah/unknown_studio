import 'package:shadcn_flutter/shadcn_flutter.dart';

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

  NavigationItem buildButton(String text, IconData icon) {
    return NavigationItem(
      label: Text(text),
      alignment: Alignment.center,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavigationRail(
            backgroundColor: Colors.slate[100],
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
              buildButton('目录', Icons.file_copy_outlined),
              buildButton('搜索', Icons.search_outlined),
              buildButton('代码管理', LucideIcons.gitFork),
              buildButton('运行调试', LucideIcons.bugPlay),
              buildButton('远程资源', RadixIcons.cardStackMinus),
              NavigationDivider(color: Colors.slate[200]),
              buildButton('插件', RadixIcons.dashboard),
              buildButton('测试', LucideIcons.testTubeDiagonal),
            ],
          ),
          Expanded(
            child: ResizablePanel.horizontal(
              draggerBuilder: (context) {
                return const HorizontalResizableDragger();
              },
              children: [
                if (_showLeft)
                  ResizablePane(
                    initialSize: 200,
                    child: Center(child: Text('左侧面板')),
                  ),
                ResizablePane.flex(
                  child: ResizablePanel.vertical(
                    draggerBuilder: (context) {
                      return const HorizontalResizableDragger();
                    },
                    children: [
                      ResizablePane.flex(
                        child: ColoredBox(
                          color: Colors.slate[100],
                          child: TabPaneExample1(),
                        ),
                      ),
                      if (_showBottom)
                        ResizablePane(
                          initialSize: 200,
                          child: Center(child: Text('底部面板')),
                        ),
                    ],
                  ),
                ),
                if (_showRight)
                  ResizablePane(
                    initialSize: 200,
                    child: Center(child: Text('右侧面板')),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabPaneExample1 extends StatefulWidget {
  const TabPaneExample1({super.key});

  @override
  State<TabPaneExample1> createState() => _TabPaneExample1State();
}

class MyTab {
  final String title;
  final int count;
  final String content;
  MyTab(this.title, this.count, this.content);

  @override
  String toString() {
    return 'TabData{title: $title, count: $count, content: $content}';
  }
}

class _TabPaneExample1State extends State<TabPaneExample1> {
  late List<TabPaneData<MyTab>> tabs;
  int focused = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabs = [
      for (int i = 0; i < 3; i++)
        TabPaneData(MyTab('Tab ${i + 1}', i + 1, 'Content ${i + 1}')),
    ];
  }

  TabItem _buildTabItem(MyTab data) {
    return TabItem(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: Label(
          trailing: IconButton.ghost(
            shape: ButtonShape.circle,
            size: ButtonSize.xSmall,
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                tabs.remove(tabs.firstWhere((element) => element.data == data));
              });
            },
          ),
          child: Text(data.title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabPane<MyTab>(
      items: tabs,
      itemBuilder: (context, item, index) {
        return _buildTabItem(item.data);
      },
      focused: focused,
      onFocused: (value) {
        setState(() {
          focused = value;
        });
      },
      onSort: (value) {
        setState(() {
          tabs = value;
        });
      },
      trailing: [
        IconButton.ghost(
          icon: const Icon(Icons.add),
          size: ButtonSize.small,
          density: ButtonDensity.iconDense,
          onPressed: () {
            setState(() {
              int max = tabs.fold<int>(0, (previousValue, element) {
                return element.data.count > previousValue
                    ? element.data.count
                    : previousValue;
              });
              tabs.add(TabPaneData(
                  MyTab('Tab ${max + 1}', max + 1, 'Content ${max + 1}')));
            });
          },
        )
      ],
      child: Center(
        child: Text('Tab ${focused + 1}').xLarge().bold(),
      ),
    );
  }
}
