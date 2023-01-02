import 'dart:async';
import 'dart:io';
import 'package:app_review/app_review.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/models/calendar.dart';
import 'package:balancemanagement_app/models/category.dart';
import 'package:balancemanagement_app/utils/app.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/datebase_help_category.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:intl/intl.dart';
import 'edit_form.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key key}) : super(key: key);
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = <Calendar>[];

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = <Category>[];

  //表示月
  int selectMonthValue = 0;
  final DateTime _today = DateTime.now();
  //選択している日
  DateTime selectDay = DateTime.now();
  InfinityPageController _infinityPageController;
  int _initialPage = 0;
  int _scrollIndex = 0;
  Map<String,dynamic> monthMap;
  int yearSum;
  Map<String,dynamic> yearMap;

  InfinityPageController _infinityPageControllerList;
  int calendarClose = 0;
  int _realIndex= 1000000000;

  bool isLoading = true;

  List<String> _week = ['日', '月', '火', '水', '木', '金', '土'];
  final _weekColor = [Colors.red[200],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.grey[300],
    Colors.blue[200]];

  @override
  void initState() {
    // tracking();
    updateListViewCategory();
    _infinityPageControllerList = InfinityPageController(initialPage: 0);
    _infinityPageController = InfinityPageController(initialPage: 0);
    dataUpdate();
    super.initState();
  }

  @override
  void dispose() {
    _infinityPageControllerList.dispose();
    _infinityPageController.dispose();
    super.dispose();
  }

  // Future<void> tracking() async {
  //   await Admob.requestTrackingAuthorization();
  // }

  void reviewCount() {
    print(SharedPrefs.getLoginCount());
    SharedPrefs.setLoginCount(SharedPrefs.getLoginCount()+1);

    if (Platform.isIOS && SharedPrefs.getLoginCount() % 10 == 0) {
      AppReview.requestReview.then((onValue) {
        print(onValue);
      });
    }else if (Platform.isAndroid && SharedPrefs.getLoginCount() % 20 == 0){
      AppReview.requestReview.then((onValue) {
        print(onValue);
        // showDialog(
        //   context: context,
        //   builder: (_) {
        //     return AlertDialog(
        //       title: Text("このアプリは満足していますか？"),
        //       // content: Text("このアプリは満足していますか？"),
        //       actions: <Widget>[
        //         // ボタン領域
        //         FlatButton(
        //           child: Text("いいえ"),
        //           onPressed: () {
        //             Navigator.pop(context);
        //           },
        //         ),
        //         FlatButton(
        //           child: Text("はい"),
        //           onPressed: () {
        //             Navigator.pop(context);
        //             print(onValue);
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     _week = [AppLocalizations.of(context).sunday,
             AppLocalizations.of(context).monday,
             AppLocalizations.of(context).tuesday,
             AppLocalizations.of(context).wednesday,
             AppLocalizations.of(context).thursday,
             AppLocalizations.of(context).friday,
             AppLocalizations.of(context).saturday];

    return Column(
      children: [
        Expanded(
          child: Container(
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
                              icon:  Icon(calendarClose.isEven ? Icons.file_upload : Icons.file_download),
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
                                if(!isLoading) appbarWidgetsMap()[SharedPrefs.getTapIndex()],
                                InkWell(
                                  onTap: ()async{
                                    final nextIndex = (_title.indexOf(SharedPrefs.getTapIndex()) +1)%_title.length;
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
                                updateListViewCategory();
                                dataUpdate();
                                reviewCount();
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                    calendarClose.isEven
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
                                print(selectMonthValue);
                                print(selectDay);
                                dataUpdate();
                              });
                            },
                            iconSize:30,
                            icon: const Icon(Icons.arrow_left),
                          ),
                        ),
                        Expanded(
                          flex:5,
                          //アイコン
                          child:Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                                  DateFormat.yMMM(Localizations.localeOf(context).languageCode == 'ja' ? 'ja_JP': 'en_JP').format(selectOfMonth(selectMonthValue)),
                                  style: const TextStyle(
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
                                print(selectMonthValue);
                                print(selectDay);
                                dataUpdate();
                              });
                            },
                            iconSize:30,
                            icon: const Icon(Icons.arrow_right),
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
                            child: Text(DateFormat(Localizations.localeOf(context).languageCode == 'ja' ? 'yyyy年MM月dd日': 'MMM d, yyyy').format(selectDay),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 30
                              ),
                            ),
                          );
                        },
                        onPageChanged: (index) {
                          selectDay = selectDay.add(Duration(days: _infinityPageControllerList.realIndex - _realIndex));
                          _realIndex = _infinityPageControllerList.realIndex;
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
                                if (_initialPage == index) Expanded(child: SingleChildScrollView(child: Column( children: memoList() ))) else Container()
                              ],
                            );
                        },
                        onPageChanged: (index) {
                          dataUpdate();
                          _scrollIndex = 0;
                          scrollValue(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // SharedPrefs.getAdPositionTop()
        //     ? Container()
        //     : AdMob.adContainer(myBanner2),
      ],
    );
  }

  final List<String> _title =['month','year','both','monthDouble', 'yearDouble'];

  Map<String,Widget> appbarWidgetsMap(){
    final _widgets = <String,Widget>{};
    final _string = <String>[
      "${AppLocalizations.of(context).monthlyTotal}：${Utils.commaSeparated(monthMap["SUM"])}${SharedPrefs.getUnit()}",
      '${AppLocalizations.of(context).annualTotal}：${Utils.commaSeparated(yearSum)}${SharedPrefs.getUnit()}',
    ];
    for(var i=0;i<2;i++){
      _widgets[_title[i]]=(
        Center(
          child: AutoSizeText(
            _string[i],
            minFontSize: 4,
            maxLines: 1,
            style: const TextStyle(fontSize: 25),
          )
        )
      );
    }
    _widgets['both']=(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text('${AppLocalizations.of(context).annualTotal}：',style: const TextStyle(fontSize: 12.5),),
              Text('${AppLocalizations.of(context).monthlyTotal}：',style: const TextStyle(fontSize: 12.5),)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('${Utils.commaSeparated(yearSum)}${SharedPrefs.getUnit()}',
                style: const TextStyle(fontSize: 12.5),),
              Text("${Utils.commaSeparated(monthMap["SUM"])}${SharedPrefs.getUnit()}",
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ],
      )
    );
    _widgets['monthDouble']=(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Text('${AppLocalizations.of(context).monthlyTotalPlus}：',style: const TextStyle(fontSize: 12.5)),
                Text('${AppLocalizations.of(context).monthlyTotalMinus}：',style: const TextStyle(fontSize: 12.5)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${Utils.commaSeparated(monthMap["PLUS"])}${SharedPrefs.getUnit()}",
                  style: TextStyle(fontSize: 12.5, color: App.plusColor),),
                Text("${Utils.commaSeparated(monthMap["MINUS"])}${SharedPrefs.getUnit()}",
                    style: TextStyle(fontSize: 12.5, color: App.minusColor)),
              ],
            ),
          ],
        )
    );

    _widgets['yearDouble']=(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Text('${AppLocalizations.of(context).annualTotal}：',style: const TextStyle(fontSize: 12.5)),
                Text('${AppLocalizations.of(context).annualTotal}：',style: const TextStyle(fontSize: 12.5)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text("${Utils.commaSeparated(yearMap["PLUS"])}${SharedPrefs.getUnit()}",
                  style: TextStyle(fontSize: 12.5, color: App.plusColor),),
                Text("${Utils.commaSeparated(yearMap["MINUS"])}${SharedPrefs.getUnit()}",
                    style: TextStyle(fontSize: 12.5, color:App.minusColor)),
              ],
            ),
          ],
        )
    );
    return _widgets;
  }

  Widget scrollPage(int index){
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
  void scrollValue(int index){
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
    final _list = <Widget>[];
    for (var i = 0; i < 7; i++) {
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
    return calendarClose.isEven ? _list : <Widget>[];
  }
//カレンダーの日付部分（2行目以降）
  List<Widget> dayList() {
    final _list = <Widget>[];
    for (var j = 0; j < 6; j++) {
      final _listCache = <Widget>[];
      for (var i = 0; i < 7; i++) {
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
    return calendarClose.isEven ? _list : <Widget>[];
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
              padding: const EdgeInsets.all(2.0),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 46/3,
                      color: DateFormat.yMMMd().format(date) == DateFormat.yMMMd().format(_today) ? Colors.red[300] : Colors.transparent ,
                      child: Center(
                        child: Text(
                          '${Utils.toInt(date.day)}',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: Utils.parseSize(context, 10.0),
                            color: DateFormat.yMMMd().format(date) ==  DateFormat.yMMMd().format(_today) ? Colors.white : Colors.black87 ,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 3,)
                ],
              ),
            ),
            //クリック時選択表示する。
            TextButton(
              child: Container(),
              onPressed: () async{
                if(selectDay == date) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return EditForm(selectDay: selectDay,inputMode: InputMode.create);
                      },
                    ),
                  );
                  updateListViewCategory();
                  dataUpdate();
                  reviewCount();
                }else{
                  selectDay = date;
                  setState((){});
                }
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
    final _list = <Widget>[];
    for(var i = 0; i < calendarList.length ; i++) {
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
                      //TODO: actionPane: const SlidableDrawerActionPane(),
                      //TODO: actionExtentRatio: 0.15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('　${categoryTitle(
                                calendarList[i].categoryId)}${calendarList[i].title}'),
                            Center(
                              child: Text(
                                  '${Utils.commaSeparated(calendarList[i].money)}${SharedPrefs.getUnit()}　',
                                  style: TextStyle(
                                      color: calendarList[i].money >= 0 ? App.plusColor : App.minusColor
                                  )
                              ),
                            ),
                          ],
                        ),
                  // TODO:      secondaryActions: <Widget>[
                  //         IconSlideAction(
                  //             caption: '削除',
                  //             color: Colors.red,
                  //             icon: Icons.delete,
                  //             onTap: () {
                  //               _delete(calendarList[i].id);
                  //               dataUpdate();
                  //             }
                  //          )
                  // ]
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
                dataUpdate();
              },
            ),
        );
      }
    }
    return _list;
  }
  Future<void> updateListView(DateTime month) async {
//全てのDBを取得
    calendarList = await databaseHelper.getCalendarMonthList(month);
    setState(() {});
  }

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    this.categoryList = await databaseHelperCategory.getCategoryListAll();
    setState(() {});
  }
  Future<void> dataUpdate() async{
    final selectMonthDate = DateTime(_today.year, _today.month + selectMonthValue+_scrollIndex, 1);
    monthMap = await databaseHelper.getCalendarMonthInt(selectMonthDate);
    yearSum = await databaseHelper.getCalendarYearInt(selectMonthDate);
    yearMap = await databaseHelper.getCalendarYearMap(selectMonthDate);
    isLoading = false;
    updateListView(selectOfMonth(selectMonthValue));
    print(selectMonthDate);
    print(monthMap);
    setState(() {});
  }

  //１日のマスの中身
 List<Widget> squareValue(DateTime date){
    final _list = <Widget>[Expanded(flex: 1, child: Container())];
    for(var i =0; i<2; i++){
      _list.add(
        Expanded(
            flex: 1,
            child: Container(
                child: Align(
                    alignment: Alignment.centerRight,
                    child:AutoSizeText(
                      moneyOfDay(i,date),
                      style: TextStyle(
                          color: i == 0 ? App.plusColor:App.minusColor
                      ),
                      minFontSize: 3,
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
  String moneyOfDay(int value,DateTime date) {
    var _plusMoney = 0;
    var _minusMoney = 0;
    for (var index = 0; index < calendarList.length; index++) {
      if (DateFormat.yMMMd().format(calendarList[index].date) == DateFormat.yMMMd().format(date)) {
        if (calendarList[index].money > 0) {
          _plusMoney += calendarList[index].money;
        } else {
          _minusMoney += calendarList[index].money;
        }
      }
    }
      return   '${Utils.commaSeparated(value == 0 ? _plusMoney : _minusMoney*(-1) )}${SharedPrefs.getUnit()}';
  }
//iとjから日程のデータを出す（Date型）
  DateTime calendarDay(int i,int j) {
    final startDay = DateTime(_today.year, _today.month + selectMonthValue+_scrollIndex, 1);
    final weekNumber = startDay.weekday;
    final calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final startDay = DateTime(_today.year, _today.month + 1 + selectMonthValue+_scrollIndex, 1);
    final endOfMonth = startDay.add(const Duration(days: -1));
    final _endOfMonth = Utils.toInt(endOfMonth.day);
    return _endOfMonth;
  }
//選択中の月をdate型で出す。
  DateTime selectOfMonth(int value) {
    final _selectOfMonth = DateTime(_today.year, _today.month + value, 1);
    return  _selectOfMonth;
  }

  String categoryTitle(int id){
    String _title;
    if(id == 0){
      _title = '';
    }else{
      for(var i=0;i < categoryList.length;i++){
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