import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_store_listing/flutter_store_listing.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
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
 // String selectMonth = DateFormat('yyyy-MM').format(DateTime.now());
  //選択している日
  DateTime selectDay = DateTime.now();
  InfinityPageController _infinityPageController;
  int _initialPage = 0;
  int _scrollIndex = 0;
  Map<String,dynamic> monthMap;
  int yearSum;

  InfinityPageController _infinityPageControllerList;
  int calendarClose = 0;
  int _realIndex= 1000000000;

  bool isLoading = true;

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
    updateListView(selectOfMonth(selectMonthValue));
    updateListViewCategory();
    _infinityPageControllerList = InfinityPageController(initialPage: 0);
    _infinityPageController = InfinityPageController(initialPage: 0);
    monthChange();
    SharedPrefs.setLoginCount(SharedPrefs.getLoginCount()+1);
    if(Platform.isIOS && SharedPrefs.getLoginCount() % 30 == 0){
        FlutterStoreListing().launchRequestReview(onlyNative: true);
    }
    super.initState();
  }

  @override
  void dispose() {
    _infinityPageControllerList.dispose();
    _infinityPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.grey[300],
      child: SafeArea(
        child: Scaffold(
          body: Column(
            //上から合計額、カレンダー、メモ
            children: <Widget>[
              Container(
                height: 40,
                color: Colors.grey[300],
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon:  Icon(calendarClose % 2 == 0 ? Icons.file_upload : Icons.file_download),
                        onPressed: () {
                          calendarClose++;
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Stack(
                        children: <Widget>[
                          isLoading ? Text("") : appbarWidgetsMap()[SharedPrefs.getTapIndex()],
                          InkWell(
                            onTap: ()async{
                              int nextIndex = (_title.indexOf(SharedPrefs.getTapIndex()) +1)%_title.length;
                              await SharedPrefs.setTapIndex(_title[nextIndex]);
                              setState(() {});
                            },
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
                          updateListView(selectOfMonth(selectMonthValue));
                          updateListViewCategory();
                          monthChange();
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
              calendarClose % 2 == 0
              ? Container(
                height:40,
                child: Row(children: <Widget>[
                  Expanded(
                    flex:1,
                    child: IconButton(
                      onPressed: (){
                        setState(() {
                          selectMonthValue--;
                          selectDay = selectOfMonth(selectMonthValue);
                          monthChange();
                        });
                      },
                      iconSize:30,
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
                          monthChange();
                        });
                      },
                      iconSize:30,
                      icon: Icon(Icons.arrow_right),
                    ),
                  ),
                ]),
              )
              :Container(
                height: 40,
                child: InfinityPageView(
                  itemCount: 3,
                  controller: _infinityPageControllerList,
                  itemBuilder: (content, index) {
                    return Container(
                      child: Text(DateFormat("yyyy年MM月dd日").format(selectDay),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    selectDay = selectDay.add(Duration(days: _infinityPageControllerList.realIndex-_realIndex));
                    _realIndex =_infinityPageControllerList.realIndex;
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: InfinityPageView(
                  controller: _infinityPageController,
                  itemCount: 3,
                  itemBuilder: (content, index){
                    return Column(
                          children: <Widget>[
                            //曜日用に1行作る。
                            Row(children: weekList(),),
                            scrollPage(index),
                            (_initialPage == index ) ? Expanded(child: SingleChildScrollView(child: Column( children: memoList() ))) : Container()
                          ],
                        );
                  },
                  onPageChanged: (index) {
                    monthChange();
                    setState(() {});
                    _scrollIndex = 0;
                    scrollValue(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _title =["month","year","both","monthDouble"];

  Map<String,Widget> appbarWidgetsMap(){
    Map<String,Widget> _widgets = {};
    List<String> _string =[
      "月合計：${Utils.commaSeparated(monthMap["SUM"])}${SharedPrefs.getUnit()}",
      "年合計：${Utils.commaSeparated(yearSum)}${SharedPrefs.getUnit()}",
    ];
    for(int i=0;i<2;i++){
      _widgets[_title[i]]=(
          Center(
              child: AutoSizeText(
                _string[i],
                minFontSize: 4,
                maxLines: 1,
                style: TextStyle(fontSize: 25),
              )
          )
      );
    }
    _widgets["both"]=(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text("年合計：",style: TextStyle(fontSize: 12.5),),
              Text("月合計：",style: TextStyle(fontSize: 12.5),)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text("${Utils.commaSeparated(yearSum)}${SharedPrefs.getUnit()}",
                style: TextStyle(fontSize: 12.5),),
              Text("${Utils.commaSeparated(monthMap["SUM"])}${SharedPrefs.getUnit()}",
                  style: TextStyle(fontSize: 12.5)),
            ],
          ),
        ],
      )
    );
    _widgets["monthDouble"]=(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Text("月合計（プラス）　：",style: TextStyle(fontSize: 12.5),),
                Text("月合計（マイナス）：",style: TextStyle(fontSize: 12.5),),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${Utils.commaSeparated(monthMap["PLUS"])}${SharedPrefs.getUnit()}",
                  style: TextStyle(fontSize: 12.5, color: Colors.lightBlueAccent[200]),),
                Text("${Utils.commaSeparated(monthMap["MINUS"])}${SharedPrefs.getUnit()}",
                    style: TextStyle(fontSize: 12.5, color:Colors.redAccent[200])),
              ],
            ),
          ],
        )
    );
    return _widgets;
  }

  Widget scrollPage(index){
    if( (index - _initialPage).abs() == 1) {
      _scrollIndex = (index - _initialPage);
    }else if((index - _initialPage).abs() == 2) {
      _scrollIndex = (((index - _initialPage)/2)*-1).floor();
    }else{
      _scrollIndex = 0;
    }
    return Column( children: dayList() );
    //print(scrollIndex);

  }
  void scrollValue(index){
    if( (index - _initialPage).abs() == 1) {
      selectMonthValue += (index - _initialPage);
    }else if((index - _initialPage).abs() == 2) {
      selectMonthValue += (((index - _initialPage)/2)*-1).floor();
    }
    selectDay = selectOfMonth(selectMonthValue);
    _initialPage = index;
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
    return calendarClose % 2 == 0 ? _list : List<Widget>();
  }
//カレンダーの日付部分（2行目以降）
  List<Widget> dayList() {
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
      if (Utils.toInt(calendarDay(6, j).month) != selectOfMonth(selectMonthValue+_scrollIndex).month ||
          endOfMonth() == Utils.toInt(calendarDay(6, j).day)) {
        break;
      }
    }
    return calendarClose % 2 == 0 ? _list : List<Widget>();
  }
//カレンダー１日のマス（その月以外は空白にする）
  Widget calendarSquare(DateTime date){
    if(date.month == selectOfMonth(selectMonthValue+_scrollIndex).month){
      return Container(
        color: Colors.grey[100],
        height: 50.0,
        child: Stack(
          children: <Widget>[
            Container(
//              height: 100.0,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.white),
                color:  DateFormat.yMMMd().format(selectDay) ==  DateFormat.yMMMd().format(date)  ? Colors.yellow[300] : Colors.transparent ,
              ),
              child: Column(
                  children: squareValue(date)
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
                        color: DateFormat.yMMMd().format(date) == DateFormat.yMMMd().format(DateTime.now()) ? Colors.red[300] : Colors.transparent ,
                        child: AutoSizeText(
                          "${Utils.toInt(date.day)}",
                          textAlign: TextAlign.center,
                          minFontSize: 4,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10.0,
                            color: DateFormat.yMMMd().format(date) ==  DateFormat.yMMMd().format(DateTime.now()) ? Colors.white : Colors.black ,
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
                selectDay = date;
                setState((){});
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
      if(DateFormat.yMMMd().format(calendarList[i].date) == DateFormat.yMMMd().format(selectDay)){
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
                            Text("　${categoryTitle(
                                calendarList[i].categoryId)}${calendarList[i].title}"),
                            Center(
                              child: Text(
                                  "${Utils.commaSeparated(calendarList[i].money)}${SharedPrefs.getUnit()}　",
                                  style: TextStyle(
                                      color: calendarList[i].money >= 0 ? Colors.lightBlueAccent[200] : Colors.redAccent[200]
                                  )
                              ),
                            ),
                          ],
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption: '削除',
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () {
                                _delete(calendarList[i].id);
                                updateListView(selectOfMonth(selectMonthValue));
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
                      return EditForm(selectCalendarList: calendarList[i],inputMode: InputMode.edit,);
                    },
                  ),
                );
                updateListViewCategory();
                updateListView(selectOfMonth(selectMonthValue));
               // monthChange();
              },
            ),
        );
      }
    }
    return _list;
  }
  Future<void> updateListView(month) async{
//全てのDBを取得
    calendarList = await databaseHelper.getCalendarMonthList(month);
    setState(() {});
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    this.categoryList = await databaseHelperCategory.getCategoryListAll();
    setState(() {});
  }
  Future<void> monthChange() async{
    final DateTime _date = DateTime.now();
    var selectMonthDate = DateTime(_date.year, _date.month + selectMonthValue+_scrollIndex, 1);
    monthMap = await databaseHelper.getCalendarMonthInt(selectMonthDate);
    yearSum = await databaseHelper.getCalendarYearInt(selectMonthDate);
    isLoading = false;
    updateListView(selectOfMonth(selectMonthValue));
    setState(() {});
  }

  //１日のマスの中身
 List<Widget> squareValue(date){
    List<Widget> _list = [Expanded(flex: 1, child: Container())];
    for(int i =0; i<2; i++){
      _list.add(
        Expanded(
            flex: 1,
            child: Container(
                child: Align(
                    alignment: Alignment.centerRight,
                    child:AutoSizeText(
                      moneyOfDay(i,date),
                      style: TextStyle(
                          color: i == 0 ? Colors.lightBlueAccent[200]:Colors.redAccent[200]
                      ),
                      minFontSize: 4,
                      maxLines: 1,
                    )
                )
            )
        ),
      );
    }
    return _list;
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
      return   "${Utils.commaSeparated(value == 0 ? _plusMoney : _minusMoney*(-1) )}${SharedPrefs.getUnit()}";
  }
//iとjから日程のデータを出す（Date型）
  DateTime calendarDay(i, j) {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + selectMonthValue+_scrollIndex, 1);
    int weekNumber = startDay.weekday;
    DateTime calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final DateTime _date = DateTime.now();
    var startDay = DateTime(_date.year, _date.month + 1 + selectMonthValue+_scrollIndex, 1);
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
    await databaseHelper.deleteCalendar(id);
  }

}