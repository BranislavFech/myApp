import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'database_service.dart';
import 'teeth_checkbox.dart';

class TeethSection extends StatefulWidget {
  final DateTime today;
  final bool cleanedTeethMorning;
  final bool cleanedTeethEvening;
  final Function(bool morning, bool evening) onChanged;

  const TeethSection({
    super.key,
    required this.today,
    required this.cleanedTeethMorning,
    required this.cleanedTeethEvening,
    required this.onChanged,
  });

  @override
  State<TeethSection> createState() => _TeethSectionState();
}

class _TeethSectionState extends State<TeethSection> {
  late bool morning;
  late bool evening;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    morning = widget.cleanedTeethMorning;
    evening = widget.cleanedTeethEvening;
  }

  Future<void> _updateTeethData() async {
    await widget.onChanged(morning, evening);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeethCheckboxContainer(
          value: morning,
          text: 'Cleaned teeth in the morning',
          color: const Color.fromARGB(255, 243, 216, 129),
          onChanged: (value) async {
            setState(() {
              morning = value!;
            });

            await _updateTeethData();
          },
        ),

        TeethCheckboxContainer(
          value: evening,
          text: 'Cleaned teeth in the evening',
          color: const Color.fromARGB(255, 164, 145, 248),
          onChanged: (value) async {
            setState(() {
              evening = value!;
            });

            await _updateTeethData();
          },
        ),
      ],
    );
  }
}
