import 'package:balancemanagement_app/utils/app.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/graph_bar.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class GraphBarPage extends StatefulWidget {
  @override
  _GraphBarPageState createState() => _GraphBarPageState();
}

class _GraphBarPageState extends State<GraphBarPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();

  List<OrdinalSales> data = [
    // new OrdinalSales('2014', 5),
    // new OrdinalSales('2015', 25),
    // new OrdinalSales('2016', 100),
    // new OrdinalSales('2017', 150),
    // new OrdinalSales('2018', 300),
    // new OrdinalSales('2019', 600),
    // new OrdinalSales('2020', 1000),
    // new OrdinalSales('2021', 2500),
  ];

  @override
  void initState(){
    updateListView();
    super.initState();
  }

  Future<void> updateListView() async{
    List _calendarList = await databaseHelper.getWeekList();
    print(_calendarList);
    data = await dataSet(_calendarList).reversed.toList();
    setState(() {});
  }

  List<OrdinalSales> dataSet(list){
    var listIndex = 0;
    var date = DateTime.now();
    return List.generate(App.graphLength, (index){
      var _month       = DateFormat("yyyy-MM").format(DateTime(date.year, date.month - index, 1));
      var month_format = DateFormat("M月").format(DateTime(date.year, date.month - index, 1));

      //配列の中を全て当てはまったら他は０にする。
      if(listIndex == list.length) return OrdinalSales(month_format ,0);
      if(_month == list[listIndex]['month']){
        listIndex++;
        return OrdinalSales(month_format ,list[listIndex - 1]['sum']);
      }
      return OrdinalSales(month_format ,0);
    });
  }

   List<charts.Series<OrdinalSales, String>> _createSampleData(data) {
    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SimpleBarChart(
              _createSampleData(data),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}
