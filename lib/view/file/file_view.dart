import 'dart:io';

import 'package:open_file/open_file.dart'
  if (Platform.isOhos) 'package:open_file_ohos/open_file_ohos.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FileView extends StatefulWidget {
  const FileView(this.file, {super.key});

  final File file;

  @override
  State<FileView> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Button.primary(
      child: Text('用系统打开${widget.file.path.split('/').last}'),
      onPressed: () => OpenFile.open(widget.file.path),
    ));
  }
}
