import 'package:flutter/material.dart';
import 'package:myapp/data/database_service.dart';
import 'package:myapp/data/models.dart';
import 'package:myapp/minutes.dart';
import 'package:intl/intl.dart';
import 'timer_section.dart';

import 'dart:async';

import 'package:myapp/sections/widgets/category_dropdown.dart';

class StopwatchSection extends StatefulWidget {
  final Function(int duration, String category) onActivityComplete;
  final TimerSectionState? timerState;

  const StopwatchSection({super.key, required this.onActivityComplete, this.timerState});

  @override
  State<StopwatchSection> createState() => StopwatchSectionState();
}

class StopwatchSectionState extends State<StopwatchSection> with AutomaticKeepAliveClientMixin{
  int timeLeft = 0;
  int timeSelected = 0;
  bool activityCompleted = false;
  bool stopTimer = false;
  Timer? _timer;
  List<ActivityCategory> categories = [];
  AlertDialog? addCategory;
  bool addCategoryBool = false;

  String? selectedValue;

  bool get isRunning => stopTimer;
  int get elapsedSeconds => timeLeft;
  String? get selectedCategory => selectedValue;

  GlobalKey<TimerSectionState> timerKey = GlobalKey();


  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    super.dispose();
  }

  @override 
  bool get wantKeepAlive => true;

  String formattedTime(int time) {
    final int sec = time % 60;
    final int min = (time / 60).floor();
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  void _startCountDown() async {
    if(widget.timerState?.isRunning ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Timer is running! Wait for it to stop.'))
      );
      return;
    }

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
    super.build(context);
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
