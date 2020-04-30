import 'package:balancemanagement_app/screens/calendar_page.dart';
import 'package:balancemanagement_app/screens/setting_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_ad_manager/flutter_google_ad_manager.dart';
import 'graph_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //以下BottomNavigationBar設定
  int _currentIndex = 0;
  final _pageWidgets = [
    CalendarPage(),
    GraphPage(),
    SettingPage(),
  ];

//メインのページ
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Scaffold(
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
          ),
        ),
        DFPBanner(
          isDevelop: true,
          testDevices: MyTestDevices(),
          adUnitId: '/XXXXXXXXX/XXXXXXXXX',
          adSize: DFPAdSize.BANNER,
          onAdLoaded: () {
            print('Banner onAdLoaded');
          },
          onAdFailedToLoad: (errorCode) {
            print('Banner onAdFailedToLoad: errorCode:$errorCode');
          },
          onAdOpened: () {
            print('Banner onAdOpened');
          },
          onAdClosed: () {
            print('Banner onAdClosed');
          },
          onAdLeftApplication: () {
            print('Banner onAdLeftApplication');
          },
        ),
      ],
    );
  }
  void _onItemTapped(int index) => setState(() => _currentIndex = index );
}

class MyTestDevices extends TestDevices {
  static MyTestDevices _instance;

  factory MyTestDevices() {
    if (_instance == null) _instance = new MyTestDevices._internal();
    return _instance;
  }

  MyTestDevices._internal();

  @override
  List<String> get values => List()..add("XXXXXXXX"); // Set here.
}