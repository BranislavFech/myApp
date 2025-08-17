import 'package:flutter/material.dart';
import 'package:myapp/data/database_service.dart';
import 'package:myapp/data/models.dart';
import 'package:myapp/minutes.dart';
import 'package:intl/intl.dart';

import 'dart:async';

class StopwatchSection extends StatefulWidget {
  final Function(int duration, String category) onActivityComplete;

  const StopwatchSection({super.key, required this.onActivityComplete});

  @override
  State<StopwatchSection> createState() => _StopwatchSectionState();
}

class _StopwatchSectionState extends State<StopwatchSection> {
  int timeLeft = 0;
  int timeSelected = 0;
  bool activityCompleted = false;
  bool stopTimer = false;
  Timer? _timer;
  List<ActivityCategory> categories = [];
  AlertDialog? addCategory;
  bool addCategoryBool = false;

  String? selectedValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService().activitiesCategories();
    setState(() {
      categories = [...cats, ActivityCategory(id: -1, category: '+ Add category')];
    });
  }

  String formattedTime(int time) {
    final int sec = time % 60;
    final int min = (time / 60).floor();
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _startCountDown() async {
    timeSelected = timeLeft;
    stopTimer = !stopTimer;

    if (stopTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeLeft++;
        });
      });
    } else {
      _timer?.cancel();
      timeSelected = timeLeft;

      setState(() {
        timeLeft = 0;
      });

      await widget.onActivityComplete(
        timeSelected,
        selectedValue ?? 'Not specified',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formattedTime(timeLeft),
          //(timeLeft).toString(),
          style: TextStyle(fontFamily: 'Bahnschrift', fontSize: 30),
        ),
        MaterialButton(
          onPressed: _startCountDown,
          color: Colors.deepPurple,
          child: Text(
            stopTimer ? 'Stop' : 'Start',
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
            items: categories
                .map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat.category,
                    child: Text(
                      cat.category,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            value: selectedValue,
            onChanged: (String? value) async {
              if (value != '+ Add category') {
                setState(() {
                  selectedValue = value!;
                });
              } else {
                String? newCategory = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    String input = "";

                    return AlertDialog(
                      title: Text("Add new category"),
                      content: TextField(
                        onChanged: (value) {
                          input = value;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, input),
                          child: const Text("Add"),
                        ),
                      ],
                    );
                  },
                );

                if (newCategory != null && newCategory.isNotEmpty) {
                  await DatabaseService().insertActivityCategory(ActivityCategory(category: newCategory));
                  _loadCategories();
                  setState(() {
                    selectedValue = newCategory;
                  });

                  print(await DatabaseService().activitiesCategories());
                }
              }
              ;
            },
          ),
        ),
      ],
    );
  }
}
