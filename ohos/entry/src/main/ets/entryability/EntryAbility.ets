import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { window } from '@kit.ArkUI';
import WindowManagerPlugin from '../plugins/WindowManagerPlugin';

export default class EntryAbility extends FlutterAbility {
  private window: window.Window | null = null

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // 添加WindowManagerPlugin
    flutterEngine.getPlugins()?.add(new WindowManagerPlugin());
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    super.onWindowStageCreate(windowStage)
    this.window = await windowStage.getMainWindow();
    WindowManagerPlugin.window = this.window;
    // 隐藏最大化、最小化和关闭按钮
    this.window.setWindowTitleButtonVisible(false, false, false)
    // 全屏
    this.window.setLayoutFullScreen(true)
    // 禁止拖动标题移动窗口
    // EntryAbility.window.setWindowTitleMoveEnabled(false);
    // 设置窗口标题栏是否可见
    this.window.setWindowDecorVisible(false)
  }
}
