import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:myapp/minutes.dart';
import 'package:intl/intl.dart';

import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class MyDay {
  final String date;
  final bool cleanedTeethMorning;
  final bool cleanedTeethEvening;

  const MyDay({
    required this.date,
    required this.cleanedTeethEvening,
    required this.cleanedTeethMorning,
  });

  Map<String, Object?> toMap() {
    return {
      'date': date,
      'cleanedTeethMorning': cleanedTeethMorning ? 1 : 0,
      'cleanedTeethEvening': cleanedTeethEvening ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'MyDay{date: $date, cleanedTeethMorning: $cleanedTeethMorning, cleanedTeethEvening: $cleanedTeethEvening}';
  }
}


class Activity {
  final int? id;
  final String date;
  final int duration;
  final String category;

  const Activity({
    this.id,
    required this.date,
    required this.duration,
    required this.category,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'MyDay{id: $id, date: $date, duration: $duration, category: $category}';
  }
}

late final Future<Database> database;
late final Future<Database> databaseActivities;


Future<void> insertMyDay(MyDay myDay) async {
  final db = await database;

  await db.insert(
    'days',
    myDay.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<MyDay>> days() async {
  final db = await database;
  final List<Map<String, Object?>> dayMaps = await db.query('days');

  return dayMaps.map((map) {
    return MyDay(
      date: map['date'] as String,
      cleanedTeethMorning: (map['cleanedTeethMorning'] as int) == 1,
      cleanedTeethEvening: (map['cleanedTeethEvening'] as int) == 1,
    );
  }).toList();
}

Future<void> insertActivity(Activity activity) async {
  final db = await databaseActivities;

  await db.insert(
    'activities',
    activity.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Activity>> activities() async {
  final db = await databaseActivities;
  final List<Map<String, Object?>> activityMaps = await db.query('activities');

  return activityMaps.map((map) {
    return Activity(
      id: map['id'] as int,
      date: map['date'] as String,
      duration: map['duration'] as int,
      category: map['category'] as String,
    );
  }).toList();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  database = openDatabase(
    join(await getDatabasesPath(), 'test_db_v1.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE days (date TEXT PRIMARY KEY, cleanedTeethEvening INTEGER, cleanedTeethMorning INTEGER)',
      );
    },
    version: 1,
  );

  databaseActivities = openDatabase(
    join(await getDatabasesPath(), 'test_activities_db_v1.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE activities (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, duration INTEGER, category TEXT, FOREIGN KEY(date) REFERENCES days(date))',
      );
    },
    version: 1,
  );

  runApp(MyApp());
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
  int timeSelected = 0;
  bool activityCompleted = false;
  bool stopTimer = false;
  final List<String> timerCategories = [
    'Not Specified',
    'Work',
    'School',
    'House work',
    'Excercise',
  ];

  String selectedValue = 'Not Specified';

  void _startCountDown() {
    timeSelected = timeLeft;

    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timeLeft > 0 && !stopTimer) {
        setState(() {
          timeLeft--;
        });
        //stopTimer = true;
      } 
      else if (timeLeft == 0) {
        timer.cancel();
        activityCompleted = true;

        await insertActivity(
                Activity(
                  date: DateFormat('yyyy-MM-dd').format(today),
                  duration: timeSelected,
                  category: selectedValue,
                ),
              );

        print(await activities());
      }
      else {
        timer.cancel();
        stopTimer = false;
      }
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String formattedTime(int time) {
    final int sec = time % 60;
    final int min = (time / 60).floor();
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  bool cleanedTeethMorning = false;
  bool cleanedTeethEvening = false;

  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Column(
        children: [
          TableCalendar(
            focusedDay: today,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),

            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                today = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              today = focusedDay;
            },
          ),
        ],
      ),
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
            formattedTime(timeLeft),
            //(timeLeft).toString(),
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
          DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text('Select category', style: TextStyle(fontSize: 14)),
              items: timerCategories
                  .map(
                    (String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              value: selectedValue,
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value!;
                });
              },
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
            onChanged: (value) async {
              setState(() {
                cleanedTeethMorning = value!;
              });

              await insertMyDay(
                MyDay(
                  date: DateFormat('yyyy-MM-dd').format(today),
                  cleanedTeethMorning: cleanedTeethMorning,
                  cleanedTeethEvening: cleanedTeethEvening,
                ),
              );

              print(await days());
            },
          ),

          TeethCheckboxContainer(
            value: cleanedTeethEvening,
            text: 'Cleaned teeth in the evening',
            color: const Color.fromARGB(255, 164, 145, 248),
            onChanged: (value) async {
              setState(() {
                cleanedTeethEvening = value!;
              });

              await insertMyDay(
                MyDay(
                  date: DateFormat('yyyy-MM-dd').format(today),
                  cleanedTeethMorning: cleanedTeethMorning,
                  cleanedTeethEvening: cleanedTeethEvening,
                ),
              );

              print(await days());
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
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
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
