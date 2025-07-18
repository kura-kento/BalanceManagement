import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:balancemanagement_app/i18n/message.dart';
import 'package:balancemanagement_app/View/calendar/week.dart';
import 'package:balancemanagement_app/Common/app.dart';
import 'package:balancemanagement_app/models/DB/database_help.dart';
import 'package:balancemanagement_app/Common/shared_prefs.dart';
import 'package:balancemanagement_app/Common/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../Common/Widget/drawer.dart';
import '../../Common/Widget/previewDialog.dart';
import '../../models/calendar.dart';
import 'daySquare.dart';
import 'edit_form.dart';

final selectDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final addMonthProvider = StateProvider<int>((ref) => 0);

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);
  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends ConsumerState<CalendarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DateTime _today = DateTime.now();
  //選択している日
  late DateTime selectDay;
  late int addMonth;
  bool isLoading = true;

  PageController pageController = PageController(initialPage: App.infinityPage);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 親要素を更新するfunction
  void _setStateFunction(String input) {
    if (mounted) {
      setState(() {
        // 状態更新
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    selectDay = ref.watch(selectDayProvider);
    addMonth = ref.watch(addMonthProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerWidget(),
      body: Column(
        //上から合計額、カレンダー、メモ
        children: <Widget>[
          Container(
            height: 55,
            color: App.bgColor,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 50,
                    child: IconButton(
                      onPressed: () {_scaffoldKey.currentState?.openDrawer();},
                      icon: Icon(Icons.note_alt_outlined, size: 32,),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: sumPriceWidget(),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.add, size: 32),
                    onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return EditForm(calendar: null, inputMode: InputMode.create, parentFn:_setStateFunction);
                            },
                          ),
                        );

                        Future.delayed(const Duration(microseconds: 1000), () {
                          PreviewDialog.reviewCount(context); //レビューカウント
                        });
                        // setState(() {});
                      },
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: App.isSmall(context) ? 40 : 50,
            child: Row(children: <Widget>[
              Expanded(
                flex:1,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      pageController.animateToPage(
                        App.infinityPage + addMonth - 1, // 変更したいページのインデックス
                        duration: const Duration(milliseconds: 300), // アニメーションの時間
                        curve: Curves.ease, // アニメーションのカーブ
                      );
                    });
                  },
                  iconSize: App.isSmall(context) ? 30 : 40,
                  icon: const Icon(Icons.arrow_left),
                ),
              ),
              Expanded(
                flex:5,
                //アイコン
                child:Align(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                        DateFormat.yMMM(Localizations.localeOf(context).languageCode == 'ja' ? 'ja_JP': 'en_JP').format(selectOfMonth(addMonth)),
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
                  onPressed: () {
                    setState(() {
                      pageController.animateToPage(
                        App.infinityPage + addMonth + 1, // 変更したいページのインデックス
                        duration: const Duration(milliseconds: 300), // アニメーションの時間
                        curve: Curves.ease, // アニメーションのカーブ
                      );
                    });
                  },
                  iconSize: App.isSmall(context) ? 30 : 40,
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
                    Week(),
                    DaySquare(parentFn: _setStateFunction,),
                    calendarBottomList(),
                  ],
                ); // 日付ごとの四角の枠;
              },
            ),
          ),
        ],
      ),
    );
  }

  // カレンダー下のリスト
  Widget calendarBottomList()  {
    return FutureBuilder(
        future: DatabaseHelper().selectDayList(selectDay), // Future<T> 型を返す非同期処理
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var  calendarList = snapshot.data;
            return Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (itemBuilder, index) {
                    Calendar _calendar = calendarList[index]['calendar'];
                    String full_name = calendarList[index]['full_name'];
                    return Slidable(
                      endActionPane:  ActionPane(
                        extentRatio: 1/5,
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              _delete(_calendar.id ?? 0);
                              _setStateFunction('削除に成功しました');
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                        ],
                      ),
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          height: App.isSmall(context) ? 40 : 50,
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(width: 0.8, color: Colors.black12),),),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(full_name ?? ''),
                              Text(
                                '${Utils.commaSeparated(_calendar.money ?? 0)}${SharedPrefs.getUnit()}',
                                style: TextStyle(color: (_calendar.money ?? 0) >= 0 ? App.plusColor : App.minusColor),
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return EditForm(calendar: _calendar, inputMode: InputMode.edit, parentFn: _setStateFunction,);
                              },
                            ),
                          );
                          Future.delayed(const Duration(microseconds: 1000), () {
                            PreviewDialog.reviewCount(context); //レビューカウント
                          });
                          if (mounted) { setState(() {});}
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
    final startDay = DateTime(_today.year, _today.month + addMonth, 1);
    final weekNumber = startDay.weekday;
    final calendarStartDay =
    startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
    return calendarStartDay;
  }
//月末の日を取得（来月の１日を取得して１引く）
  int endOfMonth() {
    final startDay = DateTime(_today.year, _today.month + 1 + addMonth, 1);
    final endOfMonth = startDay.add(const Duration(days: -1));
    final _endOfMonth = Utils.toInt(endOfMonth.day);
    return _endOfMonth;
  }
//選択中の月をdate型で出す。
  DateTime selectOfMonth(int value) {
    final _selectOfMonth = DateTime(_today.year, _today.month + value, 1);
    return  _selectOfMonth;
  }

  Future <void> _delete(int id) async {
    await DatabaseHelper().deleteCalendar(id);
  }

  //
  Widget sumPriceWidget() {
    int tapCount = (SharedPrefs.getTapInt() % ['both','monthDouble', 'yearDouble'].length);
    var list = [];
    var title = [];
    switch(tapCount) {
      case 0:
        title = [AppLocalizations.of(context).monthlyTotal,AppLocalizations.of(context).annualTotal];
        list = ['MonthSUM','YearSUM'];
        break;
      case 1:
        title = [AppLocalizations.of(context).monthlyTotal,AppLocalizations.of(context).monthlyTotal];
        list = ['MonthPULS','MonthNINUS'];
        break;
      case 2:
        title = [AppLocalizations.of(context).annualTotal,AppLocalizations.of(context).annualTotal];
        list = ['YearPULS','YearNINUS'];
        break;
    }

    return FutureBuilder(
        future: DatabaseHelper().sumData(selectDay), // Future<T> 型を返す非同期処理
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            var  calendarData = snapshot.data;
            return InkWell(
              onTap: () {
                SharedPrefs.setTapInt(SharedPrefs.getTapInt() + 1);
                setState(() {});
             },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('${title[0]}：',style: const TextStyle(fontSize: 12.5)),
                      Text('${title[1]}：',style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("${Utils.commaSeparated(calendarData[list[0]])}${SharedPrefs.getUnit()}",
                        style: TextStyle(fontSize: 12.5, color: tapCount == 0 ? Colors.black87 : App.plusColor),),
                      Text("${Utils.commaSeparated(calendarData[list[1]])}${SharedPrefs.getUnit()}",
                          style: TextStyle(fontSize: 12.5, color: tapCount == 0 ? Colors.black87 : App.minusColor)),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
      });
  }
}