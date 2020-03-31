import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'create_form.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

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
                  onPressed: null,
                  iconSize:40,
                  icon: Icon(Icons.arrow_left),
                ),
              ),
              Expanded(
                flex:5,
                //アイコン
                child: Text("合計金額"),
              ),
              Expanded(
                flex:1,
                //アイコン
                child: IconButton(
                  onPressed: null,
                  iconSize:40,
                  icon: Icon(Icons.arrow_right),
                  //onPressed: ,
                ),
              ),
            ]),
          ),
          Column(
            children: <Widget>[
              //曜日用に1行作る。
              Row(children: weekList(),),
              //columnlist()で繰り返す。
              Column( children: columnList() )
            ],
          ),
          //メモ（カラムで行を取る）memoList名前変更予定
          Expanded(child: SingleChildScrollView(child: Column( children: memoList() )))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //テーブルに値を入力
          setState(() {
            _save(Calendar(100,'title','title',DateTime.now() ));
          });
        },
      ),
    );
  }

  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
      calendarListFuture.then((calendarList) {

        setState(() {
          this.calendarList = calendarList;
        });
      });
    });
  }

  void _save(Calendar calendar) async {

    int result;
    if (calendar.id != null) {  // Case 1: Update operation
      result = await databaseHelper.updateCalendar(calendar);
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertCalendar(calendar);
    }
    print(result);
  }

//iとjから日程のデータを出す（Date型）
  DateTime calendarDay(i, j) {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month, 1);
    int weekNumber = startDay.weekday;
    DateTime calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + 1, 1);
    DateTime endofmonth = startDay.add(Duration(days: -1));
    final int _endOfMonth = int.parse(endofmonth.day.toString());
    return _endOfMonth;
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

  String plusMoney(){
    String _money;
    if(calendarList.length == 0 ){
      _money = "0円";
    }else{
      _money = "${Utils.commaSeparated(150000)}円";
    }
    return  _money;
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
              color: calendarDay(i, j).month == DateTime.now().month ? Colors.grey[100] : Colors.grey[300],
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
                                child:Text(
                                    "${Utils.commaSeparated(2500)}円",
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
                                    plusMoney(),
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
                              color: calendarDay(i, j).day ==  DateTime.now().day ? Colors.red[500] : Colors.transparent ,
                              child: Text(
                                "${Utils.toInt(calendarDay(i, j).day)}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: calendarDay(i, j).day ==  DateTime.now().day ? Colors.white : Colors.black ,
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
      if (Utils.toInt(calendarDay(6, j).month) > DateTime.now().month ||
          endOfMonth() == Utils.toInt(calendarDay(6, j).day)) {
        break;
      }
    }
    return _list;
  }
  List<Widget> memoList(){

    List<Widget> _list = [];
    for(int i = 0; i < calendarList.length ; i++) {
      if(DateFormat.yMMMd().format(this.calendarList[i].date) == DateFormat.yMMMd().format(selectDay)){
        _list.add(
            Row(children: <Widget>[
              Text( "${this.calendarList[i].title}",
                  style: TextStyle(
                      fontSize: 50
                  )
              ),
              Text( "${this.calendarList[i].money}"),
              Text( "${this.calendarList[i].date}")
            ],
            )
        );
      }

    }
    return _list;
  }
}