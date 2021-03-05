import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';

import 'package:sudoku_game/language.dart';
import 'package:sudoku_game/sudokular.dart';

final Map<String, int> sudokuSeviyeleri = {
  dil['seviye1']: 62,
  dil['seviye2']: 53,
  dil['seviye3']: 44,
  dil['seviye4']: 35,
  dil['seviye5']: 26,
  dil['seviye6']: 17,
};

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Timer _sayac;
  bool _note = false;
  List _sudoku = [], _sudokuHistory = [];
  final Box _sudokuBox = Hive.box('sudoku');
  String _sudokuString;

  @override
  void initState() {
    super.initState();
    sudokuCreate();
    _sayac = Timer.periodic(Duration(seconds: 1), (timer) {
      int sure = _sudokuBox.get('sure');
      _sudokuBox.put('sure', ++sure);
    });
  }

  @override
  void dispose() {
    if (_sayac != null && _sayac.isActive) _sayac.cancel();
    super.dispose();
  }

  void sudokuCreate() {
    int showBox = sudokuSeviyeleri[
        _sudokuBox.get('seviye', defaultValue: dil['seviye2'])];

    _sudokuString = sudokular[Random().nextInt(sudokular.length)];
    _sudokuBox.put('sudokuString', _sudokuString);

    _sudoku = List.generate(
        9, (i) => List.generate(9, (j) => "e" + _sudokuString[i * 9 + j]));

    int i = 0;
    while (i < 81 - showBox) {
      int x = Random().nextInt(9);
      int y = Random().nextInt(9);

      if (_sudoku[x][y] != "0") {
        _sudoku[x][y] = "0";
        i++;
      }
    }

    int hint = 26;

    _sudokuBox.put('hint', hint);
    _sudokuBox.put('sudokuRows', _sudoku);
    _sudokuBox.put('xy', "99");
    _sudokuBox.put('sure', 0);

    print(_sudokuString);
  }

  void _save() {
    String _sudokuStatus = _sudokuBox.get('sudokuRows').toString();

    if (_sudokuStatus.contains("0")) {
      Map historyItem = {
        'sudokuRows': _sudokuBox.get('sudokuRows'),
        'xy': _sudokuBox.get('xy'),
        'hint': _sudokuBox.get('hint'),
      };

      _sudokuHistory.add(jsonEncode(historyItem));

      _sudokuBox.put('sudokuHistory', _sudokuHistory);
    } else {
      _sudokuString = _sudokuBox.get('sudokuString');
      String control = _sudokuStatus.replaceAll(RegExp(r'[e,[,\], ]'), '');

      String mesaj = "Sudoku Hatalı. Kontrol Et.";

      if (control == _sudokuString) {
        mesaj = "Sudoku Başarııyla tamamlandı. Tebrikler";
        Box tamamlananKutusu = Hive.box('tamamlanan_sudokular');

        Map tamamlananSudoku = {
          'date': DateTime.now(),
          'sure': _sudokuBox.get('sure'),
          'sudoku': _sudokuBox.get('sudokuRows'),
        };

        tamamlananKutusu.add(tamamlananSudoku);
        //_sudokuBox.put('sudokuRows', null);

        Navigator.pop(context);
      }
      Fluttertoast.showToast(
        msg: mesaj,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
      );
      print("Sudoku son durum: $control");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sudako Game"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HiveListener(
                box: _sudokuBox,
                keys: ['sure'],
                builder: (box) {
                  String sure = Duration(seconds: box.get('sure')).toString();
                  return Text(sure.split('.').first);
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(_sudokuBox.get('seviye', defaultValue: dil['seviye2'])),
          ValueListenableBuilder<Box>(
              valueListenable:
                  _sudokuBox.listenable(keys: ['xy', 'sudokuRows']),
              builder: (context, box, _) {
                String xy = box.get('xy');
                int xC = int.parse(xy.substring(0, 1));
                int yC = int.parse(xy.substring(1));
                List sudokuRows = box.get('sudokuRows');

                return AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    margin: EdgeInsets.all(2.0),
                    padding: EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: [
                        for (int x = 0; x < 9; x++)
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      for (int y = 0; y < 9; y++)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: xC == x && yC == y
                                                      ? Colors.orangeAccent
                                                      : Colors.red.withOpacity(
                                                          xC == x || yC == y
                                                              ? 0.8
                                                              : 1.0),
                                                  margin: EdgeInsets.all(1.0),
                                                  alignment: Alignment.center,
                                                  child:
                                                      "${sudokuRows[x][y]}"
                                                              .startsWith("e")
                                                          ? Text(
                                                              "${sudokuRows[x][y]}"
                                                                  .substring(1),
                                                              style: TextStyle(
                                                                  fontSize: 21,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          : InkWell(
                                                              onTap: () {
                                                                print("$x$y");
                                                                print(
                                                                    "length :${sudokuRows[x][y]}"
                                                                        .length);

                                                                _sudokuBox.put(
                                                                    'xy',
                                                                    '$x$y');
                                                              },
                                                              child: Center(
                                                                child: "${sudokuRows[x][y]}"
                                                                            .length >
                                                                        8
                                                                    ? Column(
                                                                        children: [
                                                                          for (int i = 0;
                                                                              i < 9;
                                                                              i += 3)
                                                                            Expanded(
                                                                              child: Row(
                                                                                children: [
                                                                                  for (int j = 0; j < 3; j++)
                                                                                    Expanded(
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          "${sudokuRows[x][y]}".split('')[i + j] == "0" ? "" : "${sudokuRows[x][y]}".split('')[i + j],
                                                                                          style: TextStyle(fontSize: 10),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      )
                                                                    : Text(
                                                                        sudokuRows[x][y] !=
                                                                                "0"
                                                                            ? sudokuRows[x][y]
                                                                            : "",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                              ),
                                                            ),
                                                ),
                                              ),
                                              if (y == 2 || y == 5)
                                                SizedBox(
                                                  width: 2.0,
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (x == 2 || x == 5)
                                  SizedBox(
                                    height: 2.0,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.amber,
                                margin: EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    String xy = _sudokuBox.get('xy');
                                    if (xy != "99") {
                                      int xC = int.parse(xy.substring(0, 1)),
                                          yC = int.parse(xy.substring(1));

                                      _sudoku[xC][yC] = "0";
                                      _sudokuBox.put('sudokuRows', _sudoku);
                                      _save();
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        "Sil",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder<Box>(
                              valueListenable:
                                  _sudokuBox.listenable(keys: ['hint']),
                              builder: (context, box, widget) {
                                return Expanded(
                                  child: Card(
                                    color: Colors.amber,
                                    margin: EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        String xy = box.get('xy');

                                        if (xy != "99" && box.get('hint') > 0) {
                                          int xC =
                                                  int.parse(xy.substring(0, 1)),
                                              yC = int.parse(xy.substring(1));
                                          String resultString =
                                              box.get('sudokuString');
                                          List resultSudoku = List.generate(
                                              9,
                                              (i) => List.generate(
                                                  9,
                                                  (j) =>
                                                      resultString[i * 9 + j]));
                                          print(_sudoku[xC][yC]);
                                          print(resultSudoku[xC][yC]);

                                          if (_sudoku[xC][yC] !=
                                              resultSudoku[xC][yC]) {
                                            _sudoku[xC][yC] =
                                                resultSudoku[xC][yC];

                                            box.put('sudokuRows', _sudoku);

                                            box.put(
                                                'hint', box.get('hint') - 1);
                                            _save();
                                          }
                                        }
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.lightbulb_outline,
                                            color: Colors.black,
                                          ),
                                          Text(
                                            "İpucu : ${_sudokuBox.get('hint')}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: _note ? Colors.blueGrey : Colors.amber,
                                margin: EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _note = !_note;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.note_add,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        "Not",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.amber,
                                margin: EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (_sudokuHistory.length > 1) {
                                      _sudokuHistory.removeLast();
                                      Map last =
                                          jsonDecode(_sudokuHistory.last);
                                      _sudokuBox.put(
                                        'sudokuRows',
                                        last['sudokuRows'],
                                      );
                                      _sudokuBox.put('xy', last['xy']);

                                      _sudokuBox.put('hint', last['hint']);

                                      _sudokuBox.put(
                                          'sudokuHistory', _sudokuHistory);
                                      _sudoku = last['sudokuRows'];
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.undo_rounded,
                                        color: Colors.black,
                                      ),
                                      Text(
                                        "Geri Al",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: [
                    for (int i = 1; i < 10; i += 3)
                      Expanded(
                          child: Row(
                        children: [
                          for (int j = 0; j < 3; j++)
                            Expanded(
                                child: Card(
                              color: Colors.amber,
                              shape: CircleBorder(),
                              child: InkWell(
                                onTap: () {
                                  String xy = _sudokuBox.get('xy');
                                  if (xy != "99") {
                                    int xC = int.parse(xy.substring(0, 1)),
                                        yC = int.parse(xy.substring(1));
                                    if (!_note) {
                                      _sudoku[xC][yC] = "${i + j}";
                                    } else {
                                      if ("${_sudoku[xC][yC]}".length < 8) {
                                        _sudoku[xC][yC] = "000000000";
                                      }

                                      _sudoku[xC][yC] = "${_sudoku[xC][yC]}"
                                          .replaceRange(
                                              i + j - 1,
                                              i + j,
                                              "${_sudoku[xC][yC]}".substring(
                                                          i + j - 1, i + j) ==
                                                      "${i + j}"
                                                  ? "0"
                                                  : "${i + j}");
                                    }
                                    print("${i + j}");
                                    _sudokuBox.put('sudokuRows', _sudoku);
                                    _save();
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.all(3.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${i + j}",
                                    style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ))
                        ],
                      ))
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
