import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../chart.dart';

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  List<ChartData> _debugChartList = [
    ChartData(DateFormat("M月").format(DateTime.now()), 100.0,DateFormat("yyyy年").format(DateTime.now()),"0"),
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
        title: Text("グラフ", style: TextStyle(color: Colors.black),),
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 320,
                      margin: EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ChartContainer(_debugChartList, "合計値：月")
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }

  Future<void> updateListView() async{
//全てのDBを取得
    List<Calendar> _calendarList = await databaseHelper.getCalendarList();
    this.calendarList = _calendarList;
    if(this.calendarList.length!=0){
      _debugChartList = mapToList();
    }
    setState(() {});
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
//
  Map<DateTime, int> graphMonth(){
    Map<DateTime, int> map = {};

    DateTime _date;
    for(var i = 0; i < calendarList.length; i++){
      _date = calendarList[i].date;

      if( map.containsKey(DateTime(_date.year,_date.month)) ){
        map[DateTime(_date.year,_date.month)] += calendarList[i].money;
    }else{
        map.addAll({DateTime(_date.year,_date.month) : calendarList[i].money});
      }
    }

    return map;
  }
  List<ChartData> mapToList(){
    List<ChartData> _list = List<ChartData>();
    List<DateTime> _listCache = List<DateTime>();
    Map<DateTime,int> _map = graphMonth();

    _map.forEach((DateTime key,int value){
      print(value);
      _listCache.add(key);
    });

    _listCache.sort((a,b){
      return a.difference(b).inDays;
    });

    int durationMonth ;
    if(DateTime.now().year == _listCache[0].year){
      durationMonth = DateTime.now().month - _listCache[0].month;
    }else{
      durationMonth = DateTime.now().month +12*(DateTime.now().year - _listCache[0].year) -_listCache[0].month;
    }
    print(_listCache[0].month);
    for(int i=0;i <= durationMonth;i++){
      if(_map.containsKey(DateTime(_listCache[0].year,_listCache[0].month + i))){
        //または１月がない時
        if((_listCache[0].month+i)%12 == 1){
          _list.add(ChartData(DateFormat("M月").format(DateTime(_listCache[0].year,_listCache[0].month + i)),
              _map[DateTime(_listCache[0].year,_listCache[0].month + i)].toDouble(),
                 DateFormat("yyyy年").format(DateTime(_listCache[0].year,_listCache[0].month + i)),
                "${_map[DateTime(_listCache[0].year,_listCache[0].month + i)]}"
          ));
        }else{
          _list.add(ChartData(DateFormat("M月").format(DateTime(_listCache[0].year,_listCache[0].month + i)),_map[DateTime(_listCache[0].year,_listCache[0].month + i)].toDouble(),"",
              "${_map[DateTime(_listCache[0].year,_listCache[0].month + i)]}"
                   ));
        }
      }else{
        if((_listCache[0].month+i)%12 == 1){
          _list.add(ChartData(DateFormat("M月").format(DateTime(_listCache[0].year,_listCache[0].month + i)),0.0,
              DateFormat("yyyy年").format(DateTime(_listCache[0].year,_listCache[0].month + i)),
              "0"
          ));
        }
        _list.add(ChartData(DateFormat("M月").format(DateTime(_listCache[0].year,_listCache[0].month + i)),0.0,"","0"));
      }
    }
    return _list;
  }
}

//FutureBuilder