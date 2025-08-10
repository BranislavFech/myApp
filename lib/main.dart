import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models.dart';
import 'database_service.dart';
import 'calendar_section.dart';
import 'timer_section.dart';
import 'teeth_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime today = DateTime.now();
  bool cleanedTeethMorning = false;
  bool cleanedTeethEvening = false;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      CalendarSection(
        today: today,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            today = focusedDay;
          });
        },
      ),
      TimerSection(
        onActivityComplete: (duration, category) async {
          await DatabaseService().insertActivity(
            Activity(
              date: DateFormat('yyyy-MM-dd').format(today),
              duration: duration,
              category: category,
            ),
          );

          print(await DatabaseService().activities());
        },
      ),
      TeethSection(
        today: today,
        cleanedTeethMorning: cleanedTeethMorning,
        cleanedTeethEvening: cleanedTeethEvening,
        onChanged: (morning, evening) async {
          await DatabaseService().insertMyDay(
            MyDay(
              date: DateFormat('yyyy-MM-dd').format(today),
              cleanedTeethEvening: evening,
              cleanedTeethMorning: morning,
            ),
          );

          print(await DatabaseService().days());
        },
      ),
    ];


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Start of the app'),
        ),
        body: _widgetOptions[_selectedIndex],
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
