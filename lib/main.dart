import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/models.dart';
import 'data/database_service.dart';
import 'sections/calendar_section.dart';
import 'sections/timer_section.dart';
import 'sections/stopwatch_section.dart';
import 'sections/teeth_section.dart';
import 'package:myapp/settings/settings_page.dart';

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

  GlobalKey<StopwatchSectionState> stopwatchKey = GlobalKey();
  GlobalKey<TimerSectionState> timerKey = GlobalKey();

  //late TabController _tabController;

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: NavigatorState());
  //   _tabController.addListener(() async {
  //     if (_tabController.indexIsChanging) {
  //       if ((timerKey.currentState?.isRunning ?? false) ||
  //           (stopwatchKey.currentState?.isRunning ?? false)) {
  //         bool leave = await _confirmLeave(context);
  //         if (!leave) {
  //           // Vráť späť na pôvodný tab
  //           _tabController.index = _tabController.previousIndex;
  //         }
  //       }
  //     }
  //   });
  // }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  Future<bool> _confirmLeave(BuildContext context, String section) async {
    String title;
    String content;

    if (section == 'stopwatch') {
      title = "Stopwatch is running!";
      content = "Do you want to leave and save your time?";
    } else {
      title = "Timer is running!";
      content = "Do you want to leave and abandon your progress?";
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Leave"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onItemTapped(int index, BuildContext context) async {
    if (stopwatchKey.currentState?.isRunning ?? false) {
      bool leave = await _confirmLeave(context, 'stopwatch');
      if (!leave) return;

      if (stopwatchKey.currentState?.isRunning ?? false) {
        final duration = stopwatchKey.currentState!.elapsedSeconds;
        print("\n\n\n\n$duration\n\n\n\n");
        final category =
            stopwatchKey.currentState!.selectedCategory ?? 'Not specified';

        await DatabaseService().insertActivity(
          Activity(
            date: DateFormat('yyyy-MM-dd').format(today),
            duration: duration,
            category: category,
          ),
        );
      }
    } else if (timerKey.currentState?.isRunning ?? false) {
      bool leave = await _confirmLeave(context, 'timer');
      if (!leave) return;
    }
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
            TabBar(
              onTap: (tabIndex) async {
                if (stopwatchKey.currentState?.isRunning ?? false) {
                  bool leave = await _confirmLeave(context, 'stopwatch');
                  if (!leave) return;
                  // uloženie stopwatch
                } else if (timerKey.currentState?.isRunning ?? false) {
                  bool leave = await _confirmLeave(context, 'timer');
                  if (!leave) return;
                  // uloženie timer
                }
              },
              tabs: [
                Tab(child: Text('Timer')),
                Tab(child: Text('Stopwatch')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TimerSection(
                    key: timerKey,
                    stopwatchState: stopwatchKey.currentState,
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
                    key: stopwatchKey,
                    timerState: timerKey.currentState,
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
              onTap: (index) => _onItemTapped(index, context),
            ),
          );
        },
      ),
    );
  }
}
