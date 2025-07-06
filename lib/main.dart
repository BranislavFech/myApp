import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: const Text('Start of the app'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.verified),
          onPressed: (){
            print('Hello World!');
            setState(() {
              count++;
            });
        }),
        body:Center(
          child: Text(
            '$count',
            style: TextStyle(fontSize: 60),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business'),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'Work')
          ]),
      ),
    );
  }
}
