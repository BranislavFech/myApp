import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

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

class _MyAppState extends State<MyApp> {
  bool cleanedTeethMorning = false;
  bool cleanedTeethEvening = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Start of the app'),
        ),
        body: Column(
          children: [
            TeethCheckboxContainer(
              value: cleanedTeethMorning,
              text: 'Cleaned teeth in the morning',
              color: const Color.fromARGB(255, 243, 216, 129),
              onChanged: (value) {
                setState(() {
                  cleanedTeethMorning = value!;
                });
              },
            ),

            TeethCheckboxContainer(
              value: cleanedTeethEvening,
              text: 'Cleaned teeth in the evening',
              color: const Color.fromARGB(255, 164, 145, 248),
              onChanged: (value) {
                setState(() {
                  cleanedTeethEvening = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
