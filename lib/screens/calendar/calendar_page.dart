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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'daySquare.dart';
import 'edit_form.dart';

final selectDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final addMonthProvider = StateProvider<int>((ref) => 0);

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({Key key}) : super(key: key);
  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends ConsumerState<CalendarPage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Calendar> calendarList = <Calendar>[];

  DatabaseHelperCategory databaseHelperCategory = DatabaseHelperCategory();
  List<Category> categoryList = <Category>[];

  //表示月
  int selectMonthValue = 0;
  final DateTime _today = DateTime.now();
  //選択している日
  DateTime selectDay;
  int addMonth;

  Map<String,dynamic> monthMap;
  var yearSum;
  Map<String,dynamic> yearMap;

  int calendarClose = 1;
  bool isLoading = true;

  PageController pageController = PageController(initialPage: App.infinityPage);

  @override
  void initState() {
    // tracking();
    updateListViewCategory();
    dataUpdate();
    super.initState();
  }

  @override
  void dispose() {
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
    selectDay = ref.watch(selectDayProvider);
    addMonth = ref.watch(addMonthProvider);

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
                                      return EditForm(calendarId: null,inputMode: InputMode.create);
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
                    Container(
                      height:40,
                      child: Row(children: <Widget>[
                        Expanded(
                          flex:1,
                          child: IconButton(
                            onPressed: (){
                              setState(() {
                                pageController.animateToPage(
                                  App.infinityPage + addMonth - 1, // 変更したいページのインデックス
                                  duration: const Duration(milliseconds: 300), // アニメーションの時間
                                  curve: Curves.ease, // アニメーションのカーブ
                                );
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
                                pageController.animateToPage(
                                  App.infinityPage + addMonth + 1, // 変更したいページのインデックス
                                  duration: const Duration(milliseconds: 300), // アニメーションの時間
                                  curve: Curves.ease, // アニメーションのカーブ
                                );
                              });
                            },
                            iconSize:30,
                            icon: const Icon(Icons.arrow_right),
                          ),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: (index) { //引数では移動先のインデックスを受け取る
                          ref.read(addMonthProvider.notifier).state = index - App.infinityPage;
                          ref.read(selectDayProvider.notifier).state = selectOfMonth(index - App.infinityPage);
                        },
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              DaySquare(),
                              dishesWidget(),
                            ],
                          ); // 日付ごとの四角の枠;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  Future<void> updateListViewCategory() async{
//収支どちらか全てのDBを取得
    this.categoryList = await databaseHelperCategory.getCategoryListAll();
    setState(() {});
  }
  Future<void> dataUpdate() async {
    final selectMonthDate = DateTime(_today.year, _today.month + selectMonthValue+addMonth, 1);
    monthMap = await databaseHelper.getCalendarMonthInt(selectMonthDate);
    yearSum = await databaseHelper.getCalendarYearDouble(selectMonthDate);
    yearMap = await databaseHelper.getCalendarYearMap(selectMonthDate);
    isLoading = false;
    setState(() {});
  }

  // カレンダー下の料理リスト
  Widget dishesWidget()  {
    return FutureBuilder(
        future: DatabaseHelper().selectDayList(selectDay), // Future<T> 型を返す非同期処理
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var  calendarData = snapshot.data;
            return Expanded(
              child: ListView.builder(
                  itemCount: calendarData.length,
                  itemBuilder: (itemBuilder, index) {
                    return Slidable(
                      endActionPane:  ActionPane(
                        extentRatio: 1/5,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              // dishDelete(calendarData[index]['id']);
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                        ],
                      ),
                      child: InkWell(
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1, color: Colors.black26),),),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(calendarData[index]['title'] ?? ''),
                              Text('${Utils.formatNumber(calendarData[index]['money'] ?? 0)}円'),
                            ],
                          ),
                        ),
                        onTap: () async {
                          //TODO:
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return EditForm(calendarId: calendarData[index]['id'],inputMode: InputMode.edit,);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

//iとjから日程のデータを出す（Date型）
  DateTime calendarDay(int i,int j) {
    final startDay = DateTime(_today.year, _today.month + selectMonthValue+addMonth, 1);
    final weekNumber = startDay.weekday;
    final calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final startDay = DateTime(_today.year, _today.month + 1 + selectMonthValue+addMonth, 1);
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