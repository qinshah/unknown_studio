import 'package:mc_launch/mc_launch.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../state/content_state.dart';

class McLaunchPanel extends StatefulWidget {
  const McLaunchPanel({super.key});

  @override
  State<McLaunchPanel> createState() => _McLaunchPanelState();
}

class _McLaunchPanelState extends State<McLaunchPanel> {
  late List<String> _gamePaths = _getGamePaths();
  String? _selectedPath;
  final _memoryCntlr = TextEditingController(text: '2048');
  final _versionKey = const TextFieldKey('version');
  final _usernameKey = const TextFieldKey('username');
  final _memoryKey = const FormKey<int>('memory');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      headers: [Text('启动我的世界', textAlign: TextAlign.center)],
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _gamePaths.isEmpty
              ? [
                  Text('未检测到我的世界路径'),
                  Text('请打开.minecraft文件夹'),
                  SizedBox(height: 16),
                  PrimaryButton(
                    child: Text('刷新'),
                    onPressed: () => setState(() {
                      _gamePaths = _getGamePaths();
                    }),
                  ),
                ]
              : [
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
                ],
        ),
        onSubmit: (context, values) async {
          int memory;
          try {
            memory = int.parse(_memoryCntlr.text);
            if (memory < 1024) {
              throw FormatException('内存不能小于1024MB');
            }
            MinecraftLauncher.launch(
              versionPath: values[_versionKey]!,
              username: values[_usernameKey]!,
              memory: memory,
            );
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(title: const Text('已尝试启动'));
              },
            );
          } catch (e) {
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
