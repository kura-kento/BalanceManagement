import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Day {
  Day(this.name, this.color);
  String name;
  Color color;
}

class Week extends StatelessWidget {
  Week({Key key}) : super(key: key);
  final List<Day> week = [
    Day('日', Colors.red[200]),
    Day('月', Colors.grey[300]),
    Day('火', Colors.grey[300]),
    Day('水', Colors.grey[300]),
    Day('木', Colors.grey[300]),
    Day('金', Colors.grey[300]),
    Day('土', Colors.blue[200]),
  ];

  @override
  Widget build(BuildContext context) {
    final result = <Widget>[];
    for (var day in week) {
      result.add(
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            color: day.color,
            child: Text(day.name),
          ),
        ),
      );
    }
    return Row(children: result);
  }
}
