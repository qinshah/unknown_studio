import 'package:shadcn_flutter/shadcn_flutter.dart';

class TabsView extends StatefulWidget {
  const TabsView({super.key});

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView> {
  List<TabPaneData<MyTab>> _tabs = [
    TabPaneData(MyTab('页面1', '页面1内容')),
    TabPaneData(MyTab('页面2', '页面2内容')),
    TabPaneData(MyTab('页面3', '页面3内容')),
  ];
  late int _maxIndex = _tabs.length;

  void _add() {
    _maxIndex++;
    setState(() {
      if (_tabs.isNotEmpty) {
        _index++;
      }
      _tabs.insert(
        _index,
        TabPaneData(MyTab('页面$_maxIndex', '页面$_maxIndex内容')),
      );
    });
  }

  int _index = 0;
  double _logoSize = 100;

  TabItem _buildTabItem(int index) {
    final data = _tabs[index].data;
    return TabItem(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120),
        child: GestureDetector(
          onTertiaryTapDown: (_) {
            setState(() {
              _tabs.removeAt(index);
            });
          },
          child: Label(
            trailing: IconButton.ghost(
              shape: ButtonShape.circle,
              size: ButtonSize.xSmall,
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _tabs.removeAt(index);
                });
              },
            ),
            child: Text(data.title),
          ),
        ),
      ),
    );
  }

  int get _focused {
    if (_tabs.isEmpty) return 0;
    _index = _index.clamp(0, _tabs.length - 1);
    return _index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.accent,
      child: TabPane<MyTab>(
        items: _tabs,
        itemBuilder: (context, item, index) {
          return _buildTabItem(index);
        },
        focused: _focused,
        onFocused: (value) {
          setState(() {
            _index = value;
          });
        },
        onSort: (value) {
          setState(() {
            _tabs = value;
          });
        },
        trailing: [
          IconButton.ghost(
            icon: const Icon(Icons.add),
            size: ButtonSize.small,
            density: ButtonDensity.iconDense,
            onPressed: _add,
          )
        ],
        child: _tabs.isEmpty
            ? Center(
                child: GestureDetector(
                onTap: () {
                  setState(() {
                    _logoSize = _logoSize == 100 ? 666 : 100;
                  });
                },
                child: FlutterLogo(size: _logoSize),
              ))
            : Center(child: Text(_tabs[_index].data.content)),
      ),
    );
  }
}

class MyTab {
  final String title;
  final String content;
  MyTab(this.title, this.content);
}
