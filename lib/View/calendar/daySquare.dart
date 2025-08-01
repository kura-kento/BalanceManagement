import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../Common/Widget/previewDialog.dart';
import '../../Common/app.dart';
import '../../Common/shared_prefs.dart';
import '../../Common/utils.dart';
import '../../models/DB/database_help.dart';
import 'calendar_page.dart';
import 'edit_form.dart';

class DaySquare extends ConsumerStatefulWidget {
  const DaySquare({Key? key, required this.parentFn}) : super(key: key);
  final Function parentFn;
  @override
  DaySquareState createState() => DaySquareState();
}

class DaySquareState extends ConsumerState<DaySquare> {
  final DateTime _today = DateTime.now();
  // //選択している日
  late DateTime selectDay;
  late int addMonth;

  @override
  Widget build(BuildContext context) {
    selectDay = ref.watch(selectDayProvider);
    addMonth = ref.watch(addMonthProvider);

    final resultWeekList = <Widget>[];
    for (var j = 0; j < 6; j++) {
      final resultWeek = <Widget>[];
      for (var i = 0; i < 7; i++) {
        resultWeek.add(
          Expanded(flex: 1, child: calendarSquare(calendarDay(i, j)),),
        );
      }
      resultWeekList.add(Row(children: resultWeek));
      //土曜日の月が選択月でない　または、月末の場合は終わる。
      if (Utils.toInt(calendarDay(6, j).month) != selectOfMonth(addMonth).month || endOfMonth() == Utils.toInt(calendarDay(6, j).day)) {
        break;
      }
    }
    return Column(children: resultWeekList);
  }

  //カレンダー１日のマス（その月以外は空白にする）
  Widget calendarSquare(DateTime date) {
    if(date.month == selectOfMonth(addMonth).month) {
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
                child: squareValue(date)
            ),
            dayText(date),// 日付
            //クリック時選択表示する。
          ],
        ),
      );
    }else{
      return Container(height: 50.0, color: Colors.grey[200],);
    }
  }

  // その日の金額
  Widget squareValue(date) {
    return FutureBuilder(
      future: DatabaseHelper().sumPriceOfDay(date), // Future<T> 型を返す非同期処理
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          var dayData = snapshot.data[0];
          return InkWell(
            child: Column(
              children: [
                const Spacer(flex: 1),
                //　プラス金額
                Expanded(
                  flex: 1,
                  child:
                  SharedPrefs.getIsZeroHidden() &&  dayData['PLUS'] == 0
                      ?
                  Container()
                      :
                  Container(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AutoSizeText(
                        '${Utils.commaSeparated(dayData['PLUS'])}${SharedPrefs.getUnit()}',
                        style: TextStyle(color: App.plusColor),
                        minFontSize: 3,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                //　マイナス金額
                Expanded(
                  flex: 1,
                  child:
                  SharedPrefs.getIsZeroHidden() &&  dayData['MINUS'] == 0
                      ?
                  Container()
                      :
                  Container(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AutoSizeText(
                        '${Utils.commaSeparated(dayData['MINUS'])}${SharedPrefs.getUnit()}',
                        style: TextStyle(color: App.minusColor),
                        minFontSize: 3,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () async {
              if (selectDay == date) {
                widget.parentFn(null, InputMode.create);
              } else {
                ref.read(selectDayProvider.notifier).state = date;
              }
              // 応急処置(根本解決ではない)
              setState(() {});
            },
          );
        } else {
          return Container();
        }
    });
  }

  Widget dayText(date) {
    return Container(
      height: 50/3,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              color: DateFormat.yMMMd().format(date) == DateFormat.yMMMd().format(_today) ? Colors.red[300] : Colors.transparent ,
              child: Center(
                child: Text(
                  '${Utils.toInt(date.day)}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Utils.parseSize(context, SharedPrefs.getTextSize()),
                    color: DateFormat.yMMMd().format(date) ==  DateFormat.yMMMd().format(_today) ? Colors.white : Colors.black87 ,
                    height: 0.75,
                  ),
                ),
              ),
            ),
          ),
          Spacer(flex: 3,)
        ],
      ),
    );
  }

  //iとjから日程のデータを出す（Date型）
  DateTime calendarDay(int i,int j) {
    final startDay = DateTime(_today.year, _today.month + addMonth, 1);
    final weekNumber = startDay.weekday;
    final calendarStartDay = startDay.add(Duration(days: -(weekNumber % 7) + (i + 7 * j)));
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
}
