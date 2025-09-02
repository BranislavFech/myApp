import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/models.dart';
import 'data/database_service.dart';
import 'sections/calendar_section.dart';
import 'sections/timer_section.dart';
import 'sections/stopwatch_section.dart';
import 'sections/teeth_section.dart';
import 'package:myapp/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.init();
  await DatabaseService().ensureDefaultCategories();
  print(await DatabaseService().activitiesCategories());

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
      DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(child: Text('Timer')),
                Tab(child: Text('Stopwatch')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
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
                  StopwatchSection(
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
                ],
              ),
            ),
          ],
        ),
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
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.amber,
              title: const Text('Start of the app'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  icon: Icon(Icons.settings),
                ),
              ],
            ),
            body: _widgetOptions[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  label: 'Timer',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
