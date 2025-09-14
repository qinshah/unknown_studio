import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as m;
import 'package:webview_flutter/webview_flutter.dart';

import '../view/content_panel/content_panel.dart';

enum Panel {
  content(
    '目录',
    Icons.file_copy_outlined,
    ContentPanel(),
  ),
  search(
    '搜索',
    Icons.search_outlined,
    Center(child: Text('搜索')),
  ),
  code(
    '代码管理',
    LucideIcons.gitFork,
    Center(child: Text('代码管理')),
  ),
  debug(
    '运行调试',
    LucideIcons.bugPlay,
    Center(child: Text('运行调试')),
  ),
  webview(
    '网页(测试)',
    BootstrapIcons.browserChrome,
    _WebviewTest(),
  ),
  plugin(
    '插件',
    RadixIcons.dashboard,
    Center(child: Text('插件')),
  ),
  test(
    '测试',
    LucideIcons.testTubeDiagonal,
    Center(child: Text('测试')),
  ),
  ;

  final String title;
  final IconData iconData;
  final Widget view;
  const Panel(this.title, this.iconData, this.view);
}

class _WebviewTest extends StatefulWidget {
  const _WebviewTest();

  @override
  State<_WebviewTest> createState() => __WebviewTestState();
}

class __WebviewTestState extends State<_WebviewTest> {
  late WebViewController _controller;
  final _urlController = TextEditingController(text: 'https://www.bing.com/');
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) => setState(() => _progress = value / 100),
          onPageStarted: (String url) => _urlController.text = url,
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {
            // TODO: Handle this case.
          },
          onWebResourceError: (WebResourceError error) {
            // TODO: Handle this case.
          },
        ),
      );
    _loadUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadUrl() {
    String url = _urlController.text.trim();
    if (url.isNotEmpty) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 地址栏和刷新按钮
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [ 
              // 地址栏
              Expanded(
                child: TextField(
                  controller: _urlController,
                  placeholder: const Text('输入网址...'),
                  onSubmitted: (_) => _loadUrl(),
                ),
              ),
              const SizedBox(width: 8),
              // 前往按钮
              Button(
                style: ButtonStyle.primary(),
                onPressed: _loadUrl,
                child: const Text('前往'),
              ),
            ],
          ),
        ),
        if (_progress < 1) m.LinearProgressIndicator(value: _progress),
        // WebView
        Expanded(
          child: WebViewWidget(controller: _controller),
        ),
      ],
    );
  }
}
