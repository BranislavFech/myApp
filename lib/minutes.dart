import 'package:flutter/material.dart';


class MyMinutes extends StatelessWidget {
  int mins;

  MyMinutes({required this.mins});

  @override 
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text(
        ((mins+1)*5).toString()
        ),),
    );
  }
}