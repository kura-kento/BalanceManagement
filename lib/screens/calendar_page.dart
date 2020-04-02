import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'create_form.dart';
import 'edit_form.dart';

class CalendarPage extends StatefulWidget {

  CalendarPage({Key key}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();
  //表示月
  int selectMonthValue = 0;
  String selectMonth = DateFormat.yMMMd().format(DateTime.now());
  //選択している日
  DateTime selectDay = DateTime.now();

  var _week = ["日", "月", "火", "水", "木", "金", "土"];
  var _weekColor = [Colors.red[200],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.blue[200]];

  @override
  void initState() {
    updateListView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("タイトル"), actions: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return CreateForm(selectDay: selectDay);
                },
              ),
            );
          },
          //長押しすると表示する。tooltip:
          //tooltip: 'Increment',
          icon: Icon(Icons.add),
        ),
      ]),
      body: Column(
        //上から合計額、カレンダー、メモ
        children: <Widget>[
          Container(
            height:50,
            child: Row(children: <Widget>[
              Expanded(
                flex:1,
                //アイコン
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      selectMonthValue--;
                    });
                  },
                  iconSize:40,
                  icon: Icon(Icons.arrow_left),
                ),
              ),
              Expanded(
                flex:5,
                //アイコン
                child:Align(
                  alignment: Alignment.center,
                  child: Text("${selectOfMonth(selectMonthValue).year}年${selectOfMonth(selectMonthValue).month}月"),
                ),
              ),
              Expanded(
                flex:1,
                //アイコン
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      selectMonthValue++;
                    });
                  },
                  iconSize:40,
                  icon: Icon(Icons.arrow_right),
                ),
              ),
            ]),
          ),
          Column(
            children: <Widget>[
              //曜日用に1行作る。
              Row(children: weekList(),),
              Column( children: columnList() )
            ],
          ),
          //メモ（カラムで行を取る）memoList名前変更予定
          Expanded(child: SingleChildScrollView(child: Column( children: memoList() )))
        ],
      ),
    );
  }

  void updateListView() {
//データベースと接続するパスを取得する（起動時１回のみ処理）
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
//全てのDBを取得
      Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
      calendarListFuture.then((calendarList) {
        setState(() {
          this.calendarList = calendarList;
        });
      });
    });
  }

//iとjから日程のデータを出す（Date型）
  DateTime calendarDay(i, j) {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + selectMonthValue, 1);
    int weekNumber = startDay.weekday;
    DateTime calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + 1 + selectMonthValue, 1);
    DateTime endOfMonth = startDay.add(Duration(days: -1));
    final int _endOfMonth = Utils.toInt(endOfMonth.day);
    return _endOfMonth;
  }
  DateTime selectOfMonth(value) {
    final DateTime _date = DateTime.now();
    var _selectOfMonth = DateTime(_date.year, _date.month + value, 1);
    return  _selectOfMonth;
  }
//カレンダーの曜日部分（1行目）
  List<Widget> weekList() {
    List<Widget> _list = [];
    for (int i = 0; i < 7; i++) {
      _list.add(
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            color: _weekColor[i],
            child: Text(_week[i]),
          ),
        ),
      );
    }
    return _list;
  }
//カレンダー表示している日の合計
  String moneyOfDay(value,i, j) {
    int _plusMoney = 0;
    int _minusMoney = 0;
    for (var index = 0; index < calendarList.length; index++) {
      if (DateFormat.yMMMd().format(calendarList[index].date) == DateFormat.yMMMd().format(calendarDay(i, j))) {
        if (calendarList[index].money > 0) {
          _plusMoney += calendarList[index].money;
        } else {
          _minusMoney += calendarList[index].money;
        }
      }
    }
    return   "${Utils.commaSeparated(value == "plus" ? _plusMoney : _minusMoney*(-1) )}円";

  }
  //カレンダーの日付部分（2行目以降）
  List<Widget> columnList() {
    List<Widget> _list = [];
    for (int j = 0; j < 6; j++) {
      List<Widget> _listCache = [];
      for (int i = 0; i < 7; i++) {
        _listCache.add(
          Expanded(
            flex: 1,
            child: Container(
              color: calendarDay(i, j).month == selectOfMonth(selectMonthValue).month ? Colors.grey[100] : Colors.grey[300],
              height: 50.0,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.white),
                      color:  DateFormat.yMMMd().format(selectDay) ==  DateFormat.yMMMd().format(calendarDay(i, j))  ? Colors.yellow : Colors.transparent ,
                    ),
                    child: Column(
                        children: <Widget>[
                          //ここは空白のデータ
                          Expanded(
                              flex: 1,
                              child: Container(
                                child:Text(""),
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child:AutoSizeText(
                                    moneyOfDay("plus",i, j),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.lightBlueAccent[200]
                                    )
                                ),
                              )
                          ),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child:AutoSizeText(
                                    moneyOfDay("minus",i, j),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.redAccent[200],
                                      //fontSize: 30,
                                    )
                                ),
                              )
                          ),
                        ]
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: DateFormat.yMMMd().format(calendarDay(i, j)) == DateFormat.yMMMd().format(DateTime.now()) ? Colors.red[500] : Colors.transparent ,
                              child: Text(
                                "${Utils.toInt(calendarDay(i, j).day)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: DateFormat.yMMMd().format(calendarDay(i, j)) ==  DateFormat.yMMMd().format(DateTime.now()) ? Colors.white : Colors.black ,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                  //クリック時選択表示する。
                  FlatButton(
                    child: Container(),
                    onPressed: () {
                      setState((){
                        selectDay = calendarDay(i, j);
                        print(calendarDay(i, j));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
      _list.add(Row(children: _listCache));
      //土曜日の月が選択月でない　または、月末の場合は終わる。
      if (Utils.toInt(calendarDay(6, j).month) != selectOfMonth(selectMonthValue).month ||
          endOfMonth() == Utils.toInt(calendarDay(6, j).day)) {
        break;
      }
    }
    return _list;
  }
  //一日のリスト（カレンダー下）
  List<Widget> memoList(){
    List<Widget> _list = [];
    for(int i = 0; i < calendarList.length ; i++) {
      if(DateFormat.yMMMd().format(this.calendarList[i].date) == DateFormat.yMMMd().format(selectDay)){
        _list.add(
            FlatButton(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[200]),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Text( "${this.calendarList[i].title}"),
                        moneyTextColor(i),
                    ],
                    ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EditForm(selectCalendarList: this.calendarList[i]);
                    },
                  ),
                );
              },
            ),
        );
      }
    }
    return _list;
  }
  //＋ーで色を変える。
  Widget moneyTextColor(index){
    if(this.calendarList[index].money >= 0){
      return Text(
          "${this.calendarList[index].money}円",
          style: TextStyle(
              color: Colors.lightBlueAccent[200]
          )
      );
    }else{
      return Text(
          "${this.calendarList[index].money}円",
          style: TextStyle(
              color: Colors.redAccent[200]
          )
      );
    }

  }
}