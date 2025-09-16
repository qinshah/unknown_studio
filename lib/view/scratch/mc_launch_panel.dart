import 'dart:async';
import 'dart:io';
import 'package:mc_launch/mc_launch.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../state/content_state.dart';

class McLaunchPanel extends StatefulWidget {
  const McLaunchPanel({super.key});

  @override
  State<McLaunchPanel> createState() => _McLaunchPanelState();
}

class _McLaunchPanelState extends State<McLaunchPanel> {
  late final List<String> _gamePaths = _getGamePaths();
  String? _selectedPath;
  final _memoryCntlr = TextEditingController(text: '2048');
  final _versionKey = const TextFieldKey('version');
  final _usernameKey = const TextFieldKey('username');
  final _memoryKey = const FormKey<int>('memory');
  late Process process;
  final List<String> _logs = [];
  final _logsCntlr = ScrollController();

  @override
  void dispose() {
    _logsCntlr.dispose();
    super.dispose();
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
                  Text('日志'),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.gray),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      controller: _logsCntlr,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Text(_logs[index]);
                      },
                    ),
                  ),
                ],
              ),
              onSubmit: (context, values) async {
                try {
                  int memory = int.parse(_memoryCntlr.text);
                  if (memory < 1024) throw Exception();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Column(children: [
                          const Text('已尝试启动，请勿重复启动'),
                        ]),
                      );
                    },
                  );
                  process = await MinecraftLauncher.launch(
                    versionPath: values[_versionKey]!,
                    username: values[_usernameKey]!,
                    memory: memory,
                  );
                  // 监听输出
                  _logs.clear();
                  process.stdout.listen((data) {
                    final output = String.fromCharCodes(data).trim();
                    setState(() {
                      _logs.add(output);
                    });
                    _logsCntlr.jumpTo(_logsCntlr.position.maxScrollExtent);
                  });
                  process.stderr.listen((data) {
                    final output = String.fromCharCodes(data).trim();
                    setState(() {
                      _logs.add(output);
                    });
                    _logsCntlr.jumpTo(_logsCntlr.position.maxScrollExtent);
                  });
                } catch (e) {
                  if (!context.mounted) return;
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

  List<String> _getGamePaths() {
    final dirPath = ContentState.i.root?.entity.path;
    if (dirPath == null) return [];
    return MinecraftLauncher.detectVersions(dirPath, includeModded: true);
  }
}
