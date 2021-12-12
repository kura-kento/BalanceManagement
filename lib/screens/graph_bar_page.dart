import 'package:balancemanagement_app/utils/admob.dart';
import 'package:balancemanagement_app/utils/app.dart';
import 'package:balancemanagement_app/utils/database_help.dart';
import 'package:balancemanagement_app/utils/graph_bar.dart';
import 'package:balancemanagement_app/utils/shared_prefs.dart';
import 'package:balancemanagement_app/widget/select_month_widget.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

enum RadioValue { ALL, Twice }

class GraphBarPage extends StatefulWidget {
  @override
  _GraphBarPageState createState() => _GraphBarPageState();
}

class _GraphBarPageState extends State<GraphBarPage> {
  // final BannerAd myBanner = AdMob.admobBanner();
  DatabaseHelper databaseHelper = DatabaseHelper();
  RadioValue _radioValue = RadioValue.ALL;
  int selectMonthValue = 0;
  final toMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<OrdinalSales> data = [];
  List<OrdinalSales>  ListPlus = [];
  List<OrdinalSales>  ListMinus = [];

  @override
  void initState(){
    updateListView();
    super.initState();
  }

  Future<void> updateListView() async{
    final String _month = DateFormat("yyyy-MM").format(DateTime(DateTime.now().year, DateTime.now().month + selectMonthValue, 1));
    print(_month);
    List _calendarList = await databaseHelper.getMonthList(_month);
    print(_calendarList);
    data = await dataSet(_calendarList).reversed.toList();

    List _ListPlus = await databaseHelper.getMonthListPlus(_month);
    List _ListMinus = await databaseHelper.getMonthListMinus(_month);
    ListPlus = await dataSet(_ListPlus).reversed.toList();
    ListMinus = await dataSet(_ListMinus).reversed.toList();

    setState(() {});
  }

  List<OrdinalSales> dataSet(month_db){
    var listIndex = 0;
    
    return List.generate(App.graphLength, (index){
      var _month       = DateFormat("yyyy-MM").format(DateTime(toMonth.year, toMonth.month - index + selectMonthValue, 1));
      var month_format = DateFormat("M月").format(DateTime(toMonth.year, toMonth.month - index + selectMonthValue, 1));

      //配列の中を全て当てはまったら他は０にする。
      if(listIndex == month_db.length) return OrdinalSales(month_format ,0);
      if(_month == month_db[listIndex]['month']){
        listIndex++;
        return OrdinalSales(month_format ,month_db[listIndex - 1]['sum']);
      }
      return OrdinalSales(month_format ,0);
    });
  }

  //引数が２つの場合、支出を追加する。
   List<charts.Series<OrdinalSales, String>> _createSampleData(data, {payout}) {
    return [
      new charts.Series<OrdinalSales, String>(
        id: 'income',
        colorFn: (OrdinalSales sales,i) => sales.sales >= 0 ? charts.MaterialPalette.blue.shadeDefault:charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      ),

      if(payout != null)
        charts.Series<OrdinalSales, String>(
          id: 'payout',
          colorFn: (_, i) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (OrdinalSales sales, _) => sales.year,
          measureFn: (OrdinalSales sales, _) => sales.sales,
          data: payout,
        )
    ];
  }

  //選択中の月をdate型で出す。
  DateTime selectOfMonth(int value) {
    final _selectOfMonth = DateTime(toMonth.year, toMonth.month + value, 1);
    return  _selectOfMonth;
  }

  @override
  Widget build(BuildContext context) {
    // if(AdMob.isNoAds() == false){
    //   myBanner.load();
    //   // myBanner2.load();
    // }

    return Column(
      children: [
        // SharedPrefs.getAdPositionTop()
        //     ? AdMob.adContainer(myBanner)
        //     : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.0,),
            Text('合計'),
            Radio(
              // title: Text('合計'),
              value: RadioValue.ALL,
              groupValue: _radioValue,
              onChanged: (value) {
                  _radioValue = value;
                  setState(() {});
              },
            ),
            Text('収支・支出'),
            Radio(
              // title: Text('収支・支出'),
              value: RadioValue.Twice,
              groupValue: _radioValue,
              onChanged: (value){
                  _radioValue = value;
                  setState(() {});
              },
            ),
          ],
        ),
        SelectMonthWidget(
            tapLeft:(){
                selectMonthValue--;
                // dataUpdate();
                updateListView();
                setState(() {  });
            },
            tapRight: (){
                selectMonthValue++;
                // dataUpdate();
                updateListView();
                setState(() { });
            },
            text: DateFormat.yMMM(Localizations.localeOf(context).languageCode == 'ja' ? 'ja_JP': 'en_JP').format(selectOfMonth(selectMonthValue))
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: SimpleBarChart(
              _radioValue == RadioValue.ALL
                  ?
              _createSampleData(data)
                  :
              _createSampleData(ListPlus,payout: ListMinus),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        // SharedPrefs.getAdPositionTop()
        //     ? Container()
        //     : AdMob.adContainer(myBanner),
      ],
    );
  }
}
