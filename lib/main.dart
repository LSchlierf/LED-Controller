import 'package:flutter/material.dart';

import 'main_page.dart';

void main() {
  runApp(const LEDControlApp());
}

enum deviceType { longboard, ledController }

class LEDControlApp extends StatelessWidget {
  const LEDControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LED Controller",
      theme: ThemeData.dark(),
      home: MainPage(
        key: key,
        title: "LED Control",
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
