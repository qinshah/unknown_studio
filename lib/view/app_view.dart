import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../state/panel_state.dart';
import 'tabs/tabs_view.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  DateTime _lastBarTapTime = DateTime(0);

  /// 是否全屏
  bool _isFullScreen = false;
  bool _showToggleExpand = true;
  // final _platform = '';
  final _platform = Platform.operatingSystem;
  // int? _leftHoverPanleIndex;
  // PointerHoverEven

  @override
  void initState() {
    windowManager.isMaximized().then((value) {
      setState(() {
        _isFullScreen = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        if (details.kind != PointerDeviceKind.mouse && !_showToggleExpand) {
          setState(() => _showToggleExpand = true);
        }
      },
      child: SafeArea(
        top: !_isFullScreen,
        left: false,
        child: Scaffold(
          child: Column(
            children: [
              _appBar(),
              Expanded(
                child: Row(
                  children: [
                    _leftBar(),
                    Expanded(
                      child: ResizablePanel.horizontal(
                        draggerBuilder: (context) =>
                            const HorizontalResizableDragger(),
                        dividerBuilder: (context) => _divider(Axis.vertical),
                        children: [
                          if (PanelState.showLeft)
                            ResizablePane(
                              minSize: 150,
                              initialSize: 200,
                              child: Card(
                                padding: EdgeInsets.zero,
                                child: PanelState.leftPanel.view,
                              ),
                            ),
                          ResizablePane.flex(
                            minSize: 100,
                            key: Key('MainPane'), // 不加key会导致关闭左侧面板后右侧面板占主要尺寸
                            child: ResizablePanel.vertical(
                              draggerBuilder: (context) {
                                return const HorizontalResizableDragger();
                              },
                              dividerBuilder: (context) =>
                                  _divider(Axis.horizontal),
                              children: [
                                ResizablePane.flex(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: TabsView(),
                                  ),
                                ),
                                if (PanelState.showBottom)
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
                                                      PanelState.showBottom =
                                                          false;
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
                          if (PanelState.showRight)
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton.ghost(
                                            size: ButtonSize.small,
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              setState(() {
                                                PanelState.showRight = false;
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
        ),
      ),
    );
  }

  final _windowManagerChannel = MethodChannel('windowManagerChannel');

  Widget _appBar() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) {
        // windowManager.startDragging();
        // TODO 用插件实现
        _windowManagerChannel.invokeMethod('startDragging');
      },
      onPanEnd: (_) {
        windowManager.isMaximized().then((value) {
          setState(() {
            _isFullScreen = value;
          });
        });
      },
      onTap: () async {
        var now = DateTime.now();
        // 计时器判断双击，解决单击响应慢的问题
        if (now.difference(_lastBarTapTime).inMilliseconds < 300) {
          _toggleWindowFull();
        } else {
          _lastBarTapTime = now;
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            if (_platform == "macos") SizedBox(width: 60), // 留出Mac红绿灯🚥
            if (_showToggleExpand)
              IconButton.ghost(
                size: ButtonSize.small,
                icon: Icon(LucideIcons.menu),
                onPressed: () {
                  setState(() {
                    PanelState.expandLeftBar = !PanelState.expandLeftBar;
                  });
                },
              ),
            Text('Studio'),
            Spacer(),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                PanelState.showLeft
                    ? LucideIcons.panelLeftClose
                    : LucideIcons.panelLeft,
              ),
              onPressed: () {
                setState(() {
                  PanelState.showLeft = !PanelState.showLeft;
                });
              },
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                PanelState.showBottom
                    ? LucideIcons.panelBottomClose
                    : LucideIcons.panelBottom,
              ),
              onPressed: () {
                setState(() {
                  PanelState.showBottom = !PanelState.showBottom;
                });
              },
            ),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: Icon(
                PanelState.showRight
                    ? LucideIcons.panelRightClose
                    : LucideIcons.panelRight,
              ),
              onPressed: () {
                setState(() {
                  PanelState.showRight = !PanelState.showRight;
                });
              },
            ),
            if (_platform != "macos") ...[
              SizedBox(width: 6),
              // 全屏切换
              _tabBarButton(
                color: Colors.green,
                onPressed: _toggleWindowFull,
                iconData: Icons.crop_square,
              ),
              SizedBox(width: 2),
              // 最小化
              _tabBarButton(
                color: Colors.yellow,
                onPressed: windowManager.minimize,
                iconData: Icons.minimize,
              ),
              SizedBox(width: 2),
              // 关闭窗口
              _tabBarButton(
                color: Colors.red,
                onPressed: () => exit(0),
                iconData: Icons.close,
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _toggleWindowFull() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    SystemChrome.setEnabledSystemUIMode(
      _isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // try {
    //   _isFullScreen ? windowManager.maximize() : windowManager.unmaximize();
    // } catch (e) {
    //   print(e);
    // }
    //
    //  鸿蒙不支持窗口管理
    _windowManagerChannel
        .invokeMethod(_isFullScreen ? 'maximize' : 'unmaximize');
  }

  Widget _tabBarButton({
    required Color color,
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return Button(
      style: const ButtonStyle.destructiveIcon(size: ButtonSize.small)
          .withBackgroundColor(color: Colors.transparent, hoverColor: color)
          .withForegroundColor(color: color, hoverColor: Colors.white),
      onPressed: onPressed,
      child: Icon(iconData),
    );
  }

  Widget _leftBar() {
    return MouseRegion(
      onEnter: (_) => setState(() => PanelState.expandLeftBar = true),
      onExit: (_) => setState(() => PanelState.expandLeftBar = false),
      onHover: (_) {
        if (_showToggleExpand) setState(() => _showToggleExpand = false);
      },
      child: NavigationRail(
        padding: EdgeInsets.all(2),
        labelType: NavigationLabelType.expanded,
        labelPosition: NavigationLabelPosition.end,
        alignment: NavigationRailAlignment.start,
        expanded: PanelState.expandLeftBar,
        index: PanelState.showLeft
            ? PanelState.leftPanels.indexOf(PanelState.leftPanel)
            : null,
        onSelected: (index) {
          setState(() {
            PanelState.setLeftPanel(index);
          });
        },
        children: List.generate(
          PanelState.leftPanels.length,
          (index) => _panelButton(index),
        ),
      ),
    );
  }

  Widget? _divider(direction) {
    return direction == Axis.horizontal
        ? const SizedBox(height: 2)
        : const SizedBox(width: 2);
  }

  // double _calculateIconSize(int index) {
  //   if (_leftHoverPanleIndex == null || _leftHoverEvent == null) {
  //     return 24.0; // 默认图标大小
  //   }

  //   // 计算当前图标的垂直位置（假设每个图标间距为 56 像素）
  //   double iconCenterY = (index + 0.5) * 56.0;

  //   // 获取鼠标的垂直位置（相对于NavigationRail的局部坐标）
  //   double mouseY = _leftHoverEvent!.localPosition.dy;

  //   // 计算距离
  //   double distance = (iconCenterY - mouseY).abs();

  //   // Mac程序坞效果：距离越近放大越多
  //   double maxSize = 48.0; // 最大放大尺寸
  //   double minSize = 24.0; // 最小（默认）尺寸
  //   double maxDistance = 84.0; // 影响范围（约1.5个图标的距离）

  //   if (distance <= maxDistance) {
  //     // 使用平滑的缩放曲线
  //     double scale = 1.0 - (distance / maxDistance);
  //     scale = scale * scale; // 平方函数使效果更自然
  //     print('图标$index');
  //     print(minSize + (maxSize - minSize) * scale);
  //     return minSize + (maxSize - minSize) * scale;
  //   }

  //   return minSize;
  // }

  NavigationItem _panelButton(int index) {
    var panel = PanelState.leftPanels[index];
    return NavigationItem(
      label: Text(panel.title),
      alignment: Alignment.centerLeft,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: MouseRegion(
        // onEnter: (event) {
        //   setState(() {
        //     _leftHoverPanleIndex = index;
        //   });
        // },
        // onHover: (event) {
        //   setState(() {
        //     _leftHoverPanleIndex = index;
        //     _leftHoverEvent = event;
        //   });
        // },
        // onExit: (event) => setState(() {
        //   _leftHoverPanleIndex = null;
        // }),
        child: Icon(panel.iconData),
      ),
    );
  }
}
