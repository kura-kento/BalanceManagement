import 'package:balancemanagement_app/Common/app.dart';
import 'package:balancemanagement_app/models/DB/database_help.dart';
import 'package:balancemanagement_app/Common/graph_bar.dart';
import 'package:balancemanagement_app/widget/select_month_widget.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

enum RadioValue { ALL, Twice }

class GraphBarPage extends StatefulWidget {
  @override
  _GraphBarPageState createState() => _GraphBarPageState();
}

class _GraphBarPageState extends State<GraphBarPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final int graphLength = 10;
  RadioValue _radioValue = RadioValue.ALL;
  int selectMonthValue = 0;
  final toMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<OrdinalSales> data = [];
  List<OrdinalSales>  ListPlus = [];
  List<OrdinalSales>  ListMinus = [];

  List<OrdinalSales>  categoryPlus = [];
  List<OrdinalSales>  categoryMinus = [];
  final chartPlusColor = charts.ColorUtil.fromDartColor(App.plusColor);
  final ChartMinusColor = charts.ColorUtil.fromDartColor(App.minusColor);

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    updateListView();
    super.initState();
  }

  Future<void> updateListView() async {
    final String _month = DateFormat("yyyy-MM").format(DateTime(DateTime.now().year, DateTime.now().month + selectMonthValue, 1));

    List _calendarList = await DatabaseHelper().getMonthList(_month);
    data = await dataSet(_calendarList).reversed.toList();

    List _ListPlus = await DatabaseHelper().getMonthListPlus(_month);
    List _ListMinus = await DatabaseHelper().getMonthListMinus(_month);

    ListPlus = await dataSet(_ListPlus).reversed.toList();
    ListMinus = await dataSet(_ListMinus).reversed.toList();

    categoryPlus = await DatabaseHelper().getMonthListPlus2(_month);
    categoryMinus = await DatabaseHelper().getMonthListMinus2(_month);
    setState(() {});
  }

  List<OrdinalSales> dataSet(month_db) {
    var listIndex = 0;

    return List.generate(graphLength, (index) {
      var _month       = DateFormat("yyyy-MM").format(DateTime(toMonth.year, toMonth.month - index + selectMonthValue, 1));
      var month_format = DateFormat("M月").format(DateTime(toMonth.year, toMonth.month - index + selectMonthValue, 1));

      //配列の中を全て当てはまったら他は０にする。
      if (listIndex == month_db.length) return OrdinalSales(month_format ,0);
      if (_month == month_db[listIndex]['month']) {
        listIndex++;
        return OrdinalSales(month_format , month_db[listIndex - 1]['sum']);
      }
      return OrdinalSales(month_format ,0);
    });
  }

  //引数が２つの場合、支出を追加する。
   List<charts.Series<OrdinalSales, String>> _createSampleData(data, {payout}) {
    return [
      if (data != null)
       charts.Series<OrdinalSales, String>(
        id: 'income',
        colorFn: (OrdinalSales sales,i) => sales.sales >= 0 ? chartPlusColor:ChartMinusColor,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Center(child: Tab(text: "全体")),
              Center(child: Tab(text: "カテゴリ")),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            tabBarView1(),
            tabBarView2(),
          ],
        ),
      ),
    );
  }

  Widget tabBarView1() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.0,),
            Text('合計'),
            Radio(
              value: RadioValue.ALL,
              groupValue: _radioValue,
              onChanged: (value) {
                _radioValue = value as RadioValue;
                setState(() {});
              },
            ),
            Text('収支'),
            Radio<RadioValue>(
              // title: Text('収支・支出'),
              value: RadioValue.Twice,
              groupValue: _radioValue,
              onChanged: (RadioValue? value) {
                if (value != null) {
                  setState(() {
                    _radioValue = value;
                  });
                }
              },
            ),
          ],
        ),
        SelectMonthWidget(
            tapLeft:() {
              selectMonthValue--;
              updateListView();
              setState(() {  });
            },
            tapRight: (){
              selectMonthValue++;
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
      ],
    );
  }

  Widget tabBarView2() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10.0),
            Text('プラス'),
            Radio(
              value: RadioValue.ALL,
              groupValue: _radioValue,
              onChanged: (RadioValue? value) {
                if (value != null) {
                  _radioValue = value;
                  setState(() {});
                }
              },
            ),
            Text('マイナス'),
            Radio<RadioValue>(
              value: RadioValue.Twice,
              groupValue: _radioValue,
              onChanged: (RadioValue? value) {
                if (value != null) {
                  _radioValue = value;
                  setState(() {});
                }
              },
            ),
          ],
        ),
        SelectMonthWidget(
            tapLeft:() {
              selectMonthValue--;
              updateListView();
              setState(() {  });
            },
            tapRight: (){
              selectMonthValue++;
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
              _createSampleData(categoryPlus)
                  :
              _createSampleData(null,payout: categoryMinus),
              // _createSampleData(categoryMinus)
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}
