import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../chart.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  final List<ChartData> _debugChartList = [
    ChartData("4/15", 60.0),
  ];

  @override
  void initState(){
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(textCalendar().toString(), style: TextStyle(color: Colors.black),),
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 300,
                      margin: EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ChartContainer(_debugChartList, "合計値")
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }

  void updateListView() {
//全てのDBを取得
    Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
    calendarListFuture.then((calendarList) {
      setState(() {
        this.calendarList = calendarList;
      });
    });
  }
  int textCalendar(){
    int _moneySum =0;
    for(int i = 0; i < calendarList.length; i++){
      if(i==0) {
        _moneySum += calendarList[i].money;
      }
    }
    return _moneySum;
  }

}