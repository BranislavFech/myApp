import 'package:flutter/material.dart';
import 'package:myapp/minutes.dart';
import 'package:intl/intl.dart';

import 'dart:async';

class TimerSection extends StatefulWidget {
  final Function(int duration, String category) onActivityComplete;

  const TimerSection({super.key, required this.onActivityComplete});

  @override
  State<TimerSection> createState() => _TimerSectionState();
}

class _TimerSectionState extends State<TimerSection> {
  int timeLeft = 300;
  int timeSelected = 0;
  bool activityCompleted = false;
  bool stopTimer = false;
  MaterialButton? _button;
  bool timerRunning = true;
  final List<String> timerCategories = [
    'Not Specified',
    'Work',
    'School',
    'House work',
    'Excercise',
  ];

  String selectedValue = 'Not Specified';

  String formattedTime(int time) {
    final int sec = time % 60;
    final int min = (time / 60).floor();
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _startCountDown() {
    timeSelected = timeLeft;

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timeLeft > 0 && !stopTimer) {
        timerRunning = false;
        setState(() {
          timeLeft--;
        });
        //stopTimer = true;
      } else if (timeLeft == 0) {
        timer.cancel();
        stopTimer = true;
        setState(() {
          timeLeft = 300;
          timerRunning = true;
        });
        await widget.onActivityComplete(timeSelected,selectedValue);
      } else {
        timer.cancel();
        stopTimer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(fontFamily: 'Bahnschrift', fontSize: 30),
        ),
        if(timerRunning)
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
    );
  }
}