import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/utils/utils.dart';
/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatefulWidget {
  SimpleBarChart(this.seriesList, {this.animate});
  final List<charts.Series> seriesList;
  final bool animate;

  @override
  _SimpleBarChartState createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  int sum;
  String month = '';
  bool isPlus = true;

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
                      (num value) {
                    return Utils.commaSeparated(value.floor()).toString() + SharedPrefs.getUnit();
                  }
              ),
            ),
            selectionModels: [
              new charts.SelectionModelConfig(
                  changedListener: (SelectionModel model) {
                    // print(model.selectedSeries[0].domainFn(model.selectedDatum[0].index));
                    // print(model.selectedSeries[0].measureFn(model.selectedDatum[0].index));
                    print(model.selectedSeries[0].colorFn(model.selectedDatum[0].index));
                    isPlus = model.selectedSeries[0].colorFn(model.selectedDatum[0].index).toString() == '#1976d2ff';
                    sum = model.selectedSeries[0].measureFn(model.selectedDatum[0].index);
                    month = model.selectedSeries[0].domainFn(model.selectedDatum[0].index);
                    setState(() {});
                  }
              ),
            ],
          ),
        ),

        Container(
            height: 40,
            child: Center(
                child: AutoSizeText(
                  month + '：'+ '${(isPlus ? '' : '-')}'+ Utils.commaSeparated(sum ??= 0) + "${SharedPrefs.getUnit()}",
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
  final int sales;

  OrdinalSales(this.year, this.sales);
}