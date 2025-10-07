import HiLog from '@ohos.hilog';
import { MethodCall, MethodChannel, MethodResult, MethodCallHandler } from '@ohos/flutter_ohos';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { window } from '@kit.ArkUI';

export default class WindowManagerPlugin implements FlutterPlugin, MethodCallHandler {
  static window: window.Window | null = null
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return "WindowManagerPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "windowManagerChannel");
    this.channel.setMethodCallHandler(this)
  }


  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    let succeed: boolean | undefined = false;
    switch (call.method) {
      case "startDragging":
        this.startDragging()
        result.success(true);
      case "maximize":
        await WindowManagerPlugin.window?.setLayoutFullScreen(true)
        let maximizeProperties = WindowManagerPlugin.window?.getWindowProperties()
        succeed = maximizeProperties?.isFullScreen
        HiLog.info(0x0001, 'WindowManagerTag', '最大化结果' + succeed)
        result.success(true);
        break;
      case "unmaximize":
        await WindowManagerPlugin.window?.setLayoutFullScreen(false)
        let unmaximizeProperties = WindowManagerPlugin.window?.getWindowProperties()
        succeed = !unmaximizeProperties?.isFullScreen
        HiLog.info(0x0001, 'WindowManagerTag', '取消最大化结果' + succeed)
        result.success(true);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  startDragging() {
    WindowManagerPlugin.window?.startMoving()
    // TODO 完成移动
    HiLog.info(0x0001, 'WindowManagerTag', 'TODO 完成移动')
    // 禁止聚焦窗口（禁止选中）
    // w.setWindowFocusable(false)
    // 设置窗口标题栏高度，范围[37,112]
    // w.setWindowDecorHeight(100)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }
}