import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:myapp/minutes.dart';

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDay {
  final bool cleanedTeethMorning;
  final bool cleanedTeethEvening;

  final bool readBook;
  final int pagesRead;

  final bool coldShower;

  final bool excersized;
  final bool pushWorkout;
  final bool pullWorkout;
  final bool legsWorkout;

  const MyDay({
    required this.cleanedTeethEvening,
    required this.readBook,
    required this.pagesRead,
    required this.coldShower,
    required this.excersized,
    required this.pushWorkout,
    required this.pullWorkout,
    required this.legsWorkout,
    required this.cleanedTeethMorning,
  });

  Map<String, Object?> toMap() {
    return {
      'cleanedTeethMorning': cleanedTeethMorning ? 1 : 0,
      'cleanedTeethEvening': cleanedTeethEvening ? 1 : 0,
      'readBook': readBook ? 1 : 0,
      'pagesRead': pagesRead,
      'coldShower': coldShower ? 1 : 0,
      'excersized': excersized ? 1 : 0,
      'pushWorkout': pushWorkout ? 1 : 0,
      'pullWorkout': pullWorkout ? 1 : 0,
      'legsWorkout': legsWorkout ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'MyDay{cleanedTeethMorning: $cleanedTeethMorning, cleanedTeethEvening: $cleanedTeethEvening, readBook: $readBook, pagesRead: $pagesRead, coldShower: $coldShower, excersized: $excersized, pushWorkout: $pushWorkout, pullWorkout: $pullWorkout, legsWorkout: $legsWorkout}';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());

  /*
  final database = openDatabase(
    join(await getDatabasesPath(), 'days_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE days (cleanedTeethEvening INTEGER, cleanedTeethMorning INTEGER, readBook INTEGER, pagesRead INTEGER, coldShower INTEGER, excersized INTEGER, pushWorkout INTEGER, pullWorkout INTEGER, legsWorkout INTEGER)',
      );
    },
    version: 1,
  );

  Future<void> insertMyDay(MyDay myDay) async {
    final db = await database;

    await db.insert(
      'days',
      myDay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  var day = MyDay(
    cleanedTeethEvening: true,
    readBook: true,
    pagesRead: 7,
    coldShower: false,
    excersized: true,
    pushWorkout: true,
    pullWorkout: false,
    legsWorkout: false,
    cleanedTeethMorning: false,
  );

  await insertMyDay(day);

  Future<List<MyDay>> days() async {
    final db = await database;
    final List<Map<String, Object?>> dayMaps = await db.query('days');

    return dayMaps.map((map) {
      return MyDay(
        cleanedTeethMorning: (map['cleanedTeethMorning'] as int) == 1,
        cleanedTeethEvening: (map['cleanedTeethEvening'] as int) == 1,
        readBook: (map['readBook'] as int) == 1,
        pagesRead: map['pagesRead'] as int,
        coldShower: (map['coldShower'] as int) == 1,
        excersized: (map['excersized'] as int) == 1,
        pushWorkout: (map['pushWorkout'] as int) == 1,
        pullWorkout: (map['pullWorkout'] as int) == 1,
        legsWorkout: (map['legsWorkout'] as int) == 1,
      );
    }).toList();
  }

  print(await days());
  */
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class TeethCheckboxContainer extends StatelessWidget {
  final bool value;
  final String text;
  final Color color;
  final void Function(bool?)? onChanged;

  const TeethCheckboxContainer({
    super.key,
    required this.value,
    required this.text,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(value: value, onChanged: onChanged),
          ),

          Text(text, style: TextStyle(fontFamily: 'Bahnschrift', fontSize: 20)),
        ],
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  int timeLeft = 0;

  void _startCountDown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool cleanedTeethMorning = false;
  bool cleanedTeethEvening = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Column(
        children: [
          Container(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              onSelectedItemChanged: (value) {
                setState(() {
                  timeLeft = (1 + value) * 300;
                });
              },
              itemExtent: 50,
              physics: FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 12,
                builder: (context, index) {
                  return MyMinutes(mins: index);
                },
              ),
            ),
          ),
          Text(
            (timeLeft).toString(),
            style: TextStyle(fontFamily: 'Bahnschrift', fontSize: 30),
          ),
          MaterialButton(
            onPressed: _startCountDown,
            color: Colors.deepPurple,
            child: Text(
              'Start',
              style: TextStyle(
                fontFamily: 'Bahnschrift',
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      Column(
        children: [
          TeethCheckboxContainer(
            value: cleanedTeethMorning,
            text: 'Cleaned teeth in the morning',
            color: const Color.fromARGB(255, 243, 216, 129),
            onChanged: (value) {
              setState(() {
                cleanedTeethMorning = value!;
              });
            },
          ),

          TeethCheckboxContainer(
            value: cleanedTeethEvening,
            text: 'Cleaned teeth in the evening',
            color: const Color.fromARGB(255, 164, 145, 248),
            onChanged: (value) {
              setState(() {
                cleanedTeethEvening = value!;
              });
            },
          ),
        ],
      ),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Start of the app'),
        ),
        body: Column(children: [_widgetOptions[_selectedIndex]]),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
