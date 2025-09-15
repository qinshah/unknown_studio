import 'dart:async';
import 'package:mc_launch/mc_launch.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../state/content_state.dart';

class McLaunchPanel extends StatefulWidget {
  const McLaunchPanel({super.key});

  @override
  State<McLaunchPanel> createState() => _McLaunchPanelState();
}

// 日志管理器
class LogManager {
  static final LogManager _instance = LogManager._internal();
  factory LogManager() => _instance;
  LogManager._internal();

  static final List<String> _logs = [];
  static final StreamController<List<String>> _logController =
      StreamController<List<String>>.broadcast();

  static void init() {
    // 重定向print输出
    runZonedGuarded(
      () {
        // 保存原始的print函数
        final originalPrint = debugPrint;

        // 重写debugPrint
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) {
            // 添加时间戳
            final timestamp = DateTime.now().toString();
            final logMessage = '[$timestamp] $message';

            // 添加到日志列表
            _logs.add(logMessage);

            // 通知监听器
            _logController.add(List.from(_logs));

            // 调用原始print函数，保持控制台输出
            originalPrint(message, wrapWidth: wrapWidth);
          }
        };
      },
      (error, stack) {
        // 捕获未处理的错误
        final timestamp = DateTime.now().toString();
        final errorMessage = '[$timestamp] ERROR: $error\nSTACK: $stack';
        _logs.add(errorMessage);
        _logController.add(List.from(_logs));
      },
    );
  }

  // 获取日志流
  static Stream<List<String>> get logStream => _logController.stream;

  // 清除日志
  static void clearLogs() {
    _logs.clear();
    _logController.add(List.from(_logs));
  }

  // 获取当前所有日志
  static List<String> get currentLogs => List.from(_logs);
}

class _McLaunchPanelState extends State<McLaunchPanel> {
  late final List<String> _gamePaths = _getGamePaths();
  String? _selectedPath;
  final _memoryCntlr = TextEditingController(text: '2048');
  final _versionKey = const TextFieldKey('version');
  final _usernameKey = const TextFieldKey('username');
  final _memoryKey = const FormKey<int>('memory');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化日志管理器
    LogManager.init();

    // 监听日志流
    LogManager.logStream.listen((logs) {
      print(logs);
      // 自动滚动到底部
      if (_scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      headers: [AppBar(title: Text('我的世界启动', textAlign: TextAlign.center))],
      child: _gamePaths.isEmpty
          ? Center(child: Text('请打开含versions的目录'))
          : Form(
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  FormField(
                    key: _versionKey,
                    label: const Text('游戏版本'),
                    validator: const NotEmptyValidator(message: '请选择'),
                    child: Select<String>(
                      itemBuilder: (_, path) => Text(path.split('/').last),
                      onChanged: (value) {
                        setState(() {
                          _selectedPath = value;
                        });
                      },
                      value: _selectedPath,
                      placeholder: const Text('选择版本'),
                      popup: SelectPopup(
                        items: SelectItemList(
                          children: _gamePaths.map<SelectItemButton<String>>(
                            (String value) {
                              return SelectItemButton<String>(
                                value: value,
                                child: Text(value.split('/').last),
                              );
                            },
                          ).toList(),
                        ),
                      ).call,
                    ),
                  ),
                  SizedBox(height: 16),
                  FormField(
                    key: _usernameKey,
                    label: const Text('游戏昵称'),
                    validator: const NotEmptyValidator(message: '不能为空'),
                    child: TextField(initialValue: 'Steve'),
                  ),
                  SizedBox(height: 16),
                  FormField<int>(
                    key: _memoryKey,
                    label: const Text('内存(MB)'),
                    validator: const MinValidator(1024, message: '至少1G'),
                    child: TextField(
                      controller: _memoryCntlr,
                      features: const [InputFeature.spinner()],
                      submitFormatters: [TextInputFormatters.mathExpression()],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 24),
                  FormErrorBuilder(
                    builder: (context, errors, child) {
                      return PrimaryButton(
                        onPressed:
                            errors.isEmpty ? () => context.submitForm() : null,
                        child: const Text('启动'),
                      );
                    },
                  ),
                  SizedBox(height: 24),
                  // 日志显示区域
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.gray),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: StreamBuilder<List<String>>(
                      stream: LogManager.logStream,
                      initialData: LogManager.currentLogs,
                      builder: (context, snapshot) {
                        final logs = snapshot.data ?? [];
                        if (logs.isEmpty) {
                          return const Center(
                            child: Text('暂无日志'),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            // 根据日志内容判断是否为错误日志
                            final isError = log.contains('ERROR:') ||
                                log.contains('STACK:');

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: isError ? Colors.red.shade50 : null,
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: isError
                                      ? Colors.red.shade800
                                      : Colors.black,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              onSubmit: (context, values) async {
                int memory;
                try {
                  memory = int.parse(_memoryCntlr.text);
                  if (memory < 1024) {
                    throw FormatException('内存不能小于1024MB');
                  }
                  print('正在启动Minecraft...');
                  print('版本路径: ${values[_versionKey]}');
                  print('用户名: ${values[_usernameKey]}');
                  print('内存: $memory MB');

                  MinecraftLauncher.launch(
                    versionPath: values[_versionKey]!,
                    username: values[_usernameKey]!,
                    memory: memory,
                  );
                  print('Minecraft启动命令已发送');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(title: const Text('已尝试启动'));
                    },
                  );
                } catch (e) {
                  print('启动错误: $e');
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(title: const Text('内存请输入1024以上的整数'));
                    },
                  );
                }
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getGamePaths() {
    final dirPath = ContentState.i.root?.entity.path;
    if (dirPath == null) return [];
    return MinecraftLauncher.detectVersions(dirPath, includeModded: true);
  }
}
