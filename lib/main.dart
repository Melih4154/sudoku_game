import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sudoku_game/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter('sudoku');
  await Hive.openBox('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('settings').listenable(keys: ['darkTheme']),
        builder: (context, box, widget) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: box.get('darkTheme', defaultValue: false)
                ? //ThemeData.dark()
                ThemeData.light()
                : //ThemeData.light(),
                ThemeData.dark(),
            home: HomePage(),
          );
        });
  }
}
