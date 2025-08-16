import 'dart:developer';

import 'package:flutter/material.dart';
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

  void _startCountDown() async {
    timeSelected = timeLeft;
    stopTimer = !stopTimer;

    if (stopTimer){
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeLeft++;
        });
      });
    } else{
      _timer?.cancel();
      timeSelected = timeLeft;

      setState(() {
        timeLeft = 0;
      });

      await widget.onActivityComplete(timeSelected, selectedValue);
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
            stopTimer? 'Stop' : 'Start',
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
