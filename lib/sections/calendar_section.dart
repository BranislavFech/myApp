import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/models.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/data/database_service.dart';

class CalendarSection extends StatefulWidget {
  final DateTime today;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarSection({
    super.key,
    required this.today,
    required this.onDaySelected,
  });

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  List<ActivityCategory> categories = [];
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<String, int> weekTotals = {};
  Map<String, int> monthTotals = {};
  Map<DateTime, List<Map<String, dynamic>>> activities = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
    _loadTotals();
    _loadActivities();
  }

  String formattedTime(int timeInSeconds) {
    final int hours = (timeInSeconds ~/ 3600); // celé hodiny
    final int minutes = (timeInSeconds % 3600) ~/ 60; // zvyšné minúty
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  String formattedTimehhmmss(int timeInSeconds) {
  final int hours = timeInSeconds ~/ 3600;             // celé hodiny
  final int minutes = (timeInSeconds % 3600) ~/ 60;   // zvyšné minúty
  final int seconds = timeInSeconds % 60;             // zvyšné sekundy

  return "${hours.toString().padLeft(2, '0')}:"
         "${minutes.toString().padLeft(2, '0')}:"
         "${seconds.toString().padLeft(2, '0')}";
  }


  Future<void> _loadCategories() async {
    final cats = await DatabaseService().activitiesCategories();
    setState(() {
      categories = cats;
    });
  }

  Future<void> _loadActivities() async {
    final acts = await DatabaseService().activitiesData();
    print(acts);
    setState(() {
      activities = acts;
    });
  }

  Future<void> _loadTotals() async {
    final totals = await DatabaseService().totalHoursPerCategory();
    setState(() {
      weekTotals = totals['week'] ?? {};
      monthTotals = totals['month'] ?? {};
    });
    print(totals);
  }

  @override
  Widget build(BuildContext context) {
    final isWeek = _calendarFormat == CalendarFormat.week;
    final currentTotals = isWeek ? weekTotals : monthTotals;

    return Column(
      children: [
        TableCalendar(
          focusedDay: widget.today,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),

          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            widget.onDaySelected(selectedDay, focusedDay);

            String formatedDay = DateFormat(
              'd.M.yyyy - EEEE',
            ).format(selectedDay);

            //print('Selected day is $selectedDay');

            final normalizedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            final dayActivities = activities[normalizedDay] ?? [];

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(formatedDay),
                content: SizedBox(
                  width: double.maxFinite,
                  child: dayActivities.isEmpty
                      ? const Text('No activities for this day')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: dayActivities.length,
                          itemBuilder: (context, index) {
                            final act = dayActivities[index];

                            final category = act['category'] as String;
                            final duration = act['duration'] as int;

                            final time = formattedTimehhmmss(duration);
                            return ListTile(
                              title: Text(category),
                              trailing: Text(time),
                            );
                          },
                        ),
                ),
              ),
            );
          },

          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },

          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
        ),
        ElevatedButton(
          onPressed: () async {
            await _loadCategories();
            await _loadTotals();
            await _loadActivities();
          },
          child: const Text('Update goals'),
        ),
        Expanded(
          child: FutureBuilder<List<ActivityCategory>>(
            future: DatabaseService().activitiesCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              final cats = snapshot.data!;
              return ListView.builder(
                itemCount: cats.isNotEmpty ? cats.length - 1 : 0,
                itemBuilder: (context, index) {
                  final cat = cats[index + 1];
                  final current = currentTotals[cat.category] ?? 0;

                  final goal = isWeek ? cat.goal_hours : cat.goal_hours * 4;
                  final progress = goal > 0
                      ? ((current / 3600) / goal).clamp(0.0, 1.0)
                      : 0.0;

                  return ListTile(
                    title: Text(cat.category),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 4),

                        (Text('${(formattedTime(current))} / $goal h')),
                      ],
                    ),
                    trailing: Text(goal.toString()),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
