import 'package:balancemanagement_app/utils/app.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/graph_bar.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

enum RadioValue { ALL, Twice }

class GraphBarPage extends StatefulWidget {
  @override
  _GraphBarPageState createState() => _GraphBarPageState();
}

class _GraphBarPageState extends State<GraphBarPage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  RadioValue _radioValue = RadioValue.ALL;
  List<OrdinalSales> data = [];
  List<OrdinalSales>  ListPlus = [];
  List<OrdinalSales>  ListMinus = [];

  @override
  void initState(){
    updateListView();
    super.initState();
  }

  Future<void> updateListView() async{
    List _calendarList = await databaseHelper.getMonthList();
    print(_calendarList);
    data = await dataSet(_calendarList).reversed.toList();

    List _ListPlus = await databaseHelper.getMonthListPlus();
    List _ListMinus = await databaseHelper.getMonthListMinus();
    ListPlus = await dataSet(_ListPlus).reversed.toList();
    ListMinus = await dataSet(_ListMinus).reversed.toList();

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

  //引数が２つの場合、支出を追加する。
   List<charts.Series<OrdinalSales, String>> _createSampleData(data, {payout}) {
    return [
      new charts.Series<OrdinalSales, String>(
        id: 'income',
        colorFn: (OrdinalSales sales,i) => sales.sales >= 0 ? charts.MaterialPalette.blue.shadeDefault:charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      ),

      if(payout != null)
        charts.Series<OrdinalSales, String>(
          id: 'payout',
          colorFn: (_, i) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (OrdinalSales sales, _) => sales.year,
          measureFn: (OrdinalSales sales, _) => sales.sales,
          data: payout,
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.0,),
            Text('合計'),
            Radio(
              // title: Text('合計'),
              value: RadioValue.ALL,
              groupValue: _radioValue,
              onChanged: (value) {
                setState(() {
                  _radioValue = value;
                });
              },
            ),
            Text('収支・支出'),
            Radio(
              // title: Text('収支・支出'),
              value: RadioValue.Twice,
              groupValue: _radioValue,
              onChanged: (value){
                setState(() {
                  _radioValue = value;
                });
              },
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SimpleBarChart(
              _radioValue == RadioValue.ALL
                  ?
              _createSampleData(data)
                  :
              _createSampleData(ListPlus,payout: ListMinus),
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
