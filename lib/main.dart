import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'view/window_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio',
      home: WindowView(),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightBlue().copyWith(
          background: Colors.gray[200],
        ),
        radius: 0.5,
      ),
    );
  }
}
