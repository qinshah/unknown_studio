import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class FileView extends StatefulWidget {
  const FileView(this.file, {super.key});

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
          Icon(Icons.error, size: 50, color: Colors.red),
          Text('读取文本失败', style: TextStyle(color: Colors.red)),
          Text(_errorMessage!),
        ],
      );
    }
    return CodeEditor(
      controller: _controller,
      readOnly: true,
      wordWrap: false,
      toolbarController: _ToolbarController(),
      chunkAnalyzer: const DefaultCodeChunkAnalyzer(),
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
    );
  }
}

class _ToolbarController implements SelectionToolbarController {
  @override
  void show(
      {required BuildContext context,
      required CodeLineEditingController controller,
      required TextSelectionToolbarAnchors anchors,
      Rect? renderRect,
      required LayerLink layerLink,
      required ValueNotifier<bool> visibility}) {
    final selectedText = controller.selectedText;
    showMenu(
      context: context,
      // TODO 搞懂RelativeRect
      position: RelativeRect.fromSize(
        anchors.primaryAnchor & Size.zero,
        MediaQuery.of(context).size,
      ),
      items: [
        PopupMenuItem(
          enabled: selectedText.isNotEmpty,
          onTap: () => Clipboard.setData(ClipboardData(text: selectedText)),
          child: Text('复制'),
        )
      ],
    );
  }

  @override
  void hide(BuildContext context) {}
}
