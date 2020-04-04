import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../chart.dart';

class GraphPage extends StatelessWidget {
  final List<ChartData> _debugChartList = [
    ChartData('4/13', 60.0),
    ChartData('4/14', 70.0),
    ChartData('4/15', 80.0),
    ChartData("", 800),
  ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('グラフ', style: TextStyle(color: Colors.black),),
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 300,
                      margin: EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: ChartContainer(_debugChartList, "合計値")
                      ),
                    ),
                  ]
              )
          )
      ),
    );
  }
}