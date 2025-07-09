import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class IncomeMonthlyData {
  String month;
  int income;
  charts.Color barColor;
  IncomeMonthlyData({
    required this.month,
    required this.income,
    required this.barColor
  });
}

final List<IncomeMonthlyData> data = [
  IncomeMonthlyData(
    month: "2021年 3月",
    income: 50189209,
    barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)
  ),
];