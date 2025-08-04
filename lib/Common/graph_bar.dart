import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:balancemanagement_app/Common/utils.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../View/graph/graph_bar_page.dart';

class SimpleBarChart extends ConsumerStatefulWidget {
  SimpleBarChart(this.seriesList, {this.animate});
  final List<charts.Series<OrdinalSales, String>> seriesList;
  final bool? animate;

  @override
  _SimpleBarChartState createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends ConsumerState<SimpleBarChart> {
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

                      final salesData = selectedDatum[0].datum as OrdinalSales;
                      ref.read(ordinalSalesProvider.notifier).state = salesData;

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
  final String title;
  final double sumPrice;
  final int? categoryId;

  OrdinalSales(this.title, this.sumPrice, {this.categoryId = null});
  Map<String, dynamic> toJson() => {
    'title': title,
    'sumPrice': sumPrice,
    'categoryId': categoryId,
  };
}