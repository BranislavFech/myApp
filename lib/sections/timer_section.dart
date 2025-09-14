import 'package:flutter/material.dart';
import 'package:myapp/data/database_service.dart';
import 'package:myapp/data/models.dart';
import 'package:myapp/minutes.dart';
import 'package:intl/intl.dart';
import 'package:myapp/sections/stopwatch_section.dart';

import 'dart:async';

import 'package:myapp/sections/widgets/category_dropdown.dart';

class TimerSection extends StatefulWidget {
  final Function(int duration, String category) onActivityComplete;
  final StopwatchSectionState? stopwatchState;

  const TimerSection({super.key, required this.onActivityComplete, this.stopwatchState});

  @override
  State<TimerSection> createState() => TimerSectionState();
}

class TimerSectionState extends State<TimerSection> with AutomaticKeepAliveClientMixin{
  int timeLeft = 300;
  int timeSelected = 0;
  bool activityCompleted = false;
  bool stopTimer = false;
  MaterialButton? _button;
  bool timerRunning = true;
  List<ActivityCategory> categories = [];
  Timer? _timer;
  GlobalKey<StopwatchSectionState> stopwatchKey = GlobalKey();


  String? selectedValue;

  bool get isRunning => !stopTimer && !timerRunning;

  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override 
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService().activitiesCategories();
    setState(() {
      categories = cats;
    });
  }

  String formattedTime(int time) {
    final int sec = time % 60;
    final int min = (time / 60).floor();
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _startCountDown() {
    if(widget.stopwatchState?.isRunning ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Stopwatch is running! Stop it first.'))
      );
      return;
    }

    timeSelected = timeLeft;

    _timer=Timer.periodic(const Duration(seconds: 1), (timer) async {
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
        await widget.onActivityComplete(timeSelected,selectedValue ?? 'Not Specified');
      } else {
        timer.cancel();
        stopTimer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.center,
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
        CategoryDropdown(
          selectedValue: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
          },
        ),
      ],
    );
  }
}