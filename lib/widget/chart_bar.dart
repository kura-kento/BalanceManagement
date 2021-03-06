import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'income_monthly_data.dart';

class ChartBar extends StatefulWidget {
  @override
  _ChartBarState createState() => _ChartBarState();
}

class _ChartBarState extends State<ChartBar> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Population of U.S. over the years",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: charts.BarChart(
                    _getSeriesData(),
                    animate: true,
                    domainAxis: charts.OrdinalAxisSpec(
                        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  _getSeriesData() {
    List<charts.Series<IncomeMonthlyData, String>> series = [
      charts.Series(
        id: "income_monthly_data",
        data: data,
        domainFn: (IncomeMonthlyData series, _) => series.month,
        measureFn: (IncomeMonthlyData series, _) => series.income,
        colorFn: (IncomeMonthlyData series, _) => series.barColor,
      ),
    ];
    return series;
  }
}

