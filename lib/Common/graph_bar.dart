import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:balancemanagement_app/Common/utils.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleBarChart extends StatefulWidget {
  SimpleBarChart(this.seriesList, {this.animate});
  final List<charts.Series<dynamic, String>> seriesList;
  final bool? animate;

  @override
  _SimpleBarChartState createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  double sum = 0;
  String month = '';
  bool isMinus = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: new charts.BarChart(
            widget.seriesList,
            animate: widget.animate,
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
                      (num? value) {
                    return Utils.commaSeparated(value).toString() + SharedPrefs.getUnit();
                  }
              ),
            ),
            selectionModels: [
              new charts.SelectionModelConfig(
                  changedListener: (charts.SelectionModel<String> model) {
                    final selectedDatum = model.selectedDatum;
                    if (selectedDatum.isNotEmpty) {
                      final series = model.selectedSeries[0];
                      final index = selectedDatum[0].index!;
                      final color = series.colorFn!(index);
                      final value = series.measureFn(index);
                      final domain = series.domainFn(index);
                      // print(color);
                      // print(charts.ColorUtil.fromDartColor(App.plusColor));
                      // print(series.id);
                      // TODO 間違っているけど問題なさそう
                      isMinus = (color.toString() != '#1976d2ff' && series.id == 'payout');
                      // isMinus = true;
                      sum = value?.toDouble() ?? 0;
                      month = domain;
                      setState(() {});
                    }
                  }
              ),
            ],
          ),
        ),

        Container(
            height: 40,
            child: Center(
                child: AutoSizeText(
                  month + (month == '' ?'': '：') + '${(isMinus ? '-' : '')}'+ Utils.commaSeparated(sum ??= 0) + "${SharedPrefs.getUnit()}",
                  minFontSize: 4,
                  maxLines: 1,
                ),
            ),
        ),

      ],
    );
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}