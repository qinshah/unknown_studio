import 'dart:io';

import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FileView extends StatefulWidget {
  const FileView(this.file, {required super.key});

  final File file;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  final _controller = CodeLineEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final content = await widget.file.readAsString();
      setState(() => _controller.text = content);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          Text('读取文本失败', style: TextStyle(color: Colors.red)),
          Text(_errorMessage!),
        ],
      );
    }
    return CodeEditor(
      controller: _controller,
      readOnly: true,
      wordWrap: false,
      chunkAnalyzer: const DefaultCodeChunkAnalyzer(),
      style: CodeEditorStyle(
        // TODO 添加更多语言
        codeTheme: CodeHighlightTheme(languages: {
          'dart': CodeHighlightThemeMode(mode: langDart),
          'json': CodeHighlightThemeMode(mode: langJson),
          'java': CodeHighlightThemeMode(mode: langJava),
          'cpp': CodeHighlightThemeMode(mode: langCpp),
          'js': CodeHighlightThemeMode(mode: langJavascript),
          'kts': CodeHighlightThemeMode(mode: langKotlin),
          'kt': CodeHighlightThemeMode(mode: langKotlin),
          'xml': CodeHighlightThemeMode(mode: langXml),
          'yaml': CodeHighlightThemeMode(mode: langYaml),
        }, theme: atomOneLightTheme),
      ),
      indicatorBuilder:
          (context, editingController, chunkController, notifier) {
        return Row(
          children: [
            DefaultCodeLineNumber(
              controller: editingController,
              notifier: notifier,
            ),
            DefaultCodeChunkIndicator(
                width: 20, controller: chunkController, notifier: notifier)
          ],
        );
      },
    );
  }
}