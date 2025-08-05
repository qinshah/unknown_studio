import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../state/panel_state.dart';
import 'tabs/tabs_view.dart';

class WindowView extends StatefulWidget {
  const WindowView({super.key});

  @override
  State<WindowView> createState() => _WindowViewState();
}

class _WindowViewState extends State<WindowView> {
  DateTime _lastBarTapTime = DateTime(0);
  bool _isImmersiveSticky = true;
  int? _leftHoverPanleIndex;
  PointerHoverEvent? _leftHoverEvent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: !_isImmersiveSticky,
      child: Scaffold(
        child: Column(
          children: [
            _windowBar(),
            Expanded(
              child: Row(
                children: [
                  MouseRegion(
                    onEnter: (_) =>
                        setState(() => PanelState.expandLeftBar = true),
                    onExit: (_) =>
                        setState(() => PanelState.expandLeftBar = false),
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
                                      mainAxisAlignment: MainAxisAlignment.end,
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
        if (now.difference(_lastBarTapTime).inMilliseconds < 300) {
          setState(() {
            _isImmersiveSticky = !_isImmersiveSticky;
          });
          SystemChrome.setEnabledSystemUIMode(
            _isImmersiveSticky
                ? SystemUiMode.immersiveSticky
                : SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          print('object');
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
          _lastBarTapTime = now;
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
          ],
        ),
      ),
    );
  }

  double _calculateIconSize(int index) {
    if (_leftHoverPanleIndex == null || _leftHoverEvent == null) {
      return 24.0; // 默认图标大小
    }

    // 计算当前图标的垂直位置（假设每个图标间距为 56 像素）
    double iconCenterY = (index + 0.5) * 56.0;

    // 获取鼠标的垂直位置（相对于NavigationRail的局部坐标）
    double mouseY = _leftHoverEvent!.localPosition.dy;

    // 计算距离
    double distance = (iconCenterY - mouseY).abs();

    // Mac程序坞效果：距离越近放大越多
    double maxSize = 48.0; // 最大放大尺寸
    double minSize = 24.0; // 最小（默认）尺寸
    double maxDistance = 84.0; // 影响范围（约1.5个图标的距离）

    if (distance <= maxDistance) {
      // 使用平滑的缩放曲线
      double scale = 1.0 - (distance / maxDistance);
      scale = scale * scale; // 平方函数使效果更自然
      print('图标$index');
      print(minSize + (maxSize - minSize) * scale);
      return minSize + (maxSize - minSize) * scale;
    }

    return minSize;
  }

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
