import 'package:flutter/material.dart';

class TeethCheckboxContainer extends StatelessWidget {
  final bool value;
  final String text;
  final Color color;
  final void Function(bool?)? onChanged;

  const TeethCheckboxContainer({
    super.key,
    required this.value,
    required this.text,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(value: value, onChanged: onChanged),
          ),

          Text(text, style: TextStyle(fontFamily: 'Bahnschrift', fontSize: 20)),
        ],
      ),
    );
  }
}