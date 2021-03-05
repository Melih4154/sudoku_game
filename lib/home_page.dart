import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sudoku_game/language.dart';
import 'package:sudoku_game/sudoku_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box _sudokuBox;

  Future<Box> _boxOpen() async {
    _sudokuBox = await Hive.openBox('sudoku');

    return await Hive.openBox('tamamlanan_sudokular');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: _boxOpen(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Sudoku Home"),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Box box = Hive.box('settings');
                    box.put(
                      'darkTheme',
                      !box.get('darkTheme', defaultValue: false),
                    );
                  },
                ),
                PopupMenuButton(
                  icon: Icon(Icons.add),
                  onSelected: (value) {
                    if (_sudokuBox.isOpen) {
                      _sudokuBox.put('seviye', value);
                      _sudokuBox.put('sudokuRows', null);

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GamePage()),
                      );
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      value: dil['seviye_secin'],
                      child: Text(
                        dil['seviye_secin'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                      enabled: false,
                    ),
                    for (String k in sudokuSeviyeleri.keys)
                      PopupMenuItem(
                        value: k,
                        child: Text(k),
                      ),
                  ],
                ),
              ],
            ),
            body: ValueListenableBuilder<Box>(
                valueListenable: snapshot.data.listenable(),
                builder: (context, box, widget) {
                  return Column(
                    children: [
                      if (box.length == 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              dil['tamanlanan_yok'],
                            ),
                          ),
                        ),
                      for (Map eleman in box.values.toList().reversed.take(30))
                        ListTile(
                          onTap: () {},
                          title: Text("${eleman['date']}"),
                          subtitle: Text("${Duration(seconds: eleman['sure'])}"
                              .split('.')
                              .first),
                        )
                    ],
                  );
                }),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
