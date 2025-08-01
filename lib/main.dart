import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'page/main_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Studio',
      home: MainPage(),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightBlue(),
        radius: 0.5,
      ),
    );
  }
}
