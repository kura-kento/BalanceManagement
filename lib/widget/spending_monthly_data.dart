import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class MonthlyData {
  String month;
  int money;
  charts.Color barColor;
  MonthlyData({
    required this.month,
    required this.money,
    required this.barColor
  });
}

final List<MonthlyData> data = [
  MonthlyData(
      month: "2021年 3月",
      money: 189209,
      barColor: charts.ColorUtil.fromDartColor(Colors.redAccent)
  ),
];