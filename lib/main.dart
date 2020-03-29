import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/create_form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //以下BottomNavigationBar設定
  int _currentIndex = 0;
  final _pageWidgets = [
    PageWidget(color:Colors.orange, title:'Chat'),
    GraphPage(),
    SettingPage(),
  ];
//メインのページ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text('カレンダー')),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer), title: Text('グラフ')),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text('設定')),
        ],
        currentIndex: _currentIndex,
        fixedColor: Colors.blueAccent,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  void _onItemTapped(int index) => setState(() => _currentIndex = index );
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PageWidget extends StatelessWidget {

  Calendar calendar;
  DatabaseHelper helper = DatabaseHelper();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList;
  int count = 0;

  final Color color;
  final String title;

  PageWidget({Key key, this.color, this.title}) : super(key: key);

  var _week = ["日", "月", "火", "水", "木", "金", "土"];
  var _weekColor = [Colors.red[200],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.blue[200]];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text("タイトル"), actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CreateForm();
                  },
                ),
              );
            },
            tooltip: 'Increment',
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
                child: Text("←"),
              ),
              Expanded(
                flex:5,
                //アイコン
                child: Text("合計金額"),
              ),
              Expanded(
                flex:1,
                //アイコン
                child: Text("→"),
              ),
            ]),
          ),
          Column(
            children: <Widget>[
              //曜日用に1行作る。
              Row(children: WeekList(),),
              //columnlist()で繰り返す。
              Column( children: columnList() )
            ],
          ),
          //メモ（カラムで行を取る）
          Column(

          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //テーブルに値を入力
          calendar = Calendar(100,'title','title',DateFormat.yMMMd().format(DateTime.now()) ) ;
          _save();
        },
      ),
    );
  }

  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
      calendarListFuture.then((calendarList) {

          this.calendarList = calendarList;
          this.count = calendarList.length;

      });
    });
  }

  void _save() async {

    int result;
    if (calendar.id != null) {  // Case 1: Update operation
      result = await helper.updateCalendar(calendar);
    } else { // Case 2: Insert Operation
      result = await helper.insertCalendar(calendar);
    }
    print(calendar.date);
  }
//カンマ区切り
  String CommaSeparated(number){
    final formatter = NumberFormat("#,###");
    var result = formatter.format(number);
    return result;
  }

//int型に変更
  int toInt(vulue) {
    final int _vulue = int.parse(vulue.toString());
    return _vulue;
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
  int EndOfMonth() {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + 1, 1);
    DateTime Endofmonth = startDay.add(Duration(days: -1));
    final int _EndOfMonth = int.parse(Endofmonth.day.toString());
    return _EndOfMonth;
  }
//カレンダーの曜日部分（1行目）
  List<Widget> WeekList() {
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
                                    CommaSeparated(2500),
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
                                    "${CommaSeparated(120000)}円",
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
                                "${toInt(calendarDay(i, j).day)}",
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
                ],
              ),
            ),
          ),
        );
      }
      _list.add(Row(children: _listCache));
      if (toInt(calendarDay(6, j).month) > DateTime.now().month ||
          EndOfMonth() == toInt(calendarDay(6, j).day)) {
        break;
      }
    }
    return _list;
  }
}

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('グラフ'),
      ),
      body: Text('グラフ'),
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Text('設定'),
    );
  }
}

//作成フォーム（削除予定）
class CreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("追加フォーム"),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: "プラス"), Tab(text: "マイナス")],
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Container(
            color: Colors.white,
          ),
        ]),
      ),
    );
  }
}