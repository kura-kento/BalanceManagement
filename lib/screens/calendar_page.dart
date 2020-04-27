import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'edit_form.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = List<Calendar>();

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = List<Category>();

  //表示月
  int selectMonthValue = 0;
  String selectMonth = DateFormat.yMMMd().format(DateTime.now());
  //選択している日
  DateTime selectDay = DateTime.now();

 // InfinityPageController _infinityPageController;
  int _initialPage = 0;
  int _scrollIndex = 0;

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
    updateListViewCategory();
    //_infinityPageController = InfinityPageController(initialPage: 0);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: <Widget>[
              expandedNull(1),
              Expanded(
                flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("合計(年)："),
                          Text("合計(月)：")
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text("${Utils.commaSeparated(yearSum())}${SharedPrefs.getUnit()}"),
                            Text("${Utils.commaSeparated(monthSum())}${SharedPrefs.getUnit()}"),
                          ],
                        ),
                      ),
                    ],
                  ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: ()async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EditForm(selectDay: selectDay,inputMode: InputMode.create);
                        },
                      ),
                    );
                    updateListView();
                    updateListViewCategory();
                  },
                  icon: Icon(Icons.add),
                ),
              ),
            ],
          ),
      ),
      body: Column(
        //上から合計額、カレンダー、メモ
        children: <Widget>[
          Container(
            height:50,
            child: Row(children: <Widget>[
              Expanded(
                flex:1,
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      selectMonthValue--;
                      selectDay = selectOfMonth(selectMonthValue);
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
                  child: AutoSizeText(
                        DateFormat.yMMM("ja_JP").format(selectOfMonth(selectMonthValue)),
                        style: TextStyle(
                          fontSize: 30
                        ),
                    ),

                ),
              ),
              Expanded(
                flex:1,
                //アイコン
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      selectMonthValue++;
                      selectDay = selectOfMonth(selectMonthValue);
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
           SingleChildScrollView(child: Column( children: memoList() ))
        ],
      ),
    );
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
//カレンダーの日付部分（2行目以降）
  List<Widget> columnList() {
    List<Widget> _list = [];
    for (int j = 0; j < 6; j++) {
      List<Widget> _listCache = [];
      for (int i = 0; i < 7; i++) {
        _listCache.add(
          Expanded(
            flex: 1,
            child: calendarSquare(calendarDay(i, j)),
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
//カレンダー１日のマス（その月以外は空白にする）
  Widget calendarSquare(DateTime date){
    if(date.month == selectOfMonth(selectMonthValue).month){
      return Container(
        color: Colors.grey[100],
        height: 50.0,
        child: Stack(
          children: <Widget>[
            Container(
              height: 100.0,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.white),
                color:  DateFormat.yMMMd().format(selectDay) ==  DateFormat.yMMMd().format(date)  ? Colors.yellow[300] : Colors.transparent ,
              ),
              child: Column(
                  children: <Widget>[
                    //ここは空白のデータ
                    expandedNull(1),
                    Expanded(
                        flex: 1,
                        child: Container(
                            child: Align(
                                alignment: Alignment.centerRight,
                                child:AutoSizeText(
                                    moneyOfDay("plus",date),
                                    style: TextStyle(
                                      color: Colors.lightBlueAccent[200]
                                    ),
                                    minFontSize: 4,
                                    maxLines: 1,
                                )
                            )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child:AutoSizeText(
                                  moneyOfDay("minus",date),
                                  minFontSize: 4,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.redAccent[200],
                                  )
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
                      flex: 2,
                      child: Container(
                        color: DateFormat.yMMMd().format(date) == DateFormat.yMMMd().format(DateTime.now()) ? Colors.red[300] : Colors.transparent ,
                        child: Text(
                          "${Utils.toInt(date.day)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: DateFormat.yMMMd().format(date) ==  DateFormat.yMMMd().format(DateTime.now()) ? Colors.white : Colors.black ,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                      flex: 5,
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
                  selectDay = date;
                  print(date);
                });
              },
            ),
          ],
        ),
      );
    }else{
      return Container(
          color: Colors.grey[200],
          height: 50.0,
      );
    }
  }
  //一日のリスト（カレンダー下）
  List<Widget> memoList(){
    List<Widget> _list = [];
    for(int i = 0; i < calendarList.length ; i++) {
      if(DateFormat.yMMMd().format(this.calendarList[i].date) == DateFormat.yMMMd().format(selectDay)){
        _list.add(
            InkWell(
              child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:BorderSide(width: 1, color: Colors.grey[200]),
                    ),
                    ),
                    child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                        Text( "　${categoryTitle(this.calendarList[i].categoryId)}${this.calendarList[i].title}"),
                          moneyTextColor(i),
                      ],
                      ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption: '削除',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                _delete(calendarList[i].id);
                                updateListView();
                                setState(() {});
                              }
                    )
                  ]
                    ),

              ),
              onTap: () async{
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return EditForm(selectCalendarList: this.calendarList[i],inputMode: InputMode.edit,);
                    },
                  ),
                );
                updateListView();
                updateListViewCategory();
              },
            ),
        );
      }
    }
    return _list;
  }
  void updateListView() {
//全てのDBを取得
      Future<List<Calendar>> calendarListFuture = databaseHelper.getCalendarList();
      calendarListFuture.then((calendarList) {
          this.calendarList = calendarList;
          setState(() {});
      });
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    List<Category> _categoryList = await databaseHelperCategory.getCategoryListAll();
    this.categoryList = _categoryList;
    setState(() {});
  }

//カレンダーの月合計
  int monthSum(){
    int _moneySum =0;
    for(int i = 0; i < calendarList.length; i++){
      if(selectOfMonth(selectMonthValue).month == calendarList[i].date.month &&
          selectOfMonth(selectMonthValue).year == calendarList[i].date.year){
        _moneySum += calendarList[i].money;
      }
    }
    return _moneySum;
  }
//カレンダーの年合計
  int yearSum(){
    int _moneySum =0;
    for(int i = 0; i < calendarList.length; i++){
      if(selectOfMonth(selectMonthValue).year == calendarList[i].date.year){
        _moneySum += calendarList[i].money;
      }
    }
    return _moneySum;
  }
//カレンダー表示している日の合計
  String moneyOfDay(value,date) {
    int _plusMoney = 0;
    int _minusMoney = 0;
    for (var index = 0; index < calendarList.length; index++) {
      if (DateFormat.yMMMd().format(calendarList[index].date) == DateFormat.yMMMd().format(date)) {
        if (calendarList[index].money > 0) {
          _plusMoney += calendarList[index].money;
        } else {
          _minusMoney += calendarList[index].money;
        }
      }
    }
    return   "${Utils.commaSeparated(value == "plus" ? _plusMoney : _minusMoney*(-1) )}${SharedPrefs.getUnit()}";
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
//選択中の月をdate型で出す。
  DateTime selectOfMonth(value) {
    final DateTime _date = DateTime.now();
    var _selectOfMonth = DateTime(_date.year, _date.month + value, 1);
    return  _selectOfMonth;
  }
  //＋ーで色を変える。
  Widget moneyTextColor(index){
      return Center(
        child: Text(
            "${Utils.commaSeparated(this.calendarList[index].money)}${SharedPrefs.getUnit()}　",
            style: TextStyle(
                color: this.calendarList[index].money >= 0 ? Colors.lightBlueAccent[200]:Colors.redAccent[200]
            )
        ),
      );
  }
  //空白
  Widget expandedNull(value){
    return Expanded(
        flex: value,
        child:Container(
          child:Text(""),
        )
    );
  }
  String categoryTitle(id){
    String _title;
    if(id == 0){
      _title = "";
    }else{
      for(int i=0;i < categoryList.length;i++){
        if(categoryList[i].id == id){
          _title = categoryList[i].title;
        }
      }
    }
    return _title;
  }

  Future <void> _delete(int id) async{
    int result;
    result = await databaseHelper.deleteCalendar(id);
    print(result);
  }

}