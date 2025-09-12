import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'view/app_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置状态栏全屏显示模式
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // TODO 鸿蒙不支持窗口管理
  try {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    windowManager.setMovable(false);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (e) {
    print(e);
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  /// 是否启用耗时模拟
  static bool enableSlowSimulation = true;

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio',
      home: AppView(),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightBlue.copyWith(
          background: () => Colors.gray.shade300,
        ),
        radius: 0.5,
      ),
    );
  }
}
